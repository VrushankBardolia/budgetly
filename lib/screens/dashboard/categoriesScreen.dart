import 'package:budgetly/model/Expense.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';

import '../../provider/CategoryProvider.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  Future<void> _addCategory(BuildContext context) async {
    final nameController = TextEditingController();
    final emojiController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emojiController,
              decoration: const InputDecoration(
                labelText: 'Emoji',
                hintText: '🛒',
                border: OutlineInputBorder(),
              ),
              maxLength: 1,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  emojiController.text.isNotEmpty) {
                try {
                  await context.read<CategoryProvider>().addCategory(
                    nameController.text,
                    emojiController.text,
                  );

                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                } catch (e) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(
                        content: Text(
                          e.toString().replaceAll('Exception: ', ''),
                        ),
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(BuildContext context, String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        await context.read<CategoryProvider>().deleteCategory(id);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
          );
        }
      }
    }
  }

  Future<void> _editCategory(
      BuildContext context,
      Category category,
      ) async {
    final nameController = TextEditingController(text: category.name);
    final emojiController = TextEditingController(text: category.emoji);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emojiController,
              decoration: const InputDecoration(
                labelText: 'Emoji',
                border: OutlineInputBorder(),
              ),
              maxLength: 1,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  emojiController.text.isNotEmpty) {
                try {
                  final updatedCategory = Category(
                    id: category.id,
                    name: nameController.text.trim(),
                    emoji: emojiController.text.trim(),
                    userId: category.userId,
                  );

                  await context.read<CategoryProvider>().updateCategory(
                    category.id,
                    updatedCategory,
                  );

                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                } catch (e) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(
                        content: Text(
                          e.toString().replaceAll('Exception: ', ''),
                        ),
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, _) {
          if (categoryProvider.categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text('No categories yet'),
                  const SizedBox(height: 8),
                  const Text('Add categories to track expenses'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categoryProvider.categories.length,
            itemBuilder: (context, index) {
              final category = categoryProvider.categories[index];
              return GestureDetector(
                onLongPressStart: (details) {
                  showPullDownMenu(
                    context: context,
                    routeTheme: PullDownMenuRouteTheme(
                      backgroundColor: Colors.black,
                    ),
                    items: [
                      PullDownMenuItem(
                        onTap:()=> _editCategory(context, category),
                        title: "Edit",
                        icon: CupertinoIcons.pen,
                        itemTheme: PullDownMenuItemTheme(
                          textStyle: TextStyle(
                            fontFamily:
                            GoogleFonts.plusJakartaSans()
                                .fontFamily,
                          ),
                        ),
                      ),
                      // PullDownMenuDivider.large(color: Theme.of(context).scaffoldBackgroundColor,),
                      PullDownMenuItem(
                        onTap: () => _deleteCategory(context, category.id, category.name),
                        title: "Delete",
                        icon: CupertinoIcons.delete,
                        isDestructive: true,
                        itemTheme: PullDownMenuItemTheme(
                          textStyle: TextStyle(
                            fontFamily:
                            GoogleFonts.plusJakartaSans()
                                .fontFamily,
                          ),
                        ),
                      ),
                    ],
                    position: Rect.fromLTRB(
                      details.globalPosition.dx,
                      details.globalPosition.dy,
                      details.globalPosition.dx,
                      details.globalPosition.dy,
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Text(category.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(category.name, style: const TextStyle(fontSize: 20),)
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addCategory(context),
        label: Text("Add Category"),
        icon: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterFloat,
    );
  }
}
package com.app.budgetly

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class RemainingBudgetWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.remaining_budget_widget).apply {
                val remainingBudget = widgetData.getString("remaining_budget", "₹0") ?: "₹0"
                val budgetValue = widgetData.getString("budget_value", "₹0") ?: "₹0"
                val expenseValue = widgetData.getString("expense_value", "₹0") ?: "₹0"
                val monthName = widgetData.getString("month_name", "Budgetly") ?: "Budgetly"

                setTextViewText(R.id.widget_remaining_budget, remainingBudget)
                setTextViewText(R.id.widget_spent_value, expenseValue)
                setTextViewText(R.id.widget_budget_value, budgetValue)
                setTextViewText(R.id.widget_month_name, monthName)

                try {
                    val budgetDouble = budgetValue.replace("₹", "").toDoubleOrNull() ?: 0.0
                    val expenseDouble = expenseValue.replace("₹", "").toDoubleOrNull() ?: 0.0
                    val progress = if (budgetDouble > 0) {
                        ((expenseDouble / budgetDouble) * 100).toInt().coerceIn(0, 100)
                    } else {
                        0
                    }
                    setProgressBar(R.id.widget_progress_bar, 100, progress, false)
                } catch (e: Exception) {
                    setProgressBar(R.id.widget_progress_bar, 100, 0, false)
                }

                try {
                    val remainingDouble = remainingBudget.replace("₹", "").replace("+", "").toDoubleOrNull()
                    if (remainingDouble != null && remainingDouble < 0) {
                        setTextColor(R.id.widget_remaining_budget, android.graphics.Color.parseColor("#EF5350"))
                    } else {
                        setTextColor(R.id.widget_remaining_budget, android.graphics.Color.parseColor("#66BB6A"))
                    }
                } catch (e: Exception) {
                    setTextColor(R.id.widget_remaining_budget, android.graphics.Color.parseColor("#66BB6A"))
                }
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}

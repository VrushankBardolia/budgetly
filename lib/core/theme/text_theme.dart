import 'package:budgetly/core/import_to_export.dart';

TextStyle regularText(double size, {Color? color, double? height}) {
  return GoogleFonts.schibstedGrotesk(
    fontSize: size,
    fontWeight: FontWeight.w400,
    color: color ?? AppColors.textPrimary,
    height: height,
  );
}

TextStyle boldText(double size, {Color? color, double? height}) {
  return GoogleFonts.schibstedGrotesk(
    fontSize: size,
    fontWeight: FontWeight.bold,
    color: color ?? AppColors.textPrimary,
    height: height,
  );
}

TextStyle semiBoldText(double size, {Color color = AppColors.textPrimary, double? height}) {
  return GoogleFonts.schibstedGrotesk(
    fontSize: size,
    fontWeight: FontWeight.w600,
    color: color,
    height: height,
  );
}

TextStyle mediumText(double size, {Color? color, double? height}) {
  return GoogleFonts.schibstedGrotesk(
    fontSize: size,
    fontWeight: FontWeight.w500,
    color: color ?? AppColors.textPrimary,
    height: height,
  );
}

TextStyle customText(double size, FontWeight fontWeight, {Color? color, double? height}) {
  return GoogleFonts.plusJakartaSans(
    fontSize: size,
    fontWeight: fontWeight,
    color: color ?? AppColors.textPrimary,
    height: height,
  );
}

TextStyle serifText(double size, {FontWeight? fontWeight, Color? color, double? height}) {
  return GoogleFonts.lora(
    fontSize: size,
    fontWeight: fontWeight ?? FontWeight.w400,
    color: color ?? AppColors.textPrimary,
    height: height,
  );
}

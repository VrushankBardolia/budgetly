import 'package:budgetly/core/import_to_export.dart';

TextStyle regularText(double size, {Color color = AppColors.white, double? height}) {
  return GoogleFonts.plusJakartaSans(
    fontSize: size,
    fontWeight: FontWeight.w500,
    color: color,
    height: height,
  );
}

TextStyle boldText(double size, {Color color = AppColors.white, double? height}) {
  return GoogleFonts.plusJakartaSans(
    fontSize: size,
    fontWeight: FontWeight.bold,
    color: color,
    height: height,
  );
}

TextStyle semiBoldText(double size, {Color color = AppColors.white, double? height}) {
  return GoogleFonts.plusJakartaSans(
    fontSize: size,
    fontWeight: FontWeight.w600,
    color: color,
    height: height,
  );
}

TextStyle mediumText(double size, {Color color = AppColors.white, double? height}) {
  return GoogleFonts.plusJakartaSans(
    fontSize: size,
    fontWeight: FontWeight.w500,
    color: color,
    height: height,
  );
}

TextStyle customText(
  double size,
  FontWeight fontWeight, {
  Color color = AppColors.white,
  double? height,
}) {
  return GoogleFonts.plusJakartaSans(
    fontSize: size,
    fontWeight: fontWeight,
    color: color,
    height: height,
  );
}

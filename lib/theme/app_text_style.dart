import 'package:flutter/widgets.dart';
import 'package:ridelink_admin/core/constants/app_colors.dart';

class AppTextStyle {
  AppTextStyle._();

  static const _fontFamily = 'Inter';

  static TextStyle text42Bold = TextStyle(
    fontSize: 42,
    color: AppColors.primaryTextColor,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static TextStyle text20Medium = TextStyle(
    fontSize: 20,
    color: AppColors.primaryTextColor,
    fontWeight: FontWeight.w500,
    height: 28 / 20,
    fontFamily: _fontFamily,
  );

  static TextStyle text16Medium = TextStyle(
    fontSize: 16,
    color: AppColors.primaryTextColor,
    fontWeight: FontWeight.w500,
    height: 24 / 16,
    fontFamily: _fontFamily,
  );

  static TextStyle text14Medium = TextStyle(
    fontSize: 14,
    color: AppColors.primaryTextColor,
    fontWeight: FontWeight.w500,
    height: 20 / 14,
    fontFamily: _fontFamily,
  );

  static TextStyle text12MediumOrSmall = TextStyle(
    fontSize: 12,
    color: AppColors.primaryTextColor,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    fontFamily: _fontFamily,
  );
  static TextStyle text10Medium = TextStyle(
    fontSize: 10,
    color: AppColors.primaryTextColor,
    fontWeight: FontWeight.w500,
    height: 14 / 10,
    fontFamily: _fontFamily,
  );
  static TextStyle text12Semibold = TextStyle(
    fontSize: 12,
    color: AppColors.primaryTextColor,
    fontWeight: FontWeight.w600,
    height: 16 / 12,
    fontFamily: _fontFamily,
  );

  static TextStyle text30Semibold = TextStyle(
    fontSize: 30,
    color: AppColors.primaryTextColor,
    fontWeight: FontWeight.w600,
    height: 36 / 30,
    fontFamily: _fontFamily,
  );

  static TextStyle text24Semibold = TextStyle(
    fontSize: 24,
    color: AppColors.primaryTextColor,
    fontWeight: FontWeight.w600,
    height: 32 / 24,
  );

  static TextStyle text20Semibold = TextStyle(
    fontSize: 20,
    color: AppColors.primaryTextColor,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
    fontFamily: _fontFamily,
  );
  static TextStyle text18Semibold = TextStyle(
    fontSize: 18,
    color: AppColors.primaryTextColor,
    fontWeight: FontWeight.w600,
    height: 28 / 18,
    fontFamily: _fontFamily,
  );

  static TextStyle text16Semibold = TextStyle(
    fontSize: 16,
    color: AppColors.primaryTextColor,
    fontWeight: FontWeight.w600,
    height: 24 / 16,
  );

  static TextStyle text14Semibold = TextStyle(
    fontSize: 14,
    color: AppColors.primaryTextColor,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
    fontFamily: _fontFamily,
  );

  static TextStyle text14Regular = TextStyle(
    fontSize: 14,
    color: AppColors.primaryTextColor,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    fontFamily: _fontFamily,
  );
  static TextStyle text16Regular = TextStyle(
    fontSize: 16,
    color: AppColors.primaryTextColor,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
  );
  static TextStyle text12Regular = TextStyle(
    fontSize: 12,
    color: AppColors.primaryTextColor,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    fontFamily: _fontFamily,
  );

  static TextStyle headlineMedium_28 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    fontFamily: _fontFamily,
    color: AppColors.primaryTextColor,
  );

  static TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
    color: AppColors.white,
  );

  static TextStyle error = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFamily: _fontFamily,
    color: AppColors.primaryTextColor,
  );
}

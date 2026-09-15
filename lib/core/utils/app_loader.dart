import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class CircularLoader extends StatelessWidget {
  const CircularLoader({super.key, this.color, this.loaderSize});
  final Color? color;
  final double? loaderSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: loaderSize ?? 20,
      height: loaderSize ?? 20,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.primaryColor,
        ),
        strokeCap: StrokeCap.round,
        strokeWidth: 2,
      ),
    );
  }
}

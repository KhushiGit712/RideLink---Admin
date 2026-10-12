import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ridelink_admin/core/constants/app_colors.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: () => Get.back(),
        child: Icon(
          CupertinoIcons.back,
          size: 18,
          color: AppColors.secondaryTextColor,
        ),
      ).paddingOnly(bottom: 20),
    );
  }
}

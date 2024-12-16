import 'package:flutter/material.dart';
import 'package:unshelf_seller/utils/colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final Widget? actionWidget;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.onBackPressed,
    this.actionWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: AppColors.primaryColor,
      foregroundColor: Colors.white,
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: AppColors.darkColor,
        ),
        onPressed: onBackPressed ?? () => Navigator.pop(context),
      ),
      actions: actionWidget != null ? [actionWidget!] : null,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4.0),
        child: Container(
          color: AppColors.lightColor,
          height: 4.0,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 4.0);
}

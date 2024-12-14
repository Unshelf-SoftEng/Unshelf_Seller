import 'package:flutter/material.dart';
import 'package:unshelf_seller/utils/colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Alignment alignment;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: const WidgetStatePropertyAll(
          AppColors.middleGreenYellow,
        ),
        foregroundColor: const WidgetStatePropertyAll(
          AppColors.deepMossGreen,
        ),
        alignment: alignment,
      ),
      onPressed: onPressed,
      child: Text(
        text,
      ),
    );
  }
}

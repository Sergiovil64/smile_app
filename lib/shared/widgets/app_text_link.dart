import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class AppTextLink extends StatelessWidget {
  const AppTextLink({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppColors.primary,
    this.fontSize = 14,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.underline,
          decorationColor: color,
        ),
      ),
    );
  }
}

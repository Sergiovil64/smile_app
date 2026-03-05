import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class HistorialTab extends StatelessWidget {
  const HistorialTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Historial',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 18,
        ),
      ),
    );
  }
}

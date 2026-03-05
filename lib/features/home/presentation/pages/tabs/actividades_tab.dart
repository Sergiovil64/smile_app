import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class ActividadesTab extends StatelessWidget {
  const ActividadesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Actividades',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 18,
        ),
      ),
    );
  }
}

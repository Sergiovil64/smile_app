import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class ContenidoTab extends StatelessWidget {
  const ContenidoTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Contenido',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 18,
        ),
      ),
    );
  }
}

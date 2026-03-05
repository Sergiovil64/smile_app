import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../providers/home_providers.dart';

class PerfilTab extends ConsumerWidget {
  const PerfilTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentUserProfileProvider);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: profileAsync.when(
          data: (profile) {
            final fullName = profile != null
                ? '${profile.firstName} ${profile.lastName}'
                : '';
            return Text(
              'Bienvenido $fullName a Smile App',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            );
          },
          loading: () => const CircularProgressIndicator(
            color: AppColors.primary,
          ),
          error: (_, __) => const Text(
            'Bienvenido a Smile App',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

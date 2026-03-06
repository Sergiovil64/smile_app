import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../notifiers/emotional_log_state.dart';
import '../providers/emotional_log_providers.dart';

// La pagina de creacion de un registro emocional
// Muestra un selector de estado emocional y una nota opcional

const _moodEmojis = ['😢', '😕', '😐', '😊', '😄'];
const _moodLabels = ['Muy triste', 'Triste', 'Neutral', 'Feliz', 'Muy feliz'];

class CreateEmotionalLogPage extends ConsumerStatefulWidget {
  const CreateEmotionalLogPage({super.key});

  @override
  ConsumerState<CreateEmotionalLogPage> createState() =>
      _CreateEmotionalLogPageState();
}

class _CreateEmotionalLogPageState
    extends ConsumerState<CreateEmotionalLogPage> {
  int _selectedMood = 3; // 1-based index, default neutral (index 2 → mood 3)
  final _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    await ref.read(createLogNotifierProvider.notifier).createLog(
          moodIndicator: _selectedMood,
          textNote: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<CreateLogState>(createLogNotifierProvider, (_, next) {
      if (next is CreateLogSuccess) {
        ref.invalidate(emotionalLogsProvider);
        ref.read(createLogNotifierProvider.notifier).reset();
        Navigator.of(context).pop();
      } else if (next is CreateLogError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message)),
        );
        ref.read(createLogNotifierProvider.notifier).reset();
      }
    });

    final state = ref.watch(createLogNotifierProvider);
    final isLoading = state is CreateLogLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Nuevo Registro',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textSecondary),
          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          children: [
            Text(
              '¿Cómo te sientes hoy?',
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Selecciona el estado que mejor describe tu día.',
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            _MoodSelector(
              selected: _selectedMood,
              onChanged: (mood) => setState(() => _selectedMood = mood),
            ),
            const SizedBox(height: 32),
            Text(
              'Nota (opcional)',
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _noteController,
              maxLines: 5,
              maxLength: 500,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Escribe algo sobre tu día...',
                hintStyle:
                    const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                filled: true,
                fillColor: AppColors.surface,
                counterStyle:
                    const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 40),
            AppButton(
              label: 'GUARDAR REGISTRO',
              isLoading: isLoading,
              showIcon: false,
              onPressed: isLoading ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodSelector extends StatelessWidget {
  const _MoodSelector({required this.selected, required this.onChanged});

  final int selected;
  final void Function(int mood) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(_moodEmojis.length, (i) {
        final mood = i + 1;
        final isSelected = selected == mood;
        return Tooltip(
          message: _moodLabels[i],
          child: GestureDetector(
          onTap: () => onChanged(mood),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 56,
            height: 72,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withAlpha(30)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _moodEmojis[i],
                  style: TextStyle(fontSize: isSelected ? 30 : 24),
                ),
                const SizedBox(height: 4),
                Text(
                  '${mood}',
                  style: GoogleFonts.inter(
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

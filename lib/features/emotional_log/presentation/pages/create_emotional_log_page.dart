import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../notifiers/emotional_log_state.dart';
import '../providers/emotional_log_providers.dart';

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
  int _selectedMood = 3;
  final _noteController = TextEditingController();
  String? _audioFilePath;

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
          audioFilePath: _audioFilePath,
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
      body: ListView(
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
            maxLines: 4,
            maxLength: 500,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Escribe algo sobre tu día...',
              hintStyle: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14),
              filled: true,
              fillColor: AppColors.surface,
              counterStyle: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12),
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
          const SizedBox(height: 24),
          Text(
            'Audio (opcional)',
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _AudioSection(
            onAudioReady: (path) => setState(() => _audioFilePath = path),
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
    );
  }
}

// ── Mood selector ────────────────────────────────────────────────────────────

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
                    '$mood',
                    style: GoogleFonts.inter(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
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


// Estado del selector de audio
enum _AudioMode { none, record, pick }

// Widget para la sección de audio
class _AudioSection extends StatefulWidget {
  const _AudioSection({required this.onAudioReady});
  final void Function(String? path) onAudioReady;

  @override
  State<_AudioSection> createState() => _AudioSectionState();
}

// Estado de la sección de audio
class _AudioSectionState extends State<_AudioSection> {
  _AudioMode _mode = _AudioMode.none;
  final _recorder = AudioRecorder();
  bool _isRecording = false;
  int _secondsElapsed = 0;
  Timer? _timer;
  String? _audioFilePath;
  String? _audioFileName;

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  String get _formattedTime {
    final m = _secondsElapsed ~/ 60;
    final s = _secondsElapsed % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Permiso de micrófono denegado.')),
        );
      }
      return;
    }

    final dir = await _getTempDir();
    final path =
        '$dir/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _secondsElapsed++);
    });

    setState(() => _isRecording = true);
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    final path = await _recorder.stop();
    setState(() {
      _isRecording = false;
      _audioFilePath = path;
      _audioFileName =
          'Grabación — $_formattedTime';
    });
    widget.onAudioReady(path);
  }

  Future<void> _pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      final name = result.files.single.name;
      setState(() {
        _audioFilePath = path;
        _audioFileName = name;
      });
      widget.onAudioReady(path);
    }
  }

  void _clearAudio() {
    _timer?.cancel();
    if (_isRecording) _recorder.stop();
    setState(() {
      _isRecording = false;
      _secondsElapsed = 0;
      _audioFilePath = null;
      _audioFileName = null;
    });
    widget.onAudioReady(null);
  }

  Future<String> _getTempDir() async {
    final dir = await getTemporaryDirectory();
    return dir.path;
  }

  @override
  Widget build(BuildContext context) {
    // If a file has been selected/recorded, show preview
    if (_audioFilePath != null) {
      return _AudioPreview(
        fileName: _audioFileName ?? 'Audio adjunto',
        onDelete: () {
          _clearAudio();
          setState(() => _mode = _AudioMode.none);
        },
      );
    }

    // Mode selector buttons
    if (_mode == _AudioMode.none) {
      return Row(
        children: [
          Expanded(
            child: _ModeButton(
              icon: LucideIcons.mic,
              label: 'Grabar',
              onTap: () => setState(() => _mode = _AudioMode.record),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ModeButton(
              icon: LucideIcons.folder_open,
              label: 'Subir archivo',
              onTap: () {
                setState(() => _mode = _AudioMode.pick);
                _pickAudioFile();
              },
            ),
          ),
        ],
      );
    }

    // Recording UI
    if (_mode == _AudioMode.record) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            if (_isRecording)
              Text(
                _formattedTime,
                style: GoogleFonts.inter(
                  color: AppColors.error,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            if (_isRecording) const SizedBox(height: 12),
            GestureDetector(
              onTap: _isRecording ? _stopRecording : _startRecording,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: _isRecording ? AppColors.error : AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isRecording ? LucideIcons.square : LucideIcons.mic,
                  color: _isRecording
                      ? AppColors.textPrimary
                      : AppColors.onPrimary,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isRecording ? 'Toca para detener' : 'Toca para grabar',
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                _clearAudio();
                setState(() => _mode = _AudioMode.none);
              },
              child: Text(
                'Cancelar',
                style: GoogleFonts.inter(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      );
    }

    // Pick mode: show loading while picker is open, then return to none
    return const SizedBox.shrink();
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AudioPreview extends StatelessWidget {
  const _AudioPreview({required this.fileName, required this.onDelete});

  final String fileName;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withAlpha(80)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.mic, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              fileName,
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.x,
                color: AppColors.textSecondary, size: 18),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

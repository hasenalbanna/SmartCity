import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../services/community_issue_service.dart';
import '../services/voice_ai_assistant_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'ui/ui.dart';

class VoiceAiReportModal extends StatefulWidget {
  final LatLng initialLocation;
  final Function(VoiceAiCommandResult result)? onReportGenerated;

  const VoiceAiReportModal({
    super.key,
    required this.initialLocation,
    this.onReportGenerated,
  });

  static Future<VoiceAiCommandResult?> show(
    BuildContext context, {
    required LatLng initialLocation,
    Function(VoiceAiCommandResult result)? onReportGenerated,
  }) {
    return showModalBottomSheet<VoiceAiCommandResult>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => VoiceAiReportModal(
        initialLocation: initialLocation,
        onReportGenerated: onReportGenerated,
      ),
    );
  }

  @override
  State<VoiceAiReportModal> createState() => _VoiceAiReportModalState();
}

class _VoiceAiReportModalState extends State<VoiceAiReportModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final TextEditingController _voiceInputController = TextEditingController();
  bool _isListening = false;
  bool _isProcessing = false;
  String _statusText = 'Tap the microphone or select a quick voice phrase';
  VoiceAiCommandResult? _lastResult;

  static const List<String> _quickVoicePhrases = [
    'Deep dangerous pothole on Main Road near hospital',
    'Stormwater canal overflowing with flood water into street',
    'Street lights completely broken on Beach Road junction',
    'Large illegal garbage dump accumulating near public park',
    'Wave barriers damaged by coastal erosion on beachfront',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.94, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _voiceInputController.dispose();
    super.dispose();
  }

  Future<void> _handleVoiceSubmission(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _isProcessing = true;
      _statusText = 'AI evaluating speech intent & municipal routing...';
    });

    final result = await VoiceAiAssistantService.processVoicePrompt(
      text,
      defaultLocation: widget.initialLocation,
    );

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
      _lastResult = result;
      _statusText = result.responseMessage;
    });

    if (widget.onReportGenerated != null) {
      widget.onReportGenerated!(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppSpace.lg,
        left: AppSpace.lg,
        right: AppSpace.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpace.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outline(context),
              borderRadius: AppRadius.pillBorder,
            ),
          ),
          const SizedBox(height: AppSpace.md),
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.primary(context),
              ),
              const SizedBox(width: AppSpace.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Voice AI Hazard Assistant',
                      style: AppTypography.title.copyWith(
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    Text(
                      'Speak in English or Tamil to auto-triage civic reports',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.lg),
          ScaleTransition(
            scale: _isListening
                ? _pulseAnimation
                : const AlwaysStoppedAnimation(1.0),
            child: Semantics(
              label: 'Toggle microphone listening',
              button: true,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isListening = !_isListening;
                    _statusText = _isListening
                        ? 'Listening... Describe the civic issue clearly.'
                        : 'Tap microphone or enter voice text below.';
                  });
                },
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: _isListening
                        ? AppColors.danger(context)
                        : AppColors.primary(context),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpace.md),
          Text(
            _statusText,
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: AppSpace.lg),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _voiceInputController,
                  onSubmitted: _handleVoiceSubmission,
                  decoration: const InputDecoration(
                    hintText: 'Or type what you would say...',
                  ),
                ),
              ),
              const SizedBox(width: AppSpace.sm),
              AppButton(
                label: 'Analyze',
                isLoading: _isProcessing,
                onPressed: () =>
                    _handleVoiceSubmission(_voiceInputController.text),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.lg),
          if (_lastResult != null && _lastResult!.generatedIssue != null) ...[
            AppCard(
              accentBorderColor: AppColors.success(context),
              backgroundColor: AppColors.surfaceMuted(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StatusChip(
                        label: _lastResult!.detectedCategory ?? 'CIVIC ISSUE',
                        kind: StatusChipKind.resolved,
                      ),
                      StatusChip(
                        label:
                            'Urgency ${_lastResult!.generatedIssue!.aiAnalysis?.urgencyScore ?? 7.5}/10',
                        kind: StatusChipKind.pending,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.sm),
                  Text(
                    _lastResult!.suggestedTitle ?? '',
                    style: AppTypography.subtitle.copyWith(
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: AppSpace.xs),
                  Text(
                    'Ticket Ref: ${_lastResult!.generatedIssue!.aiAnalysis?.councilTicketId ?? "CW-2026"}',
                    style: AppTypography.caption.copyWith(
                      fontFamily: 'monospace',
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                  const SizedBox(height: AppSpace.md),
                  AppButton(
                    label: 'Confirm & Dispatch to Council',
                    icon: Icons.check_circle_outline_rounded,
                    fullWidth: true,
                    onPressed: () {
                      context.read<CommunityIssueService>().addDirectIssue(
                        _lastResult!.generatedIssue!,
                      );
                      Navigator.pop(context, _lastResult);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Issue dispatched to Nintavur Municipal Work Order queue.',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.lg),
          ],
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'SAMPLE VOICE COMMANDS',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpace.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _quickVoicePhrases.map((phrase) {
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpace.sm),
                  child: ActionChip(
                    avatar: const Icon(
                      Icons.record_voice_over_outlined,
                      size: 15,
                    ),
                    label: Text(
                      phrase.length > 34
                          ? '${phrase.substring(0, 32)}...'
                          : phrase,
                    ),
                    onPressed: () => _handleVoiceSubmission(phrase),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

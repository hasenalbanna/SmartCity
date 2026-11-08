import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../services/community_issue_service.dart';
import '../services/voice_ai_assistant_service.dart';

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
      backgroundColor: Colors.transparent,
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

  final List<String> _quickVoicePhrases = const [
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
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161A22) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -6)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome, color: Color(0xFF2563EB), size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Voice AI Assistant',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        'Powered by Smart City AI Triage Engine',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white54 : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Pulsing Mic Trigger
          GestureDetector(
            onTap: () {
              setState(() => _isListening = !_isListening);
              if (_isListening) {
                // Simulate listening and auto-processing after 2 seconds
                setState(() => _statusText = 'Listening... Speak your issue');
                Future.delayed(const Duration(milliseconds: 2200), () {
                  if (mounted && _isListening) {
                    setState(() => _isListening = false);
                    _handleVoiceSubmission('Deep dangerous pothole on Main Road near hospital');
                  }
                });
              } else {
                setState(() => _statusText = 'Tap microphone to start speaking');
              }
            },
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isListening ? _pulseAnimation.value : 1.0,
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: _isListening
                            ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                            : [const Color(0xFF2563EB), const Color(0xFF1D4ED8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_isListening ? const Color(0xFFEF4444) : const Color(0xFF2563EB))
                              .withValues(alpha: 0.4),
                          blurRadius: 18,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isListening ? Icons.graphic_eq : Icons.mic,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),

          // Status message
          Text(
            _statusText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _isProcessing
                  ? const Color(0xFF2563EB)
                  : (_lastResult != null ? const Color(0xFF10B981) : (isDark ? Colors.white70 : const Color(0xFF4B5563))),
            ),
          ),

          const SizedBox(height: 18),

          // If AI produced a result
          if (_lastResult != null && _lastResult!.generatedIssue != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF10B981), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _lastResult!.detectedCategory ?? 'CIVIC ISSUE',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF047857),
                          ),
                        ),
                      ),
                      Text(
                        'Urgency: ${_lastResult!.generatedIssue!.aiAnalysis?.urgencyScore}/10',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _lastResult!.suggestedTitle ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ticket Ref: ${_lastResult!.generatedIssue!.aiAnalysis?.councilTicketId ?? "CW-2026"}',
                    style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<CommunityIssueService>().addDirectIssue(_lastResult!.generatedIssue!);
                        Navigator.pop(context, _lastResult);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Issue successfully dispatched to Municipal Work Order queue!'),
                            backgroundColor: Color(0xFF10B981),
                          ),
                        );
                      },
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('Confirm & Dispatch to Council', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Quick Voice Phrases List
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'OR TAP A SAMPLE VOICE PHRASE:',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: isDark ? Colors.white54 : const Color(0xFF6B7280),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _quickVoicePhrases.map((phrase) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    avatar: const Icon(Icons.record_voice_over_outlined, size: 14),
                    label: Text(
                      phrase.length > 32 ? '${phrase.substring(0, 30)}...' : phrase,
                      style: const TextStyle(fontSize: 12),
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


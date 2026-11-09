import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import '../models/community_issue.dart';
import '../services/community_issue_service.dart';
import '../services/falcon_ai_service.dart';
import '../services/notification_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'premium_store_modal.dart';
import 'ui/ui.dart';

class FalconAiDisasterPanel extends StatefulWidget {
  final MapController mapController;

  const FalconAiDisasterPanel({
    super.key,
    required this.mapController,
  });

  @override
  State<FalconAiDisasterPanel> createState() => _FalconAiDisasterPanelState();
}

class _FalconAiDisasterPanelState extends State<FalconAiDisasterPanel> {
  final TextEditingController _customCommandCtrl = TextEditingController();

  @override
  void dispose() {
    _customCommandCtrl.dispose();
    super.dispose();
  }

  void _handleDispatchedIssue(
    BuildContext context,
    CommunityIssue emergencyIssue,
  ) {
    final issueService = context.read<CommunityIssueService>();
    final notificationService = context.read<NotificationService>();

    issueService.addDirectIssue(emergencyIssue);
    notificationService.add(
      title: '🚨 FALCON AI EMERGENCY SOS DISPATCHED',
      body:
          'Live GPS locked at ${emergencyIssue.address}. Ticket ${emergencyIssue.aiAnalysis?.councilTicketId} broadcast & acoustic siren active!',
      type: NotificationType.alert,
    );

    // Center the map directly on the locked emergency coordinates!
    widget.mapController.move(emergencyIssue.location, 15.8);
  }

  @override
  Widget build(BuildContext context) {
    final falcon = context.watch<FalconAiService>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.lg,
        AppSpace.md,
        AppSpace.lg,
        96,
      ),
      children: [
        // 1. Audible Siren Strobe Banner when Emergency is Dispatched
        if (falcon.isSirenActive) ...[
          Container(
            padding: const EdgeInsets.all(AppSpace.md),
            decoration: BoxDecoration(
              color: falcon.sirenPulse
                  ? AppColors.danger(context)
                  : AppColors.warning(context),
              borderRadius: AppRadius.mdBorder,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.volume_up_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AUDIBLE DANGER SIREN ACTIVE • GPS LOCKED',
                        style: AppTypography.subtitle.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        falcon.lockedAddress,
                        style: AppTypography.caption.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                AppButton(
                  label: 'Mute Siren',
                  variant: AppButtonVariant.secondary,
                  onPressed: falcon.stopSiren,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.md),
        ],

        // 2. Main Falcon AI Voice Command Console
        AppCard(
          accentBorderColor: falcon.state == FalconAiState.dispatched
              ? AppColors.danger(context)
              : (falcon.state == FalconAiState.awake
                    ? AppColors.success(context)
                    : AppColors.primary(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: falcon.state == FalconAiState.dispatched
                          ? AppColors.danger(context)
                          : (falcon.state == FalconAiState.awake
                                ? AppColors.success(context)
                                : AppColors.primary(context)),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      falcon.state == FalconAiState.dispatched
                          ? Icons.sos_rounded
                          : Icons.radar_rounded,
                      color: AppColors.onPrimary(context),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: AppSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: AppSpace.sm,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'FALCON AI • DISASTER GUARDIAN',
                              style: AppTypography.subtitle.copyWith(
                                color: AppColors.textPrimary(context),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            StatusChip(
                              label: falcon.state == FalconAiState.standby
                                  ? 'STANDBY'
                                  : (falcon.state == FalconAiState.awake
                                        ? 'AWAKE & LISTENING'
                                        : 'SOS LOCKED'),
                              kind: falcon.state == FalconAiState.dispatched
                                  ? StatusChipKind.pending
                                  : (falcon.state == FalconAiState.awake
                                        ? StatusChipKind.resolved
                                        : StatusChipKind.info),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          falcon.statusHeadline,
                          style: AppTypography.bodyStrong.copyWith(
                            color: falcon.state == FalconAiState.dispatched
                                ? AppColors.danger(context)
                                : AppColors.primary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.lg),

              // Two-step Voice Workflow Guide + Instant Voice Command Triggers
              Text(
                'VOICE WAKE-WORD & EMERGENCY WORKFLOW (TAP OR SPEAK):',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpace.sm),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: '1. "Hey Falcon, wake up"',
                      icon: Icons.record_voice_over_rounded,
                      variant: falcon.state == FalconAiState.awake
                          ? AppButtonVariant.secondary
                          : AppButtonVariant.primary,
                      onPressed: () => falcon.wakeUpFalcon(),
                    ),
                  ),
                  const SizedBox(width: AppSpace.sm),
                  Expanded(
                    child: AppButton(
                      label: '2. "I\'m in a danger, report this"',
                      icon: Icons.warning_amber_rounded,
                      variant: AppButtonVariant.danger,
                      onPressed: () => falcon.triggerDangerEmergencyDispatch(
                        spokenText: "I'm in a danger, report this",
                        onEmergencyDispatched: (issue) =>
                            _handleDispatchedIssue(context, issue),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.md),

              // Live Microphone + Custom Voice Phrase Input
              Row(
                children: [
                  Semantics(
                    label: 'Toggle live microphone for Falcon AI',
                    button: true,
                    child: IconButton.filled(
                      onPressed: () => falcon.toggleMicrophone(
                        onEmergencyDispatched: (issue) =>
                            _handleDispatchedIssue(context, issue),
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: falcon.isMicListening
                            ? AppColors.danger(context)
                            : AppColors.primary(context),
                        foregroundColor: AppColors.onPrimary(context),
                      ),
                      icon: Icon(
                        falcon.isMicListening
                            ? Icons.mic_rounded
                            : Icons.mic_none_rounded,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpace.sm),
                  Expanded(
                    child: TextField(
                      controller: _customCommandCtrl,
                      onSubmitted: (val) {
                        falcon.processVoiceInput(
                          val,
                          onEmergencyDispatched: (issue) =>
                              _handleDispatchedIssue(context, issue),
                        );
                        _customCommandCtrl.clear();
                      },
                      decoration: const InputDecoration(
                        hintText:
                            'Say or type: "Hey Falcon wake up" or "I\'m in a danger report this"',
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpace.sm),
                  AppButton(
                    label: 'Speak',
                    onPressed: () {
                      falcon.processVoiceInput(
                        _customCommandCtrl.text,
                        onEmergencyDispatched: (issue) =>
                            _handleDispatchedIssue(context, issue),
                      );
                      _customCommandCtrl.clear();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.lg),

        // 3. Quick Disaster Scenario Buttons (Flood, Cyclone, Tsunami, Collapse)
        const SectionHeader(
          title: 'Instant Disaster Dispatch Presets',
          subtitle:
              'One-tap Falcon AI live GPS lock + emergency siren for severe hazards',
        ),
        const SizedBox(height: AppSpace.sm),
        Wrap(
          spacing: AppSpace.sm,
          runSpacing: AppSpace.sm,
          children: [
            _buildDisasterChip(
              context,
              falcon,
              label: '🌊 Flash Flood Trapped',
              speech:
                  "I'm in a danger, report this! Flash flood water rising rapidly!",
            ),
            _buildDisasterChip(
              context,
              falcon,
              label: '⚡ Live Fallen Power Line',
              speech:
                  "I'm in a danger, report this! High-voltage wire fallen on flooded road!",
            ),
            _buildDisasterChip(
              context,
              falcon,
              label: '🏚️ Coastal / Structural Collapse',
              speech:
                  "I'm in a danger, report this! Severe coastal wall collapse near homes!",
            ),
            _buildDisasterChip(
              context,
              falcon,
              label: '🚑 Medical / Accident SOS',
              speech:
                  "I'm in a danger, report this! Severe road accident requiring immediate rescue!",
            ),
          ],
        ),
        const SizedBox(height: AppSpace.lg),

        // 4. Live Falcon AI Conversation Transcript
        SectionHeader(
          title: 'Falcon AI Live Voice Log',
          subtitle: 'Spoken dialogue between Master and Falcon AI',
          actionLabel: 'Reset AI',
          onAction: falcon.resetToStandby,
        ),
        const SizedBox(height: AppSpace.sm),
        ...falcon.conversationLog.reversed.take(5).map((entry) {
          final isFalcon = entry.speaker == 'FALCON AI';
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpace.sm),
            child: AppCard(
              accentBorderColor: entry.isEmergency
                  ? AppColors.danger(context)
                  : (isFalcon
                        ? AppColors.primary(context)
                        : AppColors.outline(context)),
              padding: const EdgeInsets.all(AppSpace.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isFalcon
                        ? Icons.smart_toy_outlined
                        : Icons.record_voice_over_outlined,
                    size: 18,
                    color: entry.isEmergency
                        ? AppColors.danger(context)
                        : AppColors.primary(context),
                  ),
                  const SizedBox(width: AppSpace.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.speaker,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.primary(context),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          entry.text,
                          style: AppTypography.body.copyWith(
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: AppSpace.md),

        // 5. Falcon Shield+ Pro Monetization Upsell
        const PremiumUpsellBanner(
          title: 'Falcon Shield+ Pro: Auto Family SMS & Satellite SOS',
          subtitle:
              'Automatically send your live Falcon AI GPS pin & audio black-box recording to 5 family contacts and private rescue teams.',
          priceBadge: 'LKR 990 / MO',
          ctaLabel: 'Unlock Falcon Pro',
        ),
      ],
    );
  }

  Widget _buildDisasterChip(
    BuildContext context,
    FalconAiService falcon, {
    required String label,
    required String speech,
  }) {
    return ActionChip(
      label: Text(label),
      onPressed: () => falcon.triggerDangerEmergencyDispatch(
        spokenText: speech,
        onEmergencyDispatched: (issue) =>
            _handleDispatchedIssue(context, issue),
      ),
    );
  }
}

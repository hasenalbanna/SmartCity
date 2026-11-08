import 'package:flutter/material.dart';
import '../../models/community_issue.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

enum StatusChipKind { pending, inProgress, resolved, info, neutral }

class StatusChip extends StatelessWidget {
  final String label;
  final StatusChipKind kind;
  final IconData? icon;

  const StatusChip({
    super.key,
    required this.label,
    this.kind = StatusChipKind.neutral,
    this.icon,
  });

  factory StatusChip.fromIssueStatus(IssueStatus status) {
    switch (status) {
      case IssueStatus.pending:
        return const StatusChip(
          label: 'Pending',
          kind: StatusChipKind.pending,
          icon: Icons.error_outline_rounded,
        );
      case IssueStatus.inProgress:
        return const StatusChip(
          label: 'In Progress',
          kind: StatusChipKind.inProgress,
          icon: Icons.autorenew_rounded,
        );
      case IssueStatus.resolved:
        return const StatusChip(
          label: 'Resolved',
          kind: StatusChipKind.resolved,
          icon: Icons.check_circle_outline_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    Color fg;
    Color bg;
    IconData defaultIcon;

    switch (kind) {
      case StatusChipKind.pending:
        fg = AppColors.danger(context);
        bg = AppColors.dangerBg(context);
        defaultIcon = Icons.error_outline_rounded;
        break;
      case StatusChipKind.inProgress:
        fg = AppColors.warning(context);
        bg = AppColors.warningBg(context);
        defaultIcon = Icons.schedule_rounded;
        break;
      case StatusChipKind.resolved:
        fg = AppColors.success(context);
        bg = AppColors.successBg(context);
        defaultIcon = Icons.check_circle_outline_rounded;
        break;
      case StatusChipKind.info:
        fg = AppColors.info(context);
        bg = AppColors.infoBg(context);
        defaultIcon = Icons.info_outline_rounded;
        break;
      case StatusChipKind.neutral:
        fg = AppColors.textSecondary(context);
        bg = AppColors.surfaceMuted(context);
        defaultIcon = Icons.circle_outlined;
        break;
    }

    return Semantics(
      label: 'Status: $label',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.sm + 2,
          vertical: AppSpace.xs,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadius.pillBorder,
          border: Border.all(color: fg.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon ?? defaultIcon, size: 14, color: fg),
            const SizedBox(width: AppSpace.xs),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: fg,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

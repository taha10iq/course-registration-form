import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import 'glass_panel.dart';

class YesNoToggle extends StatelessWidget {
  const YesNoToggle({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final bool? value;
  final ValueChanged<bool> onChanged;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassPanel(
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 380;

          final headerText = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(subtitle, style: theme.textTheme.bodySmall),
            ],
          );

          final yesOption = _BinaryChoiceOption(
            label: 'نعم',
            icon: Icons.check_rounded,
            isSelected: value == true,
            accent: AppColors.neonGreen,
            onTap: () => onChanged(true),
          );
          final noOption = _BinaryChoiceOption(
            label: 'لا',
            icon: Icons.close_rounded,
            isSelected: value == false,
            accent: AppColors.neonPurple,
            onTap: () => onChanged(false),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isCompact)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeaderIcon(icon: icon),
                    const SizedBox(height: AppSpacing.sm),
                    headerText,
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeaderIcon(icon: icon),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: headerText),
                  ],
                ),
              const SizedBox(height: AppSpacing.md),
              if (isCompact)
                Column(
                  children: [
                    yesOption,
                    const SizedBox(height: AppSpacing.sm),
                    noOption,
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(child: yesOption),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: noOption),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({
    required this.icon,
  });

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.neonBlue.withValues(alpha: 0.12),
      ),
      child: Icon(icon, color: AppColors.neonBlue),
    );
  }
}

class _BinaryChoiceOption extends StatelessWidget {
  const _BinaryChoiceOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: isSelected
              ? [
                  accent.withValues(alpha: 0.28),
                  AppColors.surfaceElevated.withValues(alpha: 0.92),
                ]
              : [
                  AppColors.surface.withValues(alpha: 0.72),
                  AppColors.surfaceElevated.withValues(alpha: 0.72),
                ],
        ),
        border: Border.all(
          color: isSelected
              ? accent.withValues(alpha: 0.82)
              : AppColors.glassStroke.withValues(alpha: 0.32),
          width: isSelected ? 1.3 : 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected ? accent : AppColors.secondaryText,
                ),
                Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isSelected
                        ? AppColors.primaryText
                        : AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

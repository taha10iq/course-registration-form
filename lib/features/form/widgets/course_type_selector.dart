import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/whatsapp_launcher.dart';
import '../logic/course_type.dart';
import 'glass_panel.dart';

class CourseTypeSelector extends StatelessWidget {
  const CourseTypeSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final CourseType? value;
  final ValueChanged<CourseType> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassPanel(
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompactHeader = constraints.maxWidth < 390;
          final isStackedOptions = constraints.maxWidth < 390;

          final headerText = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('نوع الدورة', style: theme.textTheme.titleLarge),
              Text(
                'اختر النمط الأنسب لك ليتم تحديث السعر النهائي فورًا.',
                style: theme.textTheme.bodySmall,
              ),
            ],
          );

          final options = CourseType.values
              .map(
                (type) => _CourseOptionCard(
                  type: type,
                  isSelected: value == type,
                  onTap: () => onChanged(type),
                ),
              )
              .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isCompactHeader)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SelectorIcon(),
                    const SizedBox(height: AppSpacing.sm),
                    headerText,
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SelectorIcon(),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: headerText),
                  ],
                ),
              const SizedBox(height: AppSpacing.md),
              if (isStackedOptions)
                Column(
                  children: [
                    options[0],
                    const SizedBox(height: AppSpacing.sm),
                    options[1],
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(child: options[0]),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: options[1]),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SelectorIcon extends StatelessWidget {
  const _SelectorIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            AppColors.neonBlue.withValues(alpha: 0.24),
            AppColors.neonPurple.withValues(alpha: 0.24),
          ],
        ),
      ),
      child: const Icon(
        Icons.layers_rounded,
        color: AppColors.neonBlue,
      ),
    );
  }
}

class _CourseOptionCard extends StatelessWidget {
  const _CourseOptionCard({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  final CourseType type;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent =
        type == CourseType.inPerson ? AppColors.neonBlue : AppColors.neonGreen;
    final icon = type == CourseType.inPerson
        ? Icons.apartment_rounded
        : Icons.wifi_tethering_rounded;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isSelected
              ? [
                  accent.withValues(alpha: 0.24),
                  AppColors.surfaceElevated.withValues(alpha: 0.96),
                ]
              : [
                  AppColors.surface.withValues(alpha: 0.74),
                  AppColors.surfaceElevated.withValues(alpha: 0.74),
                ],
        ),
        border: Border.all(
          color: isSelected
              ? accent.withValues(alpha: 0.9)
              : AppColors.glassStroke.withValues(alpha: 0.34),
          width: isSelected ? 1.4 : 1.0,
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: accent.withValues(alpha: 0.22),
              blurRadius: 26,
              spreadRadius: -4,
              offset: const Offset(0, 16),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: accent.withValues(alpha: 0.18),
                      ),
                      child: Icon(icon, color: accent),
                    ),
                    const Spacer(),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? accent
                            : AppColors.surface.withValues(alpha: 0.6),
                        border: Border.all(
                          color: isSelected
                              ? accent
                              : AppColors.glassStroke.withValues(alpha: 0.42),
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: AppColors.background,
                            )
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(type.label, style: theme.textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(type.description, style: theme.textTheme.bodySmall),
                const SizedBox(height: AppSpacing.md),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: accent.withValues(alpha: 0.12),
                      border: Border.all(color: accent.withValues(alpha: 0.28)),
                    ),
                    child: Text(
                      WhatsAppLauncher.formatPrice(type.price),
                      style:
                          theme.textTheme.labelLarge?.copyWith(color: accent),
                    ),
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

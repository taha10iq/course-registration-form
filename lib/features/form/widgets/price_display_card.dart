import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/whatsapp_launcher.dart';
import '../logic/course_type.dart';
import 'glass_panel.dart';

class PriceDisplayCard extends StatelessWidget {
  const PriceDisplayCard({
    super.key,
    required this.courseType,
  });

  final CourseType? courseType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = switch (courseType) {
      CourseType.inPerson => AppColors.neonBlue,
      CourseType.online => AppColors.neonGreen,
      null => AppColors.neonPurple,
    };

    final content = AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOutCubic,
      child: courseType == null
          ? Column(
              key: const ValueKey('empty-price'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('السعر النهائي', style: theme.textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(
                  'اختر نوع الدورة ليظهر المبلغ النهائي هنا بشكل فوري وواضح.',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            )
          : Column(
              key: ValueKey(courseType!.name),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('السعر النهائي', style: theme.textTheme.titleLarge),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    WhatsAppLauncher.formatPrice(courseType!.price),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: accent,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  courseType == CourseType.online
                      ? 'النمط الإلكتروني أوفر بمقدار ${WhatsAppLauncher.formatPrice(AppConstants.inPersonCoursePrice - AppConstants.onlineCoursePrice)} مقارنة بالحضوري.'
                      : 'اختيارك الحضوري يمنحك تفاعلًا مباشرًا داخل القاعة التدريبية.',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
    );

    return GlassPanel(
      padding: const EdgeInsets.all(20),
      borderColor: accent.withValues(alpha: 0.58),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          accent.withValues(alpha: 0.12),
          AppColors.surfaceElevated.withValues(alpha: 0.95),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 360;

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PriceIcon(accent: accent),
                const SizedBox(height: AppSpacing.md),
                content,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PriceIcon(accent: accent),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: content),
            ],
          );
        },
      ),
    );
  }
}

class _PriceIcon extends StatelessWidget {
  const _PriceIcon({
    required this.accent,
  });

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: accent.withValues(alpha: 0.16),
      ),
      child: Icon(Icons.payments_rounded, color: accent),
    );
  }
}

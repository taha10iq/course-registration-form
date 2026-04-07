import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';

class SubmitButton extends StatelessWidget {
  const SubmitButton({
    super.key,
    required this.isEnabled,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isEnabled;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      opacity: isEnabled ? 1 : 0.72,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: isEnabled
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.neonBlue,
                    AppColors.neonPurple,
                    AppColors.neonGreen,
                  ],
                )
              : LinearGradient(
                  colors: [
                    AppColors.surfaceElevated.withValues(alpha: 0.94),
                    AppColors.surface.withValues(alpha: 0.94),
                  ],
                ),
          boxShadow: [
            if (isEnabled)
              BoxShadow(
                color: (isLoading ? AppColors.neonGreen : AppColors.neonBlue)
                    .withValues(alpha: 0.34),
                blurRadius: 28,
                spreadRadius: -6,
                offset: const Offset(0, 16),
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isEnabled && !isLoading ? onPressed : null,
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              height: AppSpacing.ctaHeight,
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  switchInCurve: Curves.easeOutCubic,
                  child: isLoading
                      ? FittedBox(
                          key: const ValueKey('loading'),
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.background,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                'جاري تجهيز الرسالة...',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: AppColors.background,
                                ),
                              ),
                            ],
                          ),
                        )
                      : FittedBox(
                          key: const ValueKey('idle'),
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.north_west_rounded,
                                color: isEnabled
                                    ? AppColors.background
                                    : AppColors.secondaryText,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                'إرسال الطلب إلى واتساب',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: isEnabled
                                      ? AppColors.background
                                      : AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

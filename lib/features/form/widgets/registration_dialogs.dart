import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/whatsapp_launcher.dart';
import '../logic/course_type.dart';
import 'glass_panel.dart';

class SubmissionConfirmationDialog extends StatelessWidget {
  const SubmissionConfirmationDialog({
    super.key,
    required this.courseType,
  });

  final CourseType courseType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _DialogShell(
      maxWidth: 540,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _DialogHeader(
              title: 'تأكيد طلب الاشتراك',
              subtitle:
                  'راجع نوع الدورة والمبلغ قبل متابعة إجراءات الحجز والتحويل.',
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _SummaryTile(
                  label: 'نوع الدورة',
                  value: courseType.label,
                  icon: Icons.school_rounded,
                  accentColor: AppColors.neonBlue,
                ),
                _SummaryTile(
                  label: 'المبلغ المطلوب',
                  value: WhatsAppLauncher.formatPrice(courseType.price),
                  icon: Icons.payments_rounded,
                  accentColor: AppColors.neonGreen,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'بتأكيدك لهذه الخطوة سيتم تثبيت طلب الاشتراك في الدورة المحددة، ثم ستظهر لك بيانات التحويل عبر MasterCard لإكمال إجراءات الحجز قبل متابعة الإرسال إلى WhatsApp.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.secondaryText,
                height: 1.7,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _ActionButtonsRow(
              secondaryLabel: 'رجوع',
              primaryLabel: 'تأكيد الإرسال',
              primaryIcon: Icons.check_circle_rounded,
              onSecondaryPressed: () => Navigator.of(context).pop(false),
              onPrimaryPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentDetailsDialog extends StatefulWidget {
  const PaymentDetailsDialog({
    super.key,
    required this.courseType,
  });

  final CourseType courseType;

  @override
  State<PaymentDetailsDialog> createState() => _PaymentDetailsDialogState();
}

class _PaymentDetailsDialogState extends State<PaymentDetailsDialog> {
  late int _remainingSeconds;
  Timer? _timer;
  bool _hasCopiedAccountNumber = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = AppConstants.paymentButtonDelay.inSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remainingSeconds <= 1) {
        setState(() => _remainingSeconds = 0);
        timer.cancel();
        return;
      }

      setState(() => _remainingSeconds -= 1);
    });
  }

  Future<void> _copyAccountNumber() async {
    await Clipboard.setData(
      const ClipboardData(text: AppConstants.masterCardAccountNumber),
    );
    if (!mounted) {
      return;
    }

    setState(() => _hasCopiedAccountNumber = true);

    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('تم نسخ رقم الحساب بنجاح.'),
        ),
      );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canFinish = _remainingSeconds == 0;

    return _DialogShell(
      maxWidth: 560,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _DialogHeader(
              title: 'بيانات التحويل عبر MasterCard',
              subtitle:
                  'حوّل المبلغ المطلوب إلى رقم الحساب التالي، ثم اضغط تم لمتابعة تثبيت الطلب.',
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _SummaryTile(
                  label: 'نوع الدورة',
                  value: widget.courseType.label,
                  icon: Icons.auto_stories_rounded,
                  accentColor: AppColors.neonBlue,
                ),
                _SummaryTile(
                  label: 'المبلغ',
                  value: WhatsAppLauncher.formatPrice(widget.courseType.price),
                  icon: Icons.account_balance_wallet_rounded,
                  accentColor: AppColors.neonGreen,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'يرجى استخدام بطاقة MasterCard لإرسال قيمة الدورة إلى رقم الحساب المعروض أدناه. الرقم قابل للنسخ المباشر لتسهيل عملية التحويل.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.secondaryText,
                height: 1.7,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _AccountNumberCard(
              accountNumber: AppConstants.masterCardAccountNumber,
              hasCopied: _hasCopiedAccountNumber,
              onCopy: _copyAccountNumber,
            ),
            const SizedBox(height: AppSpacing.md),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 240),
              child: canFinish
                  ? Container(
                      key: const ValueKey('payment-ready'),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: AppColors.neonGreen.withValues(alpha: 0.12),
                        border: Border.all(
                          color: AppColors.neonGreen.withValues(alpha: 0.34),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.verified_rounded,
                            color: AppColors.neonGreen,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'يمكنك الآن الضغط على زر تم لمتابعة إرسال الطلب.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.primaryText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      key: ValueKey(_remainingSeconds),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color:
                            AppColors.surfaceElevated.withValues(alpha: 0.74),
                        border: Border.all(
                          color: AppColors.glassStroke.withValues(alpha: 0.28),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'سيظهر زر تم بعد $_remainingSeconds ثوانٍ حتى تتمكن من مراجعة رقم الحساب ونسخه.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (canFinish)
              _ActionButtonsRow(
                secondaryLabel: 'إلغاء',
                primaryLabel: 'تم',
                primaryIcon: Icons.done_all_rounded,
                onSecondaryPressed: () => Navigator.of(context).pop(false),
                onPrimaryPressed: () => Navigator.of(context).pop(true),
              )
            else
              SizedBox(
                width: double.infinity,
                child: _SecondaryActionButton(
                  label: 'إلغاء',
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CourseInfoDialog extends StatelessWidget {
  const CourseInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const stages = <_CourseStage>[
      _CourseStage(
        step: '01',
        title: 'أساسيات الحاسوب',
        description:
            'نبدأ بتثبيت المهارات الرقمية الأساسية، مثل التعامل مع نظام التشغيل، تنظيم الملفات، واستخدام الأدوات اليومية بثقة عملية.',
        icon: Icons.computer_rounded,
        accentColor: AppColors.neonBlue,
      ),
      _CourseStage(
        step: '02',
        title: 'أساسيات البرمجة',
        description:
            'ننتقل إلى بناء التفكير البرمجي بصورة مبسطة تشمل المتغيرات، الشروط، الحلقات، والخطوات المنهجية لحل المشكلات.',
        icon: Icons.integration_instructions_rounded,
        accentColor: AppColors.neonPurple,
      ),
      _CourseStage(
        step: '03',
        title: 'قواعد البيانات',
        description:
            'نعرّفك على هيكلة البيانات، الجداول، العلاقات، والاستعلامات الأساسية التي تشكل قاعدة أي مشروع برمجي منظم.',
        icon: Icons.storage_rounded,
        accentColor: AppColors.neonGreen,
      ),
      _CourseStage(
        step: '04',
        title: 'لغة Python',
        description:
            'بعد التأسيس نبدأ باللغة المحورية في الكورس، وهي Python، مع تدريب تطبيقي مباشر ومهام عملية تربط التعلم بالاستخدام الواقعي.',
        icon: Icons.code_rounded,
        accentColor: AppColors.neonPink,
      ),
    ];

    return _DialogShell(
      maxWidth: 920,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _DialogHeader(
              title: 'معلومات الكورس',
              subtitle:
                  'مسار تدريبي متدرج صُمم لينقل المتدرب من الأساسيات التقنية إلى التطبيق البرمجي العملي بصورة واضحة ومنظمة.',
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  colors: [
                    AppColors.neonBlue.withValues(alpha: 0.18),
                    AppColors.neonPurple.withValues(alpha: 0.18),
                  ],
                ),
                border: Border.all(
                  color: AppColors.glassStroke.withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                'المخطط الشبكي للمحاضرات',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.primaryText,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final itemWidth = width >= 860
                    ? (width - (AppSpacing.sm * 3)) / 4
                    : width >= 580
                        ? (width - AppSpacing.sm) / 2
                        : width;

                return Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: stages
                      .map(
                        (stage) => SizedBox(
                          width: itemWidth,
                          child: _CourseStageCard(stage: stage),
                        ),
                      )
                      .toList(),
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            GlassPanel(
              padding: const EdgeInsets.all(AppSpacing.md),
              borderColor: AppColors.neonBlue.withValues(alpha: 0.28),
              gradient: LinearGradient(
                colors: [
                  AppColors.surfaceElevated.withValues(alpha: 0.92),
                  AppColors.surface.withValues(alpha: 0.92),
                ],
              ),
              child: Text(
                'يُعلن خلال المحاضرات عن لغات وتقنيات إضافية تُطرح بصورة انتقائية وفقًا لمستوى المجموعة واتجاهات سوق العمل، لضمان أن يبقى المحتوى مواكبًا وذا قيمة تطبيقية حقيقية.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.secondaryText,
                  height: 1.7,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'الفائدة من الدورة',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            GlassPanel(
              padding: const EdgeInsets.all(AppSpacing.lg),
              borderColor: AppColors.neonGreen.withValues(alpha: 0.32),
              gradient: LinearGradient(
                colors: [
                  AppColors.neonGreen.withValues(alpha: 0.08),
                  AppColors.surface.withValues(alpha: 0.96),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'صُممت هذه الدورة لتمنحك مسارًا عمليًا واضحًا نحو المجال التقني، لذلك نعتمد أسلوبًا تدريبيًا يوازن بين التأسيس السليم والإنجاز التطبيقي الموجّه لسوق العمل.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.primaryText,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _BenefitRow(
                    text:
                        'نبتعد عن الإغراق في الشروحات النظرية والأكاديمية غير المنتجة، ونركّز بدلًا من ذلك على الفهم الذي يقود إلى التطبيق.',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const _BenefitRow(
                    text:
                        'نقدّم أدوات وحلولًا برمجية فعالة يمكن توظيفها مباشرة في التعلّم الذاتي، بناء المشاريع، والانطلاق نحو فرص العمل الحر أو المؤسسي.',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const _BenefitRow(
                    text:
                        'نفتح أمامك طريقًا أوضح إلى سوق العمل عبر محتوى تدريجي، أمثلة واقعية، ونظرة عملية إلى ما يحتاجه المبتدئ ليبدأ بثقة.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 180,
                child: _PrimaryActionButton(
                  label: 'إغلاق',
                  icon: Icons.done_rounded,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogShell extends StatelessWidget {
  const _DialogShell({
    required this.child,
    required this.maxWidth,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppSpacing.lg),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: MediaQuery.sizeOf(context).height * 0.88,
        ),
        child: GlassPanel(
          padding: const EdgeInsets.all(AppSpacing.lg),
          borderColor: AppColors.glassStroke.withValues(alpha: 0.48),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.surfaceElevated.withValues(alpha: 0.96),
              AppColors.surface.withValues(alpha: 0.94),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.secondaryText,
            height: 1.7,
          ),
        ),
      ],
    );
  }
}

class _ActionButtonsRow extends StatelessWidget {
  const _ActionButtonsRow({
    required this.secondaryLabel,
    required this.primaryLabel,
    required this.primaryIcon,
    required this.onSecondaryPressed,
    required this.onPrimaryPressed,
  });

  final String secondaryLabel;
  final String primaryLabel;
  final IconData primaryIcon;
  final VoidCallback onSecondaryPressed;
  final VoidCallback onPrimaryPressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 360) {
          return Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: _PrimaryActionButton(
                  label: primaryLabel,
                  icon: primaryIcon,
                  onPressed: onPrimaryPressed,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: _SecondaryActionButton(
                  label: secondaryLabel,
                  onPressed: onSecondaryPressed,
                ),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: _SecondaryActionButton(
                label: secondaryLabel,
                onPressed: onSecondaryPressed,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _PrimaryActionButton(
                label: primaryLabel,
                icon: primaryIcon,
                onPressed: onPrimaryPressed,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 180, maxWidth: 280),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: AppColors.surface.withValues(alpha: 0.7),
          border: Border.all(color: accentColor.withValues(alpha: 0.26)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: 0.14),
              ),
              child: Icon(icon, color: accentColor),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountNumberCard extends StatelessWidget {
  const _AccountNumberCard({
    required this.accountNumber,
    required this.hasCopied,
    required this.onCopy,
  });

  final String accountNumber;
  final bool hasCopied;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final copyButton = TextButton.icon(
      onPressed: onCopy,
      icon: Icon(
        hasCopied ? Icons.check_rounded : Icons.copy_rounded,
        color: hasCopied ? AppColors.neonGreen : AppColors.secondaryText,
      ),
      label: Text(
        hasCopied ? 'تم النسخ' : 'نسخ الرقم',
        style: theme.textTheme.labelLarge?.copyWith(
          color: hasCopied ? AppColors.neonGreen : AppColors.secondaryText,
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.neonBlue.withValues(alpha: 0.12),
            AppColors.neonPurple.withValues(alpha: 0.1),
            AppColors.surface.withValues(alpha: 0.96),
          ],
        ),
        border: Border.all(
          color: AppColors.neonBlue.withValues(alpha: 0.34),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonBlue.withValues(alpha: 0.1),
            blurRadius: 24,
            spreadRadius: -10,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 360) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'رقم الحساب',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    copyButton,
                  ],
                );
              }

              return Row(
                children: [
                  Text(
                    'رقم الحساب',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  copyButton,
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SelectableText(
              accountNumber,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: AppColors.primaryText,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.2,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'يمكنك نسخ الرقم أعلاه أو تحديده يدويًا لإتمام التحويل عبر بطاقة MasterCard.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.secondaryText,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: AppColors.accentGradient,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.xs,
              runSpacing: 4,
              children: [
                Icon(icon, color: AppColors.background),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.background,
                    fontWeight: FontWeight.w800,
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

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        side: BorderSide(
          color: AppColors.glassStroke.withValues(alpha: 0.45),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: theme.textTheme.titleMedium?.copyWith(
          color: AppColors.primaryText,
        ),
      ),
    );
  }
}

class _CourseStage {
  const _CourseStage({
    required this.step,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
  });

  final String step;
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
}

class _CourseStageCard extends StatelessWidget {
  const _CourseStageCard({
    required this.stage,
  });

  final _CourseStage stage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: AppColors.surface.withValues(alpha: 0.72),
        border: Border.all(color: stage.accentColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: stage.accentColor.withValues(alpha: 0.14),
                ),
                child: Icon(stage.icon, color: stage.accentColor),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: stage.accentColor.withValues(alpha: 0.12),
                ),
                child: Text(
                  stage.step,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: stage.accentColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            stage.title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColors.primaryText,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            stage.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.secondaryText,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.neonGreen.withValues(alpha: 0.14),
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 16,
            color: AppColors.neonGreen,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.secondaryText,
              height: 1.7,
            ),
          ),
        ),
      ],
    );
  }
}

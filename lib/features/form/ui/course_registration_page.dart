import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../logic/registration_form_controller.dart';
import '../widgets/animated_gradient_background.dart';
import '../widgets/course_type_selector.dart';
import '../widgets/futuristic_text_field.dart';
import '../widgets/glass_panel.dart';
import '../widgets/price_display_card.dart';
import '../widgets/registration_dialogs.dart';
import '../widgets/section_heading.dart';
import '../widgets/submit_button.dart';
import '../widgets/yes_no_toggle.dart';

class CourseRegistrationPage extends StatefulWidget {
  const CourseRegistrationPage({super.key});

  @override
  State<CourseRegistrationPage> createState() => _CourseRegistrationPageState();
}

class _CourseRegistrationPageState extends State<CourseRegistrationPage> {
  late final RegistrationFormController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RegistrationFormController();
  }

  Future<void> _handleSubmit() async {
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).clearSnackBars();

    final validationResult = _controller.validateSubmission();
    if (validationResult != SubmissionResult.success) {
      _showSubmissionFeedback(validationResult);
      return;
    }

    final selectedCourseType = _controller.selectedCourseType;
    if (selectedCourseType == null) {
      _showSubmissionFeedback(SubmissionResult.invalid);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => SubmissionConfirmationDialog(
        courseType: selectedCourseType,
      ),
    );
    if (!mounted || confirmed != true) {
      return;
    }

    final paymentConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => PaymentDetailsDialog(
        courseType: selectedCourseType,
      ),
    );
    if (!mounted || paymentConfirmed != true) {
      return;
    }

    final result = await _controller.submit();
    if (!mounted || result == SubmissionResult.success) {
      return;
    }

    _showSubmissionFeedback(result);
  }

  void _showSubmissionFeedback(SubmissionResult result) {
    final message = switch (result) {
      SubmissionResult.invalid =>
        'أكمل جميع الحقول المطلوبة وحدد نوع الدورة قبل متابعة الإرسال.',
      SubmissionResult.launchFailed =>
        'تعذر فتح WhatsApp على هذا الجهاز. تأكد من توفره ثم حاول مرة أخرى.',
      SubmissionResult.success => '',
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.start),
      ),
    );
  }

  Future<void> _showCourseInfoDialog() {
    return showDialog<void>(
      context: context,
      builder: (context) => const CourseInfoDialog(),
    );
  }

  Future<void> _launchExternalLink(String url) async {
    final launched = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );

    if (!mounted || launched) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تعذر فتح الرابط الآن. حاول مرة أخرى.'),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: AnimatedGradientBackground(
          child: SafeArea(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppConstants.maxContentWidth,
                      ),
                      child: Form(
                        key: _controller.formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildProfileShowcase(context),
                            const SizedBox(height: AppSpacing.sectionGap),
                            Text(
                              'استمارة تسجيل الدورات التقنية',
                              style: theme.textTheme.displaySmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'أكمل بياناتك بدقة، واطلع على تفاصيل الكورس، ثم أرسل طلبك من نهاية الاستمارة.',
                              style: theme.textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.sectionGap),
                            _buildCourseInfoButton(context),
                            const SizedBox(height: AppSpacing.sectionGap),
                            const SectionHeading(
                              eyebrow: 'البيانات',
                              title: 'معلومات المتقدم',
                              subtitle:
                                  'املأ البيانات الأساسية بدقة ليتم تجهيز طلب التسجيل بصورة مرتبة وواضحة قبل الإرسال.',
                            ),
                            const SizedBox(height: AppSpacing.md),
                            FuturisticTextField(
                              controller: _controller.fullNameController,
                              label: 'الاسم الكامل',
                              hint: 'مثال: محمد علي حسن',
                              icon: Icons.badge_rounded,
                              validator: _controller.validateFullName,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            FuturisticTextField(
                              controller: _controller.phoneController,
                              label: 'رقم الهاتف',
                              hint: '07xxxxxxxxx',
                              icon: Icons.phone_in_talk_rounded,
                              validator: _controller.validatePhoneNumber,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(11),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            FuturisticTextField(
                              controller: _controller.ageController,
                              label: 'العمر',
                              hint: 'اكتب العمر بالأرقام',
                              icon: Icons.timelapse_rounded,
                              validator: _controller.validateAge,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(2),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            FuturisticTextField(
                              controller: _controller.specializationController,
                              label: 'التخصص',
                              hint: 'مثال: هندسة برمجيات / إعدادية / محاسبة',
                              icon: Icons.psychology_alt_rounded,
                              validator: _controller.validateSpecialization,
                              textInputAction: TextInputAction.done,
                            ),
                            const SizedBox(height: AppSpacing.sectionGap),
                            const SectionHeading(
                              eyebrow: 'الجاهزية',
                              title: 'جاهزية المتدرب',
                              subtitle:
                                  'اختياراتك هنا تساعد على فهم مستوى الجاهزية قبل تثبيت الطلب وإرساله إلى WhatsApp.',
                            ),
                            const SizedBox(height: AppSpacing.md),
                            YesNoToggle(
                              title: 'هل لديك خبرة بسيطة بالحاسوب؟',
                              subtitle:
                                  'اختر الإجابة الأقرب إلى واقعك حتى تكون المتابعة أدق.',
                              value: _controller.hasBasicComputerExperience,
                              onChanged: _controller.updateBasicExperience,
                              icon: Icons.memory_rounded,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            YesNoToggle(
                              title: 'هل لديك كمبيوتر شخصي أو لابتوب؟',
                              subtitle:
                                  'يساعدنا هذا على معرفة مدى الجاهزية العملية للتطبيق.',
                              value: _controller.hasPersonalComputer,
                              onChanged: _controller.updatePersonalComputer,
                              icon: Icons.laptop_chromebook_rounded,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            CourseTypeSelector(
                              value: _controller.selectedCourseType,
                              onChanged: _controller.updateCourseType,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            PriceDisplayCard(
                              courseType: _controller.selectedCourseType,
                            ),
                            const SizedBox(height: AppSpacing.sectionGap),
                            _buildSubmissionSection(context),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileShowcase(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: GlassPanel(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          borderColor: AppColors.neonBlue.withValues(alpha: 0.34),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.neonBlue.withValues(alpha: 0.08),
              AppColors.surface.withValues(alpha: 0.95),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: AppColors.neonBlue.withValues(alpha: 0.42),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonBlue.withValues(alpha: 0.16),
                      blurRadius: 24,
                      spreadRadius: -8,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: Image.asset(
                    AppConstants.profileImageAsset,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'طه سعد',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'محتوى برمجي عملي يختصر عليك الطريق نحو المهارة وسوق العمل.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.secondaryText,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                AppConstants.socialHandle,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.neonGreen,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  _SocialLinkButton(
                    logoAsset: AppConstants.instagramLogoAsset,
                    label: 'Instagram',
                    accentColor: AppColors.neonPink,
                    onTap: () => _launchExternalLink(AppConstants.instagramUrl),
                  ),
                  _SocialLinkButton(
                    logoAsset: AppConstants.tiktokLogoAsset,
                    label: 'TikTok',
                    accentColor: AppColors.neonBlue,
                    onTap: () => _launchExternalLink(AppConstants.tiktokUrl),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseInfoButton(BuildContext context) {
    final theme = Theme.of(context);

    return GlassPanel(
      padding: EdgeInsets.zero,
      borderColor: AppColors.neonBlue.withValues(alpha: 0.34),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.neonBlue.withValues(alpha: 0.08),
          AppColors.surface.withValues(alpha: 0.94),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          onTap: _showCourseInfoDialog,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 430;

                final titleBlock = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'معلومات الكورس',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'اطلع على مسار المحاضرات، محاور الدورة، والفائدة العملية منها قبل المتابعة.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondaryText,
                        height: 1.6,
                      ),
                    ),
                  ],
                );

                if (isCompact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.neonBlue.withValues(alpha: 0.14),
                        ),
                        child: const Icon(
                          Icons.grid_view_rounded,
                          color: AppColors.neonBlue,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      titleBlock,
                      const SizedBox(height: AppSpacing.sm),
                      const Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Icon(
                          Icons.open_in_new_rounded,
                          color: AppColors.neonGreen,
                        ),
                      ),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.neonBlue.withValues(alpha: 0.14),
                      ),
                      child: const Icon(
                        Icons.grid_view_rounded,
                        color: AppColors.neonBlue,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: titleBlock),
                    const SizedBox(width: AppSpacing.sm),
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Icon(
                        Icons.open_in_new_rounded,
                        color: AppColors.neonGreen,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmissionSection(BuildContext context) {
    final theme = Theme.of(context);
    final isSubmitting = _controller.isSubmitting;
    final isReady = _controller.isReadyToSubmit;

    return GlassPanel(
      padding: const EdgeInsets.all(18),
      borderColor: (isReady ? AppColors.neonGreen : AppColors.glassStroke)
          .withValues(alpha: 0.58),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isSubmitting
                    ? Icons.sync_rounded
                    : isReady
                        ? Icons.verified_rounded
                        : Icons.info_outline_rounded,
                color: isSubmitting
                    ? AppColors.neonBlue
                    : isReady
                        ? AppColors.neonGreen
                        : AppColors.secondaryText,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  isSubmitting
                      ? 'جارٍ تجهيز الطلب النهائي وفتح WhatsApp...'
                      : _controller.completionHint,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SubmitButton(
            isEnabled: isReady,
            isLoading: isSubmitting,
            onPressed: _handleSubmit,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'لن يتم حفظ أي بيانات داخل التطبيق. بعد تأكيد الإرسال ستظهر لك بيانات التحويل أولًا، ثم يتم فتح WhatsApp برسالة عربية جاهزة.',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SocialLinkButton extends StatelessWidget {
  const _SocialLinkButton({
    required this.logoAsset,
    required this.label,
    required this.accentColor,
    required this.onTap,
  });

  final String logoAsset;
  final String label;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 140),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accentColor.withValues(alpha: 0.18),
              AppColors.surfaceElevated.withValues(alpha: 0.94),
            ],
          ),
          border: Border.all(color: accentColor.withValues(alpha: 0.32)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: accentColor.withValues(alpha: 0.16),
                    ),
                    child: Image.asset(logoAsset, fit: BoxFit.contain),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.arrow_outward_rounded,
                    size: 18,
                    color: accentColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

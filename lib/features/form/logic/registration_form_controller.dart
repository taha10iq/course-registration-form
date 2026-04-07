import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/whatsapp_launcher.dart';
import 'course_type.dart';

enum SubmissionResult {
  success,
  invalid,
  launchFailed,
}

class RegistrationFormController extends ChangeNotifier {
  RegistrationFormController() {
    for (final controller in _controllers) {
      controller.addListener(_onTextChanged);
    }
  }

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController specializationController =
      TextEditingController();

  bool? hasBasicComputerExperience;
  bool? hasPersonalComputer;
  CourseType? selectedCourseType;
  bool isSubmitting = false;

  List<TextEditingController> get _controllers => [
        fullNameController,
        phoneController,
        ageController,
        specializationController,
      ];

  String get fullName => fullNameController.text.trim();
  String get phoneNumber => phoneController.text.trim();
  String get age => ageController.text.trim();
  String get specialization => specializationController.text.trim();

  void _onTextChanged() => notifyListeners();

  String? validateFullName(String? value) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) {
      return 'يرجى إدخال الاسم الكامل.';
    }
    if (normalized.split(RegExp(r'\s+')).length < 2) {
      return 'أدخل اسمًا واضحًا لا يقل عن مقطعين.';
    }
    return null;
  }

  String? validatePhoneNumber(String? value) {
    final digitsOnly = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.isEmpty) {
      return 'يرجى إدخال رقم الهاتف.';
    }
    if (!RegExp(r'^07\d{9}$').hasMatch(digitsOnly)) {
      return 'أدخل رقمًا عراقيًا صحيحًا يبدأ بـ 07.';
    }
    return null;
  }

  String? validateAge(String? value) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) {
      return 'يرجى إدخال العمر.';
    }

    final parsedAge = int.tryParse(normalized);
    if (parsedAge == null) {
      return 'العمر يجب أن يكون رقمًا فقط.';
    }
    if (parsedAge < 10 || parsedAge > 80) {
      return 'يرجى إدخال عمر بين 10 و80 سنة.';
    }
    return null;
  }

  String? validateSpecialization(String? value) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) {
      return 'يرجى إدخال التخصص.';
    }
    if (normalized.length < 2) {
      return 'اكتب تخصصًا واضحًا.';
    }
    return null;
  }

  bool get isReadyToSubmit =>
      validateFullName(fullName) == null &&
      validatePhoneNumber(phoneNumber) == null &&
      validateAge(age) == null &&
      validateSpecialization(specialization) == null &&
      hasBasicComputerExperience != null &&
      hasPersonalComputer != null &&
      selectedCourseType != null &&
      !isSubmitting;

  String get completionHint {
    if (validateFullName(fullName) != null) {
      return 'أضف الاسم الكامل أولًا.';
    }
    if (validatePhoneNumber(phoneNumber) != null) {
      return 'أدخل رقم هاتف عراقي صالح للتواصل.';
    }
    if (validateAge(age) != null) {
      return 'اكتب العمر بشكل رقمي صحيح.';
    }
    if (validateSpecialization(specialization) != null) {
      return 'حدّد التخصص الدراسي أو المهني.';
    }
    if (hasBasicComputerExperience == null) {
      return 'اختر ما إذا كانت لديك خبرة بسيطة بالحاسوب.';
    }
    if (hasPersonalComputer == null) {
      return 'حدّد ما إذا كنت تمتلك جهاز كمبيوتر أو لابتوب.';
    }
    if (selectedCourseType == null) {
      return 'اختر نوع الدورة ليظهر السعر النهائي.';
    }
    return 'النموذج جاهز للإرسال إلى واتساب.';
  }

  void updateBasicExperience(bool value) {
    hasBasicComputerExperience = value;
    notifyListeners();
  }

  void updatePersonalComputer(bool value) {
    hasPersonalComputer = value;
    notifyListeners();
  }

  void updateCourseType(CourseType value) {
    selectedCourseType = value;
    notifyListeners();
  }

  SubmissionResult validateSubmission() {
    if (isSubmitting) {
      return SubmissionResult.invalid;
    }

    final textFieldsValid = formKey.currentState?.validate() ?? false;
    if (!textFieldsValid || !isReadyToSubmit) {
      notifyListeners();
      return SubmissionResult.invalid;
    }

    return SubmissionResult.success;
  }

  Future<SubmissionResult> submit() async {
    final validationResult = validateSubmission();
    if (validationResult != SubmissionResult.success) {
      return validationResult;
    }

    isSubmitting = true;
    notifyListeners();

    try {
      await Future<void>.delayed(AppConstants.submitLoadingDuration);
      await WhatsAppLauncher.launchRegistration(
        fullName: fullName,
        phoneNumber: phoneNumber,
        age: age,
        specialization: specialization,
        hasComputerExperience: hasBasicComputerExperience!,
        hasDevice: hasPersonalComputer!,
        courseType: selectedCourseType!,
      );
      return SubmissionResult.success;
    } catch (_) {
      return SubmissionResult.launchFailed;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.removeListener(_onTextChanged);
      controller.dispose();
    }
    super.dispose();
  }
}

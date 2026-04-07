import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../features/form/logic/course_type.dart';
import '../constants/app_constants.dart';

abstract final class WhatsAppLauncher {
  static final NumberFormat _priceFormat = NumberFormat.decimalPattern('en');

  static Future<void> launchRegistration({
    required String fullName,
    required String phoneNumber,
    required String age,
    required String specialization,
    required bool hasComputerExperience,
    required bool hasDevice,
    required CourseType courseType,
  }) async {
    final message = buildRegistrationMessage(
      fullName: fullName,
      phoneNumber: phoneNumber,
      age: age,
      specialization: specialization,
      hasComputerExperience: hasComputerExperience,
      hasDevice: hasDevice,
      courseType: courseType,
    );

    final uri = Uri.https(
      'wa.me',
      '/${normalizeNumber(AppConstants.whatsappRawNumber)}',
      {'text': message},
    );

    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      throw Exception('whatsapp_launch_failed');
    }
  }

  static String buildRegistrationMessage({
    required String fullName,
    required String phoneNumber,
    required String age,
    required String specialization,
    required bool hasComputerExperience,
    required bool hasDevice,
    required CourseType courseType,
  }) {
    return <String>[
      'طلب تسجيل دورة جديد',
      '',
      'الاسم: $fullName',
      'رقم الهاتف: $phoneNumber',
      'العمر: $age',
      'التخصص: $specialization',
      'لديه خبرة بالحاسوب: ${hasComputerExperience ? 'نعم' : 'لا'}',
      'يمتلك جهاز: ${hasDevice ? 'نعم' : 'لا'}',
      'نوع الدورة: ${courseType.label}',
      'السعر: ${formatPrice(courseType.price)}',
    ].join('\n');
  }

  static String formatPrice(int value) {
    return '${_priceFormat.format(value)} دينار عراقي';
  }

  static String normalizeNumber(String rawNumber) {
    final digitsOnly = rawNumber.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.startsWith(AppConstants.iraqCountryCode)) {
      return digitsOnly;
    }
    if (digitsOnly.startsWith('0')) {
      return '${AppConstants.iraqCountryCode}${digitsOnly.substring(1)}';
    }
    return '${AppConstants.iraqCountryCode}$digitsOnly';
  }
}

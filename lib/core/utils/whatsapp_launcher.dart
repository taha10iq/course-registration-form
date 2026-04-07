import 'package:flutter/foundation.dart';
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

    for (final uri in buildLaunchUris(message: message)) {
      final launched = await _launchUri(uri);
      if (launched) {
        return;
      }
    }

    throw Exception('whatsapp_launch_failed');
  }

  @visibleForTesting
  static List<Uri> buildLaunchUris({
    required String message,
    bool? isWeb,
    TargetPlatform? platform,
  }) {
    final normalizedNumber = normalizeNumber(AppConstants.whatsappRawNumber);
    final runningOnWeb = isWeb ?? kIsWeb;
    final currentPlatform = platform ?? defaultTargetPlatform;

    final deepLink = Uri(
      scheme: 'whatsapp',
      host: 'send',
      queryParameters: {
        'phone': normalizedNumber,
        'text': message,
      },
    );
    final apiLink = Uri.https(
      'api.whatsapp.com',
      '/send',
      {
        'phone': normalizedNumber,
        'text': message,
      },
    );
    final shortLink = Uri.https(
      'wa.me',
      '/$normalizedNumber',
      {'text': message},
    );

    if (runningOnWeb) {
      return [apiLink, shortLink];
    }

    return switch (currentPlatform) {
      TargetPlatform.android || TargetPlatform.iOS => [
          deepLink,
          apiLink,
          shortLink,
        ],
      _ => [apiLink, shortLink],
    };
  }

  static Future<bool> _launchUri(Uri uri) {
    if (kIsWeb) {
      return launchUrl(
        uri,
        webOnlyWindowName: '_self',
      );
    }

    return launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
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

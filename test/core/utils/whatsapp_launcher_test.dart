import 'package:course_registration_form/core/utils/whatsapp_launcher.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WhatsAppLauncher', () {
    test('normalizes Iraqi phone numbers to the international format', () {
      expect(
        WhatsAppLauncher.normalizeNumber('07852486974'),
        '9647852486974',
      );
      expect(
        WhatsAppLauncher.normalizeNumber('9647852486974'),
        '9647852486974',
      );
    });

    test('prioritizes the native WhatsApp deep link on mobile', () {
      final uris = WhatsAppLauncher.buildLaunchUris(
        message: 'hello',
        isWeb: false,
        platform: TargetPlatform.android,
      );

      expect(uris, hasLength(3));
      expect(uris.first.scheme, 'whatsapp');
      expect(uris.first.host, 'send');
      expect(uris.first.queryParameters['phone'], '9647852486974');
      expect(uris.first.queryParameters['text'], 'hello');
    });

    test('uses browser-safe WhatsApp urls on web', () {
      final uris = WhatsAppLauncher.buildLaunchUris(
        message: 'hello',
        isWeb: true,
        platform: TargetPlatform.android,
      );

      expect(uris, hasLength(2));
      expect(uris.first.scheme, 'https');
      expect(uris.first.host, 'api.whatsapp.com');
      expect(uris.first.path, '/send');
      expect(uris.every((uri) => uri.scheme != 'whatsapp'), isTrue);
    });
  });
}

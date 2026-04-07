import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:course_registration_form/features/form/widgets/course_type_selector.dart';
import 'package:course_registration_form/features/form/widgets/submit_button.dart';
import 'package:course_registration_form/features/form/widgets/yes_no_toggle.dart';
import 'package:course_registration_form/main.dart';

void main() {
  testWidgets('renders the form with a fixed submit button', (
    tester,
  ) async {
    await tester.pumpWidget(const CourseRegistrationApp());
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(4));
    expect(find.byType(SubmitButton), findsOneWidget);
    expect(find.text('معلومات الكورس'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'محمد علي حسن');
    await tester.enterText(find.byType(TextFormField).at(1), '07712345678');
    await tester.enterText(find.byType(TextFormField).at(2), '22');
    await tester.enterText(
      find.byType(TextFormField).at(3),
      'هندسة برمجيات',
    );

    await tester.ensureVisible(find.byType(YesNoToggle).first);
    await tester.tap(
      find
          .descendant(
            of: find.byType(YesNoToggle).first,
            matching: find.byType(InkWell),
          )
          .first,
    );
    await tester.pump(const Duration(milliseconds: 300));

    await tester.ensureVisible(find.byType(YesNoToggle).last);
    await tester.tap(
      find
          .descendant(
            of: find.byType(YesNoToggle).last,
            matching: find.byType(InkWell),
          )
          .first,
    );
    await tester.pump(const Duration(milliseconds: 300));

    await tester.ensureVisible(find.byType(CourseTypeSelector));
    await tester.tap(
      find
          .descendant(
            of: find.byType(CourseTypeSelector),
            matching: find.byType(InkWell),
          )
          .first,
    );
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(SubmitButton), findsOneWidget);
  });
}

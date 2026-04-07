import '../../../core/constants/app_constants.dart';

enum CourseType {
  inPerson(
    label: 'حضوري',
    description: 'تفاعل مباشر داخل القاعة التدريبية.',
    price: AppConstants.inPersonCoursePrice,
  ),
  online(
    label: 'الكتروني',
    description: 'حضور مرن عن بُعد من أي مكان.',
    price: AppConstants.onlineCoursePrice,
  );

  const CourseType({
    required this.label,
    required this.description,
    required this.price,
  });

  final String label;
  final String description;
  final int price;
}

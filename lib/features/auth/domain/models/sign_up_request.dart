import '../../../../core/domain/business_category.dart';

class SignUpRequest {
  const SignUpRequest({
    required this.category,
    required this.establishmentName,
    required this.managerName,
    required this.phone,
    required this.password,
  });

  final BusinessCategory category;
  final String establishmentName;
  final String managerName;
  final String phone;
  final String password;
}

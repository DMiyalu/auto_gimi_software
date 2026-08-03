class SignUpRequest {
  const SignUpRequest({
    required this.fullName,
    required this.phone,
    required this.password,
  });

  final String fullName;
  final String phone;
  final String password;
}

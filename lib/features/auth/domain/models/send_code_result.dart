class SendCodeResult {
  const SendCodeResult({
    required this.expiresInSeconds,
    this.debugCode,
  });

  final int expiresInSeconds;
  final String? debugCode;
}

class PasswordResetItems {
  final String title;
  final String Function(String? dynamicValue)? description;
  final String? staticDescription;

  const PasswordResetItems({
    required this.title,
    this.description,
    this.staticDescription,
  }) : assert(
         description != null || staticDescription != null,
         'Either description or staticDescription must be provided',
       );

  /// Get the description with optional dynamic value
  String getDescription([String? dynamicValue]) {
    if (description != null) {
      return description!(dynamicValue);
    }
    return staticDescription!;
  }

  static List<PasswordResetItems> items = [
    PasswordResetItems(
      title: 'REQUEST NEW\nPASSWORD',
      staticDescription: 'Enter the email address connected to your account.',
    ),
    PasswordResetItems(
      title: 'ENTER OTP',
      description: (email) => email != null && email.isNotEmpty
          ? "We sent a code to $email"
          : "We sent a code to your email",
    ),
    PasswordResetItems(
      title: 'RESET PASSWORD',
      staticDescription: "Make sure it's safe and secure",
    ),
  ];
}

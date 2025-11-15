class SignupItems {
  final String title;
  final String Function(String? dynamicValue)? description;
  final String? staticDescription;

  const SignupItems({
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

  static List<SignupItems> items = [
    const SignupItems(
      title: "What's your legal\nname?",
      staticDescription: 'Add your full legal details',
    ),
    const SignupItems(
      title: "Whats your email\naddress?",
      staticDescription: "Enter the email you'd like to link to your account",
    ),
    const SignupItems(
      title: 'Create a\npassword',
      staticDescription: "Make sure it's safe and secure",
    ),
    SignupItems(
      title: 'Confirm your\nemail',
      description: (email) => email != null && email.isNotEmpty
          ? 'We sent a code to $email'
          : 'We sent a code to your email',
    ),
    const SignupItems(
      title: 'What is your date of\nbirth?',
      staticDescription: 'You must be 16 or older to use Savvy Bee',
    ),
    const SignupItems(
      title: 'What country do\nyou live in?',
      staticDescription: 'Regulations may vary depending on where you live',
    ),
  ];
}

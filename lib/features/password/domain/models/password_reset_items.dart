class PasswordResetItems {
  final String title;
  final String description;

  const PasswordResetItems({required this.title, required this.description});

  static List<PasswordResetItems> items = [
    const PasswordResetItems(
      title: 'REQUEST NEW\nPASSWORD',
      description: 'Enter the email address connected to your account.',
    ),
    const PasswordResetItems(
      title: 'ENTER OTP',
      description: "We sent a code to jonsnow11@gmail.com",
    ),
    const PasswordResetItems(
      title: 'RESET PASSWORD',
      description: 'Create new password',
    ),
    const PasswordResetItems(
      title: 'CONFIRM YOUR\nNEMAIL',
      description: 'We sent a code to jonsnow11@gmail.com',
    ),
    const PasswordResetItems(
      title: 'DATE OF BIRTH',
      description: 'You must be 16 or older to use Savvy Bee',
    ),
    const PasswordResetItems(
      title: 'WHICH COUNTRY\nDO YOU LIVE IN?',
      description: 'Regulations may vary depending on where you live',
    ),
  ];
}

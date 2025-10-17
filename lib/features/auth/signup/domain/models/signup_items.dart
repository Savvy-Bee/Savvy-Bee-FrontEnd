class SignupItems {
  final String title;
  final String description;

  const SignupItems({required this.title, required this.description});

  static List<SignupItems> items = [
    const SignupItems(
      title: 'NAME',
      description: 'Add your full legal details',
    ),
    const SignupItems(
      title: 'EMAIL',
      description: "Enter the email you'd like to link to your account",
    ),
    const SignupItems(title: 'PASSWORD', description: 'Create a safe password'),
    const SignupItems(
      title: 'CONFIRM YOUR\nNEMAIL',
      description: 'We sent a code to jonsnow11@gmail.com',
    ),
    const SignupItems(
      title: 'DATE OF BIRTH',
      description: 'You must be 16 or older to use Savvy Bee',
    ),
    const SignupItems(
      title: 'WHICH COUNTRY\nDO YOU LIVE IN?',
      description: 'Regulations may vary depending on where you live',
    ),
  ];
}

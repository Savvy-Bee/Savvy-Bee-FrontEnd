class Avatars {
  static const String _basePath = 'assets/images/illustrations/avatars';

  // Bloom avatars
  static const String bloom1 = '$_basePath/bloom-1.png';
  static const String bloom2 = '$_basePath/bloom-2.png';
  static const String bloom3 = '$_basePath/bloom-3.png';
  static const String bloom4 = '$_basePath/bloom-4.png';

  static const List<String> bloomAvatars = [bloom1, bloom2, bloom3, bloom4];

  // Boo avatars
  static const String boo1 = '$_basePath/boo-1.png';
  static const String boo2 = '$_basePath/boo-2.png';

  static const List<String> booAvatars = [boo1, boo2];

  // Dash avatars
  static const String dash1 = '$_basePath/dash-1.png';
  static const String dash2 = '$_basePath/dash-2.png';
  static const String dash3 = '$_basePath/dash-3.png';
  static const String dash4 = '$_basePath/dash-4.png';

  static const List<String> dashAvatars = [dash1, dash2, dash3, dash4];

  // Loki avatars
  static const String loki1 = '$_basePath/loki-1.png';
  static const String loki2 = '$_basePath/loki-2.png';
  static const String loki3 = '$_basePath/loki-3.png';
  static const String loki4 = '$_basePath/loki-4.png';

  static const List<String> lokiAvatars = [loki1, loki2, loki3, loki4];

  // Luna avatars
  static const String luna1 = '$_basePath/luna-1.png';
  static const String luna2 = '$_basePath/luna-2.png';
  static const String luna3 = '$_basePath/luna-3.png';
  static const String luna4 = '$_basePath/luna-4.png';
  static const String luna5 = '$_basePath/luna-5.png';
  static const String luna6 = '$_basePath/luna-6.png';

  static const List<String> lunaAvatars = [
    luna1,
    luna2,
    luna3,
    luna4,
    luna5,
    luna6,
  ];

  // Penny avatars
  static const String penny1 = '$_basePath/penny-1.png';
  static const String penny2 = '$_basePath/penny-2.png';
  static const String penny3 = '$_basePath/penny-3.png';

  static const List<String> pennyAvatars = [penny1, penny2, penny3];

  // Susu avatars
  static const String susu1 = '$_basePath/susu-1.png';
  static const String susu2 = '$_basePath/susu-2.png';

  static const List<String> susuAvatars = [susu1, susu2];

  // Get all avatars
  static const List<String> avatars = [
    ...bloomAvatars,
    ...booAvatars,
    ...dashAvatars,
    ...lokiAvatars,
    ...lunaAvatars,
    ...pennyAvatars,
    ...susuAvatars,
  ];

  // Get avatar by index
  static String getAvatar(String name) {
    switch (name.toLowerCase()) {
      case 'bloom1':
        return bloom1;
      case 'bloom2':
        return bloom2;
      case 'bloom3':
        return bloom3;
      case 'bloom4':
        return bloom4;
      case 'boo1':
        return boo1;
      case 'boo2':
        return boo2;
      case 'dash1':
        return dash1;
      case 'dash2':
        return dash2;
      case 'dash3':
        return dash3;
      case 'dash4':
        return dash4;
      case 'loki1':
        return loki1;
      case 'loki2':
        return loki2;
      case 'loki3':
        return loki3;
      case 'loki4':
        return loki4;
      case 'luna1':
        return luna1;
      case 'luna2':
        return luna2;
      case 'luna3':
        return luna3;
      case 'luna4':
        return luna4;
      case 'luna5':
        return luna5;
      case 'luna6':
        return luna6;
      case 'penny1':
        return penny1;
      case 'penny2':
        return penny2;
      case 'penny3':
        return penny3;
      case 'susu1':
        return susu1;
      case 'susu2':
        return susu2;
      default:
        throw ArgumentError('Unknown avatar name: $name');
    }
  }
}

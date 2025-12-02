enum AuthMethodType {
  internetBanking('internet_banking'),
  mobileBanking('mobile_banking'),
  accountNumber('account_number'),
  pwa('pwa'),
  providusIbs('providus_ibs'),
  pwb('pwb'),
  whatsapp('whatsapp'),
  unknown('unknown');

  final String value;
  const AuthMethodType(this.value);

  static AuthMethodType fromString(String value) {
    return AuthMethodType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => AuthMethodType.unknown,
    );
  }
}

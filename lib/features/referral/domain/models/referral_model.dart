class ReferralData {
  final String username;
  final int flower;
  final List<Referral> referrals;

  ReferralData({
    required this.username,
    required this.flower,
    required this.referrals,
  });

  factory ReferralData.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return ReferralData(
      username: data['Username'] as String? ?? '',
      flower: data['Flower'] as int? ?? 0,
      referrals: (data['refferrals'] as List<dynamic>? ?? [])
          .map((e) => Referral.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Referral {
  final String id;
  final String username;
  final String profilePhoto;

  Referral({
    required this.id,
    required this.username,
    required this.profilePhoto,
  });

  factory Referral.fromJson(Map<String, dynamic> json) {
    return Referral(
      id: json['_id'] as String? ?? '',
      username: json['Username'] as String? ?? '',
      profilePhoto: json['ProfilePhoto'] as String? ?? '',
    );
  }
}
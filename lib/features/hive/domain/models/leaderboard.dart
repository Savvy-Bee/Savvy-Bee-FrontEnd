class LeaderboardData {
  final String league;
  final List<LeaderboardEntry> hive;

  LeaderboardData({required this.league, required this.hive});

  factory LeaderboardData.fromJson(Map<String, dynamic> json) {
    return LeaderboardData(
      league: json['league'] as String,
      hive: (json['hive'] as List<dynamic>)
          .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'league': league, 'hive': hive.map((e) => e.toJson()).toList()};
  }
}

class LeaderboardEntry {
  final String id;
  final LeaderboardUser? userID;
  final int flowers;
  final int honeyDrop;

  LeaderboardEntry({
    required this.id,
    this.userID,
    required this.flowers,
    required this.honeyDrop,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      id: json['_id'] as String,
      userID: json['UserID'] != null
          ? LeaderboardUser.fromJson(json['UserID'] as Map<String, dynamic>)
          : null,
      flowers: json['Flowers'] as int,
      honeyDrop: json['HoneyDrop'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'UserID': userID?.toJson(),
      'Flowers': flowers,
      'HoneyDrop': honeyDrop,
    };
  }
}

class LeaderboardUser {
  final String id;
  final String username;
  final String firstName;
  final String lastName;
  final String profilePhoto;

  LeaderboardUser({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.profilePhoto,
  });

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) {
    return LeaderboardUser(
      id: json['_id'] as String,
      username: json['Username'] as String,
      firstName: json['FirstName'] as String,
      lastName: json['LastName'] as String,
      profilePhoto: json['ProfilePhoto'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'Username': username,
      'FirstName': firstName,
      'LastName': lastName,
      'ProfilePhoto': profilePhoto,
    };
  }
}

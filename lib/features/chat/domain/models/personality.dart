class Personality {
  final String id;
  final String name;
  final String description;
  final String characteristics;
  final List<String> tone;
  final String dashboardBias;
  final String? image;

  const Personality({
    required this.id,
    required this.name,
    required this.description,
    required this.characteristics,
    required this.tone,
    required this.dashboardBias,
    this.image,
  });

  factory Personality.fromJson(Map<String, dynamic> json) {
    return Personality(
      id: json['ID'] as String,
      name: json['Name'] as String,
      description: json['Description'] as String,
      characteristics: json['Characteristics'] as String,
      tone: List<String>.from(json['Tone'] as List),
      dashboardBias: json['Dashboard_Bias'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Name': name,
      'Description': description,
      'Characteristics': characteristics,
      'Tone': tone,
      'Dashboard_Bias': dashboardBias,
    };
  }
}

/// AI Strictness levels
enum AIStrictness {
  strict('Strict'),
  moderate('Moderate'),
  lenient('Lenient');

  final String value;
  const AIStrictness(this.value);
}

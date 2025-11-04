class UserSettings {
  final String defaultCourtName;
  final double defaultCourtRate;
  final double defaultShuttlecockPrice;
  final bool divideCourtEqually;

  UserSettings({
    required this.defaultCourtName,
    required this.defaultCourtRate,
    required this.defaultShuttlecockPrice,
    required this.divideCourtEqually,
  });

  UserSettings copyWith({
    String? defaultCourtName,
    double? defaultCourtRate,
    double? defaultShuttlecockPrice,
    bool? divideCourtEqually,
  }) {
    return UserSettings(
      defaultCourtName: defaultCourtName ?? this.defaultCourtName,
      defaultCourtRate: defaultCourtRate ?? this.defaultCourtRate,
      defaultShuttlecockPrice: defaultShuttlecockPrice ?? this.defaultShuttlecockPrice,
      divideCourtEqually: divideCourtEqually ?? this.divideCourtEqually,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'defaultCourtName': defaultCourtName,
      'defaultCourtRate': defaultCourtRate,
      'defaultShuttlecockPrice': defaultShuttlecockPrice,
      'divideCourtEqually': divideCourtEqually,
    };
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      defaultCourtName: json['defaultCourtName'] as String,
      defaultCourtRate: (json['defaultCourtRate'] as num).toDouble(),
      defaultShuttlecockPrice: (json['defaultShuttlecockPrice'] as num).toDouble(),
      divideCourtEqually: json['divideCourtEqually'] as bool,
    );
  }

  static UserSettings getDefault() {
    return UserSettings(
      defaultCourtName: 'Main Court',
      defaultCourtRate: 200.0,
      defaultShuttlecockPrice: 25.0,
      divideCourtEqually: true,
    );
  }
}
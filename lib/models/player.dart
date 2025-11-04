class Player {
  final String id;
  final String nickname;
  final String fullName;
  final String contact;
  final String email;
  final String address;
  final String remarks;
  final int levelStart;
  final int levelEnd;

  Player({
    required this.id,
    required this.nickname,
    required this.fullName,
    required this.contact,
    required this.email,
    required this.address,
    required this.remarks,
    required this.levelStart,
    required this.levelEnd,
  });

  Player copyWith({
    String? id,
    String? nickname,
    String? fullName,
    String? contact,
    String? email,
    String? address,
    String? remarks,
    int? levelStart,
    int? levelEnd,
  }) {
    return Player(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      fullName: fullName ?? this.fullName,
      contact: contact ?? this.contact,
      email: email ?? this.email,
      address: address ?? this.address,
      remarks: remarks ?? this.remarks,
      levelStart: levelStart ?? this.levelStart,
      levelEnd: levelEnd ?? this.levelEnd,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'fullName': fullName,
      'contact': contact,
      'email': email,
      'address': address,
      'remarks': remarks,
      'levelStart': levelStart,
      'levelEnd': levelEnd,
    };
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      nickname: json['nickname'] as String,
      fullName: json['fullName'] as String,
      contact: json['contact'] as String,
      email: json['email'] as String,
      address: json['address'] as String,
      remarks: json['remarks'] as String,
      levelStart: json['levelStart'] as int,
      levelEnd: json['levelEnd'] as int,
    );
  }
}

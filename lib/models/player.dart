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
}

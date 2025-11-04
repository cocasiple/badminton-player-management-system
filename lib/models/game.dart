class Game {
  final String id;
  final String title;
  final String courtName;
  final List<GameSchedule> schedules;
  final double courtRate;
  final double shuttlecockPrice;
  final bool divideCourtEqually;
  final List<String> playerIds;
  final DateTime createdAt;

  Game({
    required this.id,
    required this.title,
    required this.courtName,
    required this.schedules,
    required this.courtRate,
    required this.shuttlecockPrice,
    required this.divideCourtEqually,
    required this.playerIds,
    required this.createdAt,
  });

  Game copyWith({
    String? id,
    String? title,
    String? courtName,
    List<GameSchedule>? schedules,
    double? courtRate,
    double? shuttlecockPrice,
    bool? divideCourtEqually,
    List<String>? playerIds,
    DateTime? createdAt,
  }) {
    return Game(
      id: id ?? this.id,
      title: title ?? this.title,
      courtName: courtName ?? this.courtName,
      schedules: schedules ?? this.schedules,
      courtRate: courtRate ?? this.courtRate,
      shuttlecockPrice: shuttlecockPrice ?? this.shuttlecockPrice,
      divideCourtEqually: divideCourtEqually ?? this.divideCourtEqually,
      playerIds: playerIds ?? this.playerIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get displayTitle {
    if (title.isNotEmpty) return title;
    if (schedules.isNotEmpty) {
      final firstSchedule = schedules.first;
      return '${firstSchedule.courtNumber} - ${_formatDateTime(firstSchedule.startTime)}';
    }
    return 'Untitled Game';
  }

  double get totalCost {
    double total = 0.0;
    
    for (final schedule in schedules) {
      final hours = schedule.duration.inMinutes / 60.0;
      total += courtRate * hours;
    }
    
    // Add shuttlecock costs (assuming 1 shuttlecock per hour of play)
    final totalHours = schedules.fold<double>(0.0, (sum, schedule) => 
        sum + (schedule.duration.inMinutes / 60.0));
    total += shuttlecockPrice * totalHours.ceil();
    
    return total;
  }

  double get costPerPlayer {
    if (playerIds.isEmpty) return 0.0;
    return divideCourtEqually ? totalCost / playerIds.length : totalCost;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'courtName': courtName,
      'schedules': schedules.map((s) => s.toJson()).toList(),
      'courtRate': courtRate,
      'shuttlecockPrice': shuttlecockPrice,
      'divideCourtEqually': divideCourtEqually,
      'playerIds': playerIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'] as String,
      title: json['title'] as String,
      courtName: json['courtName'] as String,
      schedules: (json['schedules'] as List)
          .map((s) => GameSchedule.fromJson(s))
          .toList(),
      courtRate: (json['courtRate'] as num).toDouble(),
      shuttlecockPrice: (json['shuttlecockPrice'] as num).toDouble(),
      divideCourtEqually: json['divideCourtEqually'] as bool,
      playerIds: List<String>.from(json['playerIds']),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class GameSchedule {
  final String courtNumber;
  final DateTime startTime;
  final DateTime endTime;

  GameSchedule({
    required this.courtNumber,
    required this.startTime,
    required this.endTime,
  });

  Duration get duration => endTime.difference(startTime);

  String get timeRange {
    return '${_formatTime(startTime)} - ${_formatTime(endTime)}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() {
    return {
      'courtNumber': courtNumber,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
    };
  }

  factory GameSchedule.fromJson(Map<String, dynamic> json) {
    return GameSchedule(
      courtNumber: json['courtNumber'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
    );
  }
}
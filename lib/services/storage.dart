import '../models/player.dart';
import 'dart:math';

class PlayerStorage {
  final List<Player> _players = [];

  List<Player> get all => List.unmodifiable(_players);

  String _genId() => DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(9999).toString();

  void add(Player p) {
    final withId = p.copyWith(id: p.id.isEmpty ? _genId() : p.id);
    _players.add(withId);
  }

  void update(Player p) {
    final idx = _players.indexWhere((e) => e.id == p.id);
    if (idx != -1) _players[idx] = p;
  }

  void remove(String id) {
    _players.removeWhere((e) => e.id == id);
  }

  Player? getById(String id) {
    try {
      return _players.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}

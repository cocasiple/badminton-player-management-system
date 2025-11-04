import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player.dart';
import '../models/game.dart';
import '../models/user_settings.dart';
import 'dart:math';

class AppStorage {
  static const String _playersKey = 'players';
  static const String _gamesKey = 'games';
  static const String _settingsKey = 'user_settings';

  final List<Player> _players = [];
  final List<Game> _games = [];
  UserSettings _userSettings = UserSettings.getDefault();

  List<Player> get players => List.unmodifiable(_players);
  List<Game> get games => List.unmodifiable(_games);
  UserSettings get userSettings => _userSettings;

  String _genId() => DateTime.now().millisecondsSinceEpoch.toString() + 
      Random().nextInt(9999).toString();

  // Initialize with sample data or load from storage
  Future<void> initialize() async {
    await loadFromStorage();
    
    // If no data exists, add sample players
    if (_players.isEmpty) {
      _addSamplePlayers();
    }
  }

  void _addSamplePlayers() {
    final samplePlayers = <Player>[
      Player(
        id: '',
        nickname: 'Ace',
        fullName: 'Miguel Santos',
        contact: '09171234567',
        email: 'miguel.santos@example.com',
        address: '45 Rizal Ave, Cebu',
        remarks: 'Left-handed attacker',
        levelStart: 3,
        levelEnd: 8,
      ),
      Player(
        id: '',
        nickname: 'SmashPro',
        fullName: 'Jonah Reyes',
        contact: '09179876543',
        email: 'jonah.reyes@example.com',
        address: '12 Mabini St, Davao',
        remarks: 'Powerful smash',
        levelStart: 9,
        levelEnd: 14,
      ),
      Player(
        id: '',
        nickname: 'NetMaster',
        fullName: 'Isabella Cruz',
        contact: '09201239876',
        email: 'isabella.cruz@example.com',
        address: '88 Lopez Rd, Iloilo',
        remarks: 'Excellent net play',
        levelStart: 6,
        levelEnd: 9,
      ),
      Player(
        id: '',
        nickname: 'Dart',
        fullName: 'Rafael Gomez',
        contact: '09172223344',
        email: 'rafael.gomez@example.com',
        address: '3 Mango Lane, Bohol',
        remarks: 'Quick footwork',
        levelStart: 0,
        levelEnd: 4,
      ),
      Player(
        id: '',
        nickname: 'SpinKing',
        fullName: 'Carlos Rivera',
        contact: '09173334455',
        email: 'carlos.rivera@example.com',
        address: '7 Pine St, Quezon City',
        remarks: 'Great racket spin',
        levelStart: 12,
        levelEnd: 18,
      ),
      Player(
        id: '',
        nickname: 'Runner',
        fullName: 'Jasmine Lee',
        contact: '09174445566',
        email: 'jasmine.lee@example.com',
        address: '21 Oak Blvd, Batangas',
        remarks: 'Endurance specialist',
        levelStart: 6,
        levelEnd: 10,
      ),
    ];

    for (final player in samplePlayers) {
      addPlayer(player);
    }
  }

  // Player operations
  void addPlayer(Player player) {
    final withId = player.copyWith(id: player.id.isEmpty ? _genId() : player.id);
    _players.add(withId);
    saveToStorage();
  }

  void updatePlayer(Player player) {
    final idx = _players.indexWhere((e) => e.id == player.id);
    if (idx != -1) {
      _players[idx] = player;
      saveToStorage();
    }
  }

  void removePlayer(String id) {
    _players.removeWhere((e) => e.id == id);
    saveToStorage();
  }

  Player? getPlayerById(String id) {
    try {
      return _players.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  // Game operations
  void addGame(Game game) {
    final withId = game.copyWith(id: game.id.isEmpty ? _genId() : game.id);
    _games.add(withId);
    saveToStorage();
  }

  void updateGame(Game game) {
    final idx = _games.indexWhere((e) => e.id == game.id);
    if (idx != -1) {
      _games[idx] = game;
      saveToStorage();
    }
  }

  void removeGame(String id) {
    _games.removeWhere((e) => e.id == id);
    saveToStorage();
  }

  Game? getGameById(String id) {
    try {
      return _games.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  // Settings operations
  void updateUserSettings(UserSettings settings) {
    _userSettings = settings;
    saveToStorage();
  }

  // Storage operations
  Future<void> saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save players
      final playersJson = _players.map((p) => p.toJson()).toList();
      await prefs.setString(_playersKey, jsonEncode(playersJson));
      
      // Save games
      final gamesJson = _games.map((g) => g.toJson()).toList();
      await prefs.setString(_gamesKey, jsonEncode(gamesJson));
      
      // Save settings
      await prefs.setString(_settingsKey, jsonEncode(_userSettings.toJson()));
    } catch (e) {
      // Handle save error silently in production
      print('Error saving data: $e');
    }
  }

  Future<void> loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load players
      final playersData = prefs.getString(_playersKey);
      if (playersData != null) {
        final List<dynamic> playersJson = jsonDecode(playersData);
        _players.clear();
        _players.addAll(playersJson.map((json) => Player.fromJson(json)));
      }
      
      // Load games
      final gamesData = prefs.getString(_gamesKey);
      if (gamesData != null) {
        final List<dynamic> gamesJson = jsonDecode(gamesData);
        _games.clear();
        _games.addAll(gamesJson.map((json) => Game.fromJson(json)));
      }
      
      // Load settings
      final settingsData = prefs.getString(_settingsKey);
      if (settingsData != null) {
        final Map<String, dynamic> settingsJson = jsonDecode(settingsData);
        _userSettings = UserSettings.fromJson(settingsJson);
      }
    } catch (e) {
      // Handle load error silently in production
      print('Error loading data: $e');
    }
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_playersKey);
    await prefs.remove(_gamesKey);
    await prefs.remove(_settingsKey);
    
    _players.clear();
    _games.clear();
    _userSettings = UserSettings.getDefault();
  }
}
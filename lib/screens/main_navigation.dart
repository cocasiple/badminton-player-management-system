import 'package:flutter/material.dart';
import '../models/user_settings.dart';
import '../models/game.dart';
import '../models/player.dart';
import '../services/app_storage.dart';
import '../services/storage.dart';
import 'all_players.dart';
import 'all_games.dart';
import 'user_settings.dart';

class MainNavigationScreen extends StatefulWidget {
  final AppStorage appStorage;

  const MainNavigationScreen({super.key, required this.appStorage});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  late PlayerStorage _playerStorage;

  @override
  void initState() {
    super.initState();
    // Create a wrapper that uses the app storage
    _playerStorage = PlayerStorageWrapper(widget.appStorage);
  }

  void _onGameAdded(Game game) {
    widget.appStorage.addGame(game);
    setState(() {});
  }

  void _onGameUpdated(Game game) {
    widget.appStorage.updateGame(game);
    setState(() {});
  }

  void _onGameDeleted(String gameId) {
    widget.appStorage.removeGame(gameId);
    setState(() {});
  }

  void _onTabTapped(int index) async {
    if (index == 2) {
      // Navigate to settings screen and wait for result
      final result = await Navigator.push<UserSettings>(
        context,
        MaterialPageRoute(
          builder: (context) => UserSettingsScreen(currentSettings: widget.appStorage.userSettings),
        ),
      );
      if (result != null) {
        widget.appStorage.updateUserSettings(result);
        setState(() {});
      }
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  Widget _getCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return AllPlayersScreen(storage: _playerStorage);
      case 1:
        return AllGamesScreen(
          games: widget.appStorage.games,
          userSettings: widget.appStorage.userSettings,
          appStorage: widget.appStorage,
          onGameAdded: _onGameAdded,
          onGameUpdated: _onGameUpdated,
          onGameDeleted: _onGameDeleted,
        );
      default:
        return AllPlayersScreen(storage: _playerStorage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getCurrentScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Players',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_tennis),
            label: 'Games',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// Wrapper to make AppStorage compatible with existing PlayerStorage interface
class PlayerStorageWrapper implements PlayerStorage {
  final AppStorage _appStorage;

  PlayerStorageWrapper(this._appStorage);

  @override
  List<Player> get all => _appStorage.players;

  @override
  void add(Player p) => _appStorage.addPlayer(p);

  @override
  void update(Player p) => _appStorage.updatePlayer(p);

  @override
  void remove(String id) => _appStorage.removePlayer(id);

  @override
  Player? getById(String id) => _appStorage.getPlayerById(id);
}
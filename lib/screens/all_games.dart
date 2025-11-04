import 'package:flutter/material.dart';
import '../models/game.dart';
import '../models/user_settings.dart';
import '../services/app_storage.dart';
import 'add_game.dart';
import 'view_game.dart';

class AllGamesScreen extends StatefulWidget {
  final List<Game> games;
  final UserSettings userSettings;
  final AppStorage appStorage;
  final Function(Game) onGameAdded;
  final Function(Game) onGameUpdated;
  final Function(String) onGameDeleted;

  const AllGamesScreen({
    super.key,
    required this.games,
    required this.userSettings,
    required this.appStorage,
    required this.onGameAdded,
    required this.onGameUpdated,
    required this.onGameDeleted,
  });

  @override
  State<AllGamesScreen> createState() => _AllGamesScreenState();
}

class _AllGamesScreenState extends State<AllGamesScreen> {
  final _searchController = TextEditingController();
  List<Game> _filteredGames = [];

  @override
  void initState() {
    super.initState();
    _filteredGames = widget.games;
    _searchController.addListener(_filterGames);
  }

  @override
  void didUpdateWidget(AllGamesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.games != widget.games) {
      _filteredGames = widget.games;
      _filterGames();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterGames() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredGames = widget.games;
      } else {
        _filteredGames = widget.games.where((game) {
          return game.displayTitle.toLowerCase().contains(query) ||
              game.courtName.toLowerCase().contains(query) ||
              _formatGameDate(game).toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  String _formatGameDate(Game game) {
    if (game.schedules.isEmpty) return '';
    final firstSchedule = game.schedules.first;
    return '${firstSchedule.startTime.day}/${firstSchedule.startTime.month}/${firstSchedule.startTime.year}';
  }

  void _addNewGame() async {
    final result = await Navigator.push<Game>(
      context,
      MaterialPageRoute(
        builder: (context) => AddGameScreen(
          userSettings: widget.userSettings,
          appStorage: widget.appStorage,
        ),
      ),
    );
    
    if (result != null) {
      widget.onGameAdded(result);
      setState(() {
        _filteredGames = widget.games;
      });
    }
  }

  void _viewGame(Game game) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => ViewGameScreen(
          game: game,
          userSettings: widget.userSettings,
          appStorage: widget.appStorage,
          onGameUpdated: widget.onGameUpdated,
          onGameDeleted: widget.onGameDeleted,
        ),
      ),
    );
    
    if (result != null) {
      setState(() {
        _filteredGames = widget.games;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'All Games',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search games by name or date...',
                prefixIcon: Icon(Icons.search, color: Colors.blue),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          // Games List
          Expanded(
            child: _filteredGames.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sports_tennis,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.games.isEmpty 
                              ? 'No games yet\nTap the + button to add your first game!'
                              : 'No games match your search',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredGames.length,
                    itemBuilder: (context, index) {
                      final game = _filteredGames[index];
                      return Dismissible(
                        key: Key(game.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Delete Game'),
                                content: Text('Are you sure you want to delete "${game.displayTitle}"?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                    child: const Text('Delete', style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        onDismissed: (direction) {
                          widget.onGameDeleted(game.id);
                          setState(() {
                            _filteredGames = widget.games;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.withOpacity(0.1),
                              child: const Icon(
                                Icons.sports_tennis,
                                color: Colors.blue,
                              ),
                            ),
                            title: Text(
                              game.displayTitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                letterSpacing: 0.3,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  game.courtName,
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.people,
                                      size: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${game.playerIds.length} players',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Icon(
                                      Icons.attach_money,
                                      size: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '₱${game.totalCost.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                if (game.schedules.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatGameDate(game),
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                            onTap: () => _viewGame(game),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewGame,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../models/game.dart';
import '../models/user_settings.dart';
import '../services/app_storage.dart';
import 'edit_game.dart';

class ViewGameScreen extends StatelessWidget {
  final Game game;
  final UserSettings userSettings;
  final AppStorage appStorage;
  final Function(Game) onGameUpdated;
  final Function(String) onGameDeleted;

  const ViewGameScreen({
    super.key,
    required this.game,
    required this.userSettings,
    required this.appStorage,
    required this.onGameUpdated,
    required this.onGameDeleted,
  });

  void _editGame(BuildContext context) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => EditGameScreen(
          game: game,
          userSettings: userSettings,
          appStorage: appStorage,
        ),
      ),
    );

    if (result != null) {
      if (result['action'] == 'update') {
        onGameUpdated(result['game'] as Game);
        Navigator.pop(context);
      } else if (result['action'] == 'delete') {
        onGameDeleted(result['id'] as String);
        Navigator.pop(context);
      }
    }
  }

  void _deleteGame(BuildContext context) async {
    final confirmed = await showDialog<bool>(
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

    if (confirmed == true) {
      onGameDeleted(game.id);
      Navigator.pop(context);
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
        title: Text(
          game.displayTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => _editGame(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () => _deleteGame(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Game Title Card
              _buildInfoCard(
                title: 'Game Information',
                icon: Icons.info_outline,
                children: [
                  _buildInfoRow('Title', game.title.isEmpty ? 'Default (from schedule)' : game.title),
                  _buildInfoRow('Court Name', game.courtName),
                  _buildInfoRow('Created', _formatDateTime(game.createdAt)),
                ],
              ),
              const SizedBox(height: 16),

              // Schedules Card
              _buildInfoCard(
                title: 'Schedules',
                icon: Icons.schedule,
                children: game.schedules.isEmpty
                    ? [
                        const Text(
                          'No schedules added',
                          style: TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ]
                    : game.schedules.map((schedule) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                schedule.courtNumber,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_formatDate(schedule.startTime)} • ${schedule.timeRange}',
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Duration: ${_formatDuration(schedule.duration)}',
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
              ),
              const SizedBox(height: 16),

              // Cost Information Card
              _buildInfoCard(
                title: 'Cost Information',
                icon: Icons.attach_money,
                children: [
                  _buildInfoRow('Court Rate', '₱${game.courtRate.toStringAsFixed(2)}/hour'),
                  _buildInfoRow('Shuttlecock Price', '₱${game.shuttlecockPrice.toStringAsFixed(2)}'),
                  _buildInfoRow('Cost Division', game.divideCourtEqually ? 'Split equally among players' : 'Flat rate per game'),
                  const Divider(),
                  _buildInfoRow(
                    'Total Cost',
                    '₱${game.totalCost.toStringAsFixed(2)}',
                    isHighlighted: true,
                  ),
                  if (game.playerIds.isNotEmpty)
                    _buildInfoRow(
                      'Cost per Player',
                      '₱${game.costPerPlayer.toStringAsFixed(2)}',
                      isHighlighted: true,
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Players Card
              _buildInfoCard(
                title: 'Players',
                icon: Icons.people,
                children: [
                  _buildInfoRow('Number of Players', '${game.playerIds.length}'),
                  if (game.playerIds.isEmpty)
                    const Text(
                      'No players assigned to this game',
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  else
                    ...game.playerIds.map((playerId) {
                      final player = appStorage.getPlayerById(playerId);
                      if (player == null) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: Text(
                            'Player not found (ID: $playerId)',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                            ),
                          ),
                        );
                      }
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.green.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 16,
                              color: Colors.green.shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    player.nickname,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                  Text(
                                    player.fullName,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                ],
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _editGame(context),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Game'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.blue),
                        foregroundColor: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _deleteGame(context),
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete Game'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isHighlighted ? Colors.blue : Colors.grey[600],
                fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
                color: isHighlighted ? Colors.blue : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    } else {
      return '${minutes}m';
    }
  }
}
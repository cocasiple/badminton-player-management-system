import 'package:flutter/material.dart';
import '../models/player.dart';
import '../services/storage.dart';
import 'add_player.dart';
import 'edit_player.dart';

class AllPlayersScreen extends StatefulWidget {
  final PlayerStorage storage;
  const AllPlayersScreen({super.key, required this.storage});

  @override
  State<AllPlayersScreen> createState() => _AllPlayersScreenState();
}

class _AllPlayersScreenState extends State<AllPlayersScreen> {
  String _query = '';

  List<Player> get _filtered {
    final q = _query.toLowerCase();
    return widget.storage.all
        .where(
          (p) =>
              p.nickname.toLowerCase().contains(q) ||
              p.fullName.toLowerCase().contains(q),
        )
        .toList();
  }

  void _add() async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddPlayerScreen()),
    );
    if (res is Player) {
      setState(() => widget.storage.add(res));
    }
  }

  void _openEdit(Player p) async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditPlayerScreen(player: p)),
    );
    if (res is Map && res['action'] == 'update') {
      widget.storage.update(res['player'] as Player);
      setState(() {});
    } else if (res is Map && res['action'] == 'delete') {
      widget.storage.remove(res['id'] as String);
      setState(() {});
    }
  }

  // delete confirmation is handled inline where needed (dismissible / edit screen)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'All Players',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _add,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.blue),
                hintText: 'Search by name or nickname',
                hintStyle: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w400,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 16.0,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (c, i) {
                final p = _filtered[i];
                return Dismissible(
                  key: ValueKey(p.id),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (d) => AlertDialog(
                        title: const Text('Confirm'),
                        content: Text('Delete ${p.nickname}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(d, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(d, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (ok ?? false) widget.storage.remove(p.id);
                    setState(() {});
                    return ok ?? false;
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 6.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    elevation: 0,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      leading: CircleAvatar(
                        backgroundColor:
                            Colors.primaries[i % Colors.primaries.length],
                        child: Text(
                          p.nickname.isNotEmpty ? p.nickname[0] : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      title: Text(
                        p.nickname,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          letterSpacing: 0.5,
                        ),
                      ),
                      subtitle: Text(
                        '${p.fullName} · ${_levelLabel(p.levelStart, p.levelEnd)}',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                      onTap: () => _openEdit(p),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _levelLabel(int s, int e) {
    // Return 'Level/Sublevel' for a tick value
    String labelFor(int v) {
      final names = [
        'Beginners',
        'Intermediate',
        'Level G',
        'Level F',
        'Level E',
        'Level D',
        'Open',
      ];
      final level = (v ~/ 3).clamp(0, names.length - 1);
      final pos = v % 3;
      final sub = pos == 0 ? 'Weak' : (pos == 1 ? 'Mid' : 'Strong');
      return '${names[level]}/$sub';
    }

    return '${labelFor(s)} - ${labelFor(e)}';
  }
}

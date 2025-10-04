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
    return widget.storage.all.where((p) => p.nickname.toLowerCase().contains(q) || p.fullName.toLowerCase().contains(q)).toList();
  }

  void _add() async {
    final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPlayerScreen()));
    if (res is Player) {
      setState(() => widget.storage.add(res));
    }
  }

  void _openEdit(Player p) async {
    final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => EditPlayerScreen(player: p)));
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
      appBar: AppBar(
        title: const Text('All Players'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            child: ElevatedButton.icon(
              onPressed: _add,
              icon: const Icon(Icons.person_add),
              label: const Text('Add'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.transparent,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
        ],
      ),
      body: Column(children: [Padding(padding: const EdgeInsets.all(8.0), child: TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search by name or nick name'), onChanged: (v) => setState(() => _query = v))), Expanded(child: ListView.builder(itemCount: _filtered.length, itemBuilder: (c, i) {
        final p = _filtered[i];
        return Dismissible(key: ValueKey(p.id), direction: DismissDirection.endToStart, confirmDismiss: (_) async {
          final ok = await showDialog<bool>(context: context, builder: (d) => AlertDialog(title: const Text('Confirm'), content: Text('Delete ${p.nickname}?'), actions: [TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(d, true), child: const Text('Delete'))]));
          if (ok ?? false) widget.storage.remove(p.id);
          setState(() {});
          return ok ?? false;
        }, background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)), child: ListTile(leading: CircleAvatar(child: Text(p.nickname.isNotEmpty ? p.nickname[0] : '?')), title: Text(p.nickname), subtitle: Text('${p.fullName} · ${_levelLabel(p.levelStart, p.levelEnd)}'), onTap: () => _openEdit(p)));
      }))]),
    );
  }

  String _levelLabel(int s, int e) {
    // Simplified representation using start level only
    final levels = ['Beginners','Intermediate','Level G','Level F','Level E','Level D','Open'];
    final idx = (s ~/ 3).clamp(0, levels.length - 1);
    return levels[idx];
  }
}

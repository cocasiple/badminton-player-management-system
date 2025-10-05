import 'package:flutter/material.dart';
import '../models/player.dart';

class EditPlayerScreen extends StatefulWidget {
  final Player player;
  const EditPlayerScreen({super.key, required this.player});

  @override
  State<EditPlayerScreen> createState() => _EditPlayerScreenState();
}

class _EditPlayerScreenState extends State<EditPlayerScreen> {
  late final TextEditingController _nick;
  late final TextEditingController _full;
  late final TextEditingController _contact;
  late final TextEditingController _email;
  late final TextEditingController _address;
  late final TextEditingController _remarks;

  late int _start;
  late int _end;
  bool _isSliding = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final p = widget.player;
    _nick = TextEditingController(text: p.nickname);
    _full = TextEditingController(text: p.fullName);
    _contact = TextEditingController(text: p.contact);
    _email = TextEditingController(text: p.email);
    _address = TextEditingController(text: p.address);
    _remarks = TextEditingController(text: p.remarks);
    _start = p.levelStart;
    _end = p.levelEnd;
  }

  @override
  void dispose() {
    _nick.dispose();
    _full.dispose();
    _contact.dispose();
    _email.dispose();
    _address.dispose();
    _remarks.dispose();
    super.dispose();
  }

  void _update() {
    if (_formKey.currentState?.validate() ?? false) {
      final updated = widget.player.copyWith(
        nickname: _nick.text.trim(),
        fullName: _full.text.trim(),
        contact: _contact.text.trim(),
        email: _email.text.trim(),
        address: _address.text.trim(),
        remarks: _remarks.text.trim(),
        levelStart: _start,
        levelEnd: _end,
      );
      Navigator.pop(context, {'action': 'update', 'player': updated});
    }
  }

  void _delete() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete'),
        content: Text('Delete ${widget.player.nickname}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete')),
        ],
      ),
    );
    final ok = result ?? false;
    if (ok) {
      if (!mounted) return;
      Navigator.pop(context, {'action': 'delete', 'id': widget.player.id});
    }
  }

  @override
  Widget build(BuildContext context) {
    const totalTicks = 21;
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Player')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            TextFormField(controller: _nick, decoration: const InputDecoration(labelText: 'Nickname *'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
            const SizedBox(height: 8),
            TextFormField(controller: _full, decoration: const InputDecoration(labelText: 'Full Name *'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
            const SizedBox(height: 8),
            TextFormField(controller: _contact, decoration: const InputDecoration(labelText: 'Contact Number *'), keyboardType: TextInputType.phone, validator: (v) { if (v==null||v.trim().isEmpty) return 'Required'; return RegExp(r'^\d+').hasMatch(v.trim())?null:'Numbers only'; }),
            const SizedBox(height: 8),
            TextFormField(controller: _email, decoration: const InputDecoration(labelText: 'Email *'), keyboardType: TextInputType.emailAddress, validator: (v) { if (v==null||v.trim().isEmpty) return 'Required'; return RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$").hasMatch(v.trim())?null:'Invalid email'; }),
            const SizedBox(height: 8),
            TextFormField(controller: _address, decoration: const InputDecoration(labelText: 'Address'), maxLines: 3),
            const SizedBox(height: 8),
            TextFormField(controller: _remarks, decoration: const InputDecoration(labelText: 'Remarks'), maxLines: 3),
            const SizedBox(height: 16),
            const Text('Level'),
                  SizedBox(
              height: 120,
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: RangeSlider(
                              values: RangeValues(_start.toDouble(), _end.toDouble()),
                              min: 0,
                              max: (totalTicks - 1).toDouble(),
                              divisions: totalTicks - 1,
                              labels: RangeLabels(_label(_start), _label(_end)),
                              onChanged: (r) {
                                setState(() {
                                  _start = r.start.round();
                                  _end = r.end.round();
                                  if (_start > _end) {
                                    final t = _start;
                                    _start = _end;
                                    _end = t;
                                  }
                                });
                              },
                              onChangeStart: (_) => setState(() => _isSliding = true),
                              onChangeEnd: (_) => setState(() => _isSliding = false),
                            ),
                          ),
                        ),
                        // no floating popup; sublevel shown below while sliding
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Staggered level labels (two rows) aligned with slider divisions
                  SizedBox(
                    height: 36,
                    child: LayoutBuilder(builder: (context, box) {
                      const names = [
                        'Beginners',
                        'Intermediate',
                        'Level G',
                        'Level F',
                        'Level E',
                        'Level D',
                        'Open Player'
                      ];
                      Widget labelAt(int idx) => Expanded(
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(names[idx], textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                              ),
                            ),
                          );

                      return Column(children: [
                        Expanded(
                          child: Row(children: List.generate(names.length, (i) => i.isEven ? labelAt(i) : const Expanded(child: SizedBox.shrink()))),
                        ),
                        Expanded(
                          child: Row(children: List.generate(names.length, (i) => i.isOdd ? labelAt(i) : const Expanded(child: SizedBox.shrink()))),
                        ),
                      ]);
                    }),
                  ),

                  // always show combined level/sublevel on From/To
                  Text('From: ${_label(_start)}/${_subLabel(_start)}'),
                  Text('To: ${_label(_end)}/${_subLabel(_end)}'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(children: [Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))), const SizedBox(width: 12), Expanded(child: ElevatedButton(onPressed: _update, child: const Text('Update')))]),
            const SizedBox(height: 12),
            ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: _delete, child: const Text('Delete'))
          ]),
        ),
      ),
    );
  }

  String _label(int value){
    const names = ['Beginners','Intermediate','Level G','Level F','Level E','Level D','Open Player'];
    final idx = (value~/3).clamp(0,names.length-1);
    return names[idx];
  }

  String _groupLabel(int mid) {
    const names = ['Beginners','Intermediate','Level G','Level F','Level E','Level D','Open Player'];
    final level = (mid ~/ 3).clamp(0, names.length - 1);
    final pos = mid % 3;
    final sub = pos == 0 ? 'Weak' : (pos == 1 ? 'Mid' : 'Strong');
    return '${names[level]} - $sub';
  }

  String _subLabel(int mid) {
    final pos = mid % 3;
    return pos == 0 ? 'Weak' : (pos == 1 ? 'Mid' : 'Strong');
  }
}

class _EditTicksPainter extends CustomPainter {
  final int totalTicks;
  const _EditTicksPainter({this.totalTicks = 21});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.grey..strokeWidth = 1;
  const ticksPerLevel = 3;

    // Match RangeSlider horizontal padding (8.0) so ticks line up with the track.
    const horizontalPadding = 8.0;
    final paddedWidth = (size.width - horizontalPadding * 2).clamp(0.0, size.width);

    for (int i = 0; i < totalTicks; i++) {
      final dx = horizontalPadding + (i / (totalTicks - 1)) * paddedWidth;
      final posInGroup = i % ticksPerLevel; // 0..2
      final startY = size.height * (posInGroup == 0 ? 0.55 : (posInGroup == 1 ? 0.45 : 0.32));
      final endY = size.height * 0.55;
      canvas.drawLine(Offset(dx, startY), Offset(dx, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
// removed tick overlay painter; leaving default RangeSlider appearance

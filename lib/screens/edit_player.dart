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
      final updated = Player(
        id: widget.player.id,
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
      builder: (context) => AlertDialog(
        title: const Text('Delete'),
        content: Text('Delete ${widget.player.nickname}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        titleSpacing: 0,
        toolbarHeight: 48,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          padding: const EdgeInsets.only(top: 16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text(
                  'Edit Player',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              _buildInputField(
                controller: _nick,
                label: 'NICKNAME',
                icon: Icons.person,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                controller: _full,
                label: 'FULL NAME',
                icon: Icons.person,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                controller: _contact,
                label: 'MOBILE NUMBER',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (v) { 
                  if (v==null||v.trim().isEmpty) return 'Required'; 
                  return RegExp(r'^\d+').hasMatch(v.trim())?null:'Numbers only'; 
                },
              ),
              const SizedBox(height: 16),
              _buildInputField(
                controller: _email,
                label: 'EMAIL ADDRESS',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (v) { 
                  if (v==null||v.trim().isEmpty) return 'Required'; 
                  return RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$").hasMatch(v.trim())?null:'Invalid email'; 
                },
              ),
              const SizedBox(height: 16),
              _buildInputField(
                controller: _address,
                label: 'HOME ADDRESS',
                icon: Icons.location_on,
                maxLines: null,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                controller: _remarks,
                label: 'REMARKS',
                icon: Icons.book,
                maxLines: null,
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'LEVEL',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
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
                              activeColor: Colors.blue,
                              inactiveColor: Colors.blue.withOpacity(0.3),
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int? maxLines = 1,
  }) {
    return Container(
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
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 12, right: 16),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
                fontFamily: 'Roboto',
              ),
            ),
          ),
          TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            maxLines: maxLines,
            minLines: 1,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
              fontFamily: 'Roboto',
              height: 1.4,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: Colors.blue,
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(left: 56, right: 16, bottom: 16, top: 8),
              hintStyle: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
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

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
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Player',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInputField(
                  controller: _nick,
                  label: 'NICKNAME',
                  icon: Icons.person,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 10),
                _buildInputField(
                  controller: _full,
                  label: 'FULL NAME',
                  icon: Icons.person,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 10),
                _buildInputField(
                  controller: _contact,
                  label: 'MOBILE NUMBER',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    return RegExp(r'^\d+').hasMatch(v.trim())
                        ? null
                        : 'Numbers only';
                  },
                ),
                const SizedBox(height: 10),
                _buildInputField(
                  controller: _email,
                  label: 'EMAIL ADDRESS',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    return RegExp(
                          r"^[^@\s]+@[^@\s]+\.[^@\s]+$",
                        ).hasMatch(v.trim())
                        ? null
                        : 'Invalid email';
                  },
                ),
                const SizedBox(height: 10),
                _buildInputField(
                  controller: _address,
                  label: 'HOME ADDRESS',
                  icon: Icons.location_on,
                  maxLines: null,
                ),
                const SizedBox(height: 10),
                _buildInputField(
                  controller: _remarks,
                  label: 'REMARKS',
                  icon: Icons.book,
                  maxLines: null,
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.trending_up, color: Colors.blue, size: 16),
                          const SizedBox(width: 6),
                          const Text(
                            'BADMINTON LEVEL RANGE',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      RangeSlider(
                        values: RangeValues(
                          _start.toDouble(),
                          _end.toDouble(),
                        ),
                        min: 0,
                        max: (totalTicks - 1).toDouble(),
                        divisions: totalTicks - 1,
                        labels: RangeLabels(
                          '${_label(_start)} (${_subLabel(_start)})',
                          '${_label(_end)} (${_subLabel(_end)})',
                        ),
                        activeColor: Colors.blue.shade600,
                        inactiveColor: Colors.blue.withValues(alpha: 0.3),
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
                      ),
                      const SizedBox(height: 4),
                      // Level labels
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Beginners', style: TextStyle(fontSize: 8, color: Colors.blue.shade600)),
                          Text('Intermediate', style: TextStyle(fontSize: 8, color: Colors.blue.shade600)),
                          Text('Level G', style: TextStyle(fontSize: 8, color: Colors.blue.shade600)),
                          Text('Level F', style: TextStyle(fontSize: 8, color: Colors.blue.shade600)),
                          Text('Level E', style: TextStyle(fontSize: 8, color: Colors.blue.shade600)),
                          Text('Level D', style: TextStyle(fontSize: 8, color: Colors.blue.shade600)),
                          Text('Open', style: TextStyle(fontSize: 8, color: Colors.blue.shade600)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Current selection display
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.sports_tennis, color: Colors.blue.shade700, size: 12),
                            const SizedBox(width: 6),
                            Text(
                              'From: ${_label(_start)}/${_subLabel(_start)} • To: ${_label(_end)}/${_subLabel(_end)}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Colors.grey, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _update,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Update Player',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _delete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.red.shade200, width: 1),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text(
                      'Delete Player',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _label(int value) {
    const names = [
      'Beginners',
      'Intermediate',
      'Level G',
      'Level F',
      'Level E',
      'Level D',
      'Open Player',
    ];
    final idx = (value ~/ 3).clamp(0, names.length - 1);
    return names[idx];
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
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 0.5,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        minLines: 1,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
          height: 1.3,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          floatingLabelStyle: const TextStyle(
            fontSize: 10,
            color: Colors.blue,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          prefixIcon: Icon(icon, color: Colors.blue, size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          hintStyle: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}

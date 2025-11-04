import 'package:flutter/material.dart';
import '../models/game.dart';
import '../models/user_settings.dart';
import '../services/app_storage.dart';

class AddGameScreen extends StatefulWidget {
  final UserSettings userSettings;
  final AppStorage appStorage;

  const AddGameScreen({super.key, required this.userSettings, required this.appStorage});

  @override
  State<AddGameScreen> createState() => _AddGameScreenState();
}

class _AddGameScreenState extends State<AddGameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _courtNameController = TextEditingController();
  final _courtRateController = TextEditingController();
  final _shuttlecockPriceController = TextEditingController();
  bool _divideCourtEqually = true;
  List<GameSchedule> _schedules = [];
  List<String> _selectedPlayerIds = [];

  @override
  void initState() {
    super.initState();
    _courtNameController.text = widget.userSettings.defaultCourtName;
    _courtRateController.text = widget.userSettings.defaultCourtRate.toString();
    _shuttlecockPriceController.text = widget.userSettings.defaultShuttlecockPrice.toString();
    _divideCourtEqually = widget.userSettings.divideCourtEqually;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _courtNameController.dispose();
    _courtRateController.dispose();
    _shuttlecockPriceController.dispose();
    super.dispose();
  }

  void _addSchedule() async {
    final schedule = await _showScheduleDialog();
    if (schedule != null) {
      setState(() {
        _schedules.add(schedule);
      });
    }
  }

  Future<GameSchedule?> _showScheduleDialog() async {
    String courtNumber = '';
    DateTime selectedDate = DateTime.now();
    TimeOfDay startTime = TimeOfDay.now();
    TimeOfDay endTime = TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);

    return showDialog<GameSchedule>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Schedule'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Court Number',
                        hintText: 'e.g., Court 1',
                      ),
                      onChanged: (value) => courtNumber = value,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Date'),
                      subtitle: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            selectedDate = date;
                          });
                        }
                      },
                    ),
                    ListTile(
                      title: const Text('Start Time'),
                      subtitle: Text(startTime.format(context)),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: startTime,
                        );
                        if (time != null) {
                          setState(() {
                            startTime = time;
                          });
                        }
                      },
                    ),
                    ListTile(
                      title: const Text('End Time'),
                      subtitle: Text(endTime.format(context)),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: endTime,
                        );
                        if (time != null) {
                          setState(() {
                            endTime = time;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (courtNumber.isNotEmpty) {
                      final startDateTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        startTime.hour,
                        startTime.minute,
                      );
                      final endDateTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        endTime.hour,
                        endTime.minute,
                      );
                      
                      if (endDateTime.isAfter(startDateTime)) {
                        final schedule = GameSchedule(
                          courtNumber: courtNumber,
                          startTime: startDateTime,
                          endTime: endDateTime,
                        );
                        Navigator.pop(context, schedule);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('End time must be after start time')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter court number')),
                      );
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _removeSchedule(int index) {
    setState(() {
      _schedules.removeAt(index);
    });
  }

  void _selectPlayers() async {
    final result = await showDialog<List<String>>(
      context: context,
      builder: (context) => _buildPlayerSelectionDialog(),
    );
    
    if (result != null) {
      setState(() {
        _selectedPlayerIds = result;
      });
    }
  }

  Widget _buildPlayerSelectionDialog() {
    List<String> tempSelected = List.from(_selectedPlayerIds);
    
    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text('Select Players'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: widget.appStorage.players.isEmpty
                ? const Center(child: Text('No players available'))
                : ListView.builder(
                    itemCount: widget.appStorage.players.length,
                    itemBuilder: (context, index) {
                      final player = widget.appStorage.players[index];
                      final isSelected = tempSelected.contains(player.id);
                      
                      return CheckboxListTile(
                        title: Text(player.nickname),
                        subtitle: Text(player.fullName),
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              tempSelected.add(player.id);
                            } else {
                              tempSelected.remove(player.id);
                            }
                          });
                        },
                        activeColor: Colors.blue,
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, tempSelected),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Select', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_schedules.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one schedule')),
        );
        return;
      }

      final game = Game(
        id: '',
        title: _titleController.text.trim(),
        courtName: _courtNameController.text.trim(),
        schedules: _schedules,
        courtRate: double.parse(_courtRateController.text.trim()),
        shuttlecockPrice: double.parse(_shuttlecockPriceController.text.trim()),
        divideCourtEqually: _divideCourtEqually,
        playerIds: _selectedPlayerIds,
        createdAt: DateTime.now(),
      );
      Navigator.pop(context, game);
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
          'Add New Game',
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
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInputField(
                  controller: _titleController,
                  label: 'GAME TITLE (Optional)',
                  icon: Icons.title,
                  hint: 'Leave blank to use schedule as title',
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  controller: _courtNameController,
                  label: 'COURT NAME',
                  icon: Icons.sports_tennis,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Court name is required' : null,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  controller: _courtRateController,
                  label: 'COURT RATE (₱/hour)',
                  icon: Icons.attach_money,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Court rate is required';
                    final rate = double.tryParse(v.trim());
                    if (rate == null || rate <= 0) return 'Please enter a valid rate';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  controller: _shuttlecockPriceController,
                  label: 'SHUTTLECOCK PRICE (₱)',
                  icon: Icons.sports_volleyball,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Shuttlecock price is required';
                    final price = double.tryParse(v.trim());
                    if (price == null || price <= 0) return 'Please enter a valid price';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Container(
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
                  child: CheckboxListTile(
                    title: const Text(
                      'Divide the court equally among players',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    value: _divideCourtEqually,
                    onChanged: (value) {
                      setState(() {
                        _divideCourtEqually = value ?? true;
                      });
                    },
                    activeColor: Colors.blue,
                    checkColor: Colors.white,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'PLAYERS',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _selectPlayers,
                      icon: const Icon(Icons.person_add, size: 16),
                      label: const Text('Select Players'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_selectedPlayerIds.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Center(
                      child: Text(
                        'No players selected\nTap "Select Players" to add players',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  Container(
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
                      children: _selectedPlayerIds.map((playerId) {
                        final player = widget.appStorage.getPlayerById(playerId);
                        if (player == null) return const SizedBox.shrink();
                        
                        return ListTile(
                          leading: const Icon(Icons.person, color: Colors.blue),
                          title: Text(player.nickname),
                          subtitle: Text(player.fullName),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _selectedPlayerIds.remove(playerId);
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'SCHEDULES',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _addSchedule,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Schedule'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_schedules.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Center(
                      child: Text(
                        'No schedules added yet\nTap "Add Schedule" to get started',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ...List.generate(_schedules.length, (index) {
                    final schedule = _schedules[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
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
                        leading: const Icon(Icons.schedule, color: Colors.blue),
                        title: Text(schedule.courtNumber),
                        subtitle: Text(
                          '${schedule.startTime.day}/${schedule.startTime.month}/${schedule.startTime.year} • ${schedule.timeRange}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeSchedule(index),
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.blue),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Save Game'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    String? hint,
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
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
              fontFamily: 'Roboto',
              height: 1.4,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.blue, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(
                left: 56,
                right: 16,
                bottom: 16,
                top: 8,
              ),
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
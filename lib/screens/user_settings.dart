import 'package:flutter/material.dart';
import '../models/user_settings.dart';

class UserSettingsScreen extends StatefulWidget {
  final UserSettings? currentSettings;

  const UserSettingsScreen({super.key, this.currentSettings});

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _courtNameController = TextEditingController();
  final _courtRateController = TextEditingController();
  final _shuttlecockPriceController = TextEditingController();
  bool _divideCourtEqually = true;

  @override
  void initState() {
    super.initState();
    final settings = widget.currentSettings ?? UserSettings.getDefault();
    _courtNameController.text = settings.defaultCourtName;
    _courtRateController.text = settings.defaultCourtRate.toString();
    _shuttlecockPriceController.text = settings.defaultShuttlecockPrice.toString();
    _divideCourtEqually = settings.divideCourtEqually;
  }

  @override
  void dispose() {
    _courtNameController.dispose();
    _courtRateController.dispose();
    _shuttlecockPriceController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      final settings = UserSettings(
        defaultCourtName: _courtNameController.text.trim(),
        defaultCourtRate: double.parse(_courtRateController.text.trim()),
        defaultShuttlecockPrice: double.parse(_shuttlecockPriceController.text.trim()),
        divideCourtEqually: _divideCourtEqually,
      );
      Navigator.pop(context, settings);
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
          'User Settings',
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
                  controller: _courtNameController,
                  label: 'DEFAULT COURT NAME',
                  icon: Icons.sports_tennis,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Court name is required' : null,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  controller: _courtRateController,
                  label: 'DEFAULT COURT RATE (₱/hour)',
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
                  label: 'DEFAULT SHUTTLECOCK PRICE (₱)',
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
                    subtitle: Text(
                      _divideCourtEqually 
                          ? 'Court cost will be split equally among all players'
                          : 'Court cost will be charged as a flat rate per game',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
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
                        child: const Text('Save Settings'),
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
              hintStyle: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
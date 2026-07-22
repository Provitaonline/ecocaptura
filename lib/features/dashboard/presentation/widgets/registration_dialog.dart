import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegistrationDialog extends StatefulWidget {
  const RegistrationDialog({super.key});

  @override
  State<RegistrationDialog> createState() => _RegistrationDialogState();
}

class _RegistrationDialogState extends State<RegistrationDialog> {
  final TextEditingController _usernameController = TextEditingController();
  String? _errorMessage;

  // Validation rules matching the web client
  final RegExp _usernameRegex = RegExp(r'^[a-zA-Z0-9\-\+\$\@\#]{3,20}$');

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Complete Registration'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min, 
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please choose a unique username to continue.'),
            const SizedBox(height: 8),
            const Text(
              '3-20 characters. Letters, numbers, and -, +, \$, @, # allowed.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              maxLength: 20,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\-\+\$\@\#]')),
              ],
              decoration: InputDecoration(
                labelText: 'Username',
                border: const OutlineInputBorder(),
                errorText: _errorMessage,
                counterText: '', 
              ),
              onChanged: (_) {
                if (_errorMessage != null) {
                  setState(() => _errorMessage = null);
                }
              },
              onSubmitted: (_) => _handleConfirm(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _handleConfirm,
          child: const Text('Register'),
        ),
      ],
    );
  }

  void _handleConfirm() {
    final val = _usernameController.text.trim();
    
    if (val.isEmpty) {
      setState(() => _errorMessage = 'Username cannot be empty');
      return;
    }

    if (!_usernameRegex.hasMatch(val)) {
      setState(() => _errorMessage = 'Username must be 3-20 characters long.');
      return;
    }

    Navigator.of(context).pop(val);
  }
}
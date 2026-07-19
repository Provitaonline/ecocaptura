import 'package:flutter/material.dart';

class RegistrationDialog extends StatefulWidget {
  const RegistrationDialog({super.key});

  @override
  State<RegistrationDialog> createState() => _RegistrationDialogState();
}

class _RegistrationDialogState extends State<RegistrationDialog> {
  final TextEditingController _usernameController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Complete Registration'),
      // Using SingleChildScrollView prevents RenderFlex overflow when 
      // the keyboard appears or on small screens.
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Dialog hugs content
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please choose a unique username to continue.'),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Username',
                border: const OutlineInputBorder(),
                errorText: _errorMessage,
              ),
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
    if (val.isNotEmpty) {
      Navigator.of(context).pop(val);
    } else {
      setState(() => _errorMessage = 'Username cannot be empty');
    }
  }
}
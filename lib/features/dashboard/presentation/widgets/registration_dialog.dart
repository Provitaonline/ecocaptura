import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ecocaptura/core/extensions/content_extensions.dart';

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
      title: Text(context.i18n.register),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min, 
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.i18n.chooseUsername),
            const SizedBox(height: 8),
            Text(
              context.i18n.usernameFormatLabel,
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
                labelText: context.i18n.username,
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
          child: Text(context.i18n.cancel),
        ),
        ElevatedButton(
          onPressed: _handleConfirm,
          child: Text(context.i18n.register),
        ),
      ],
    );
  }

  void _handleConfirm() {
    final val = _usernameController.text.trim();
    
    if (val.isEmpty) {
      setState(() => _errorMessage = context.i18n.usernameEmpty);
      return;
    }

    if (!_usernameRegex.hasMatch(val)) {
      setState(() => _errorMessage = context.i18n.usernameLength);
      return;
    }

    Navigator.of(context).pop(val);
  }
}
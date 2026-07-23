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

  // Validation rules matching the web client
  final RegExp _usernameRegex = RegExp(r'^[a-zA-Z0-9\-\+\$\@]{3,20}$');
  
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _usernameController.removeListener(_validateForm);
    _usernameController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final val = _usernameController.text.trim();
    final isValid = _usernameRegex.hasMatch(val);
    
    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
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
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              maxLength: 20,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\-\+\$\@]')),
              ],
              decoration: InputDecoration(
                labelText: context.i18n.username,
                border: const OutlineInputBorder(),
                counterText: '', 
              ),
              onSubmitted: (_) {
                if (_isFormValid) {
                  _handleConfirm();
                }
              },
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
          onPressed: _isFormValid ? _handleConfirm : null,
          child: Text(context.i18n.register),
        ),
      ],
    );
  }

  void _handleConfirm() {
    final val = _usernameController.text.trim();
    if (_usernameRegex.hasMatch(val)) {
      Navigator.of(context).pop(val);
    }
  }
}
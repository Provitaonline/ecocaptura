import 'package:flutter/material.dart';
import 'package:ecocaptura/core/services/auth_service.dart';
import '../widgets/registration_dialog.dart'; 

class SyncHelper {
  static Future<bool> ensureAuthenticatedAndSynced(
    BuildContext context, 
    Future<void> Function(BuildContext) executeSync,
  ) async {
    final authService = AuthService.instance;

    if (await authService.isAuthenticated()) {
      await executeSync(context);
      return true;
    }

    // Initial login attempt
    AuthResult result = await authService.loginWithGoogle();

    if (result == AuthResult.failed) {
      bool registrationSuccessful = false;
      String? registeredUsername;

      while (!registrationSuccessful) {
        if (!context.mounted) return false;

        final String? username = await showDialog<String>(
          context: context,
          builder: (context) => const RegistrationDialog(),
        );

        if (username == null) return false;

        final AuthResult regResult = await authService.loginWithGoogle(username: username);
        
        if (regResult == AuthResult.success) {
          registrationSuccessful = true;
          registeredUsername = username;
        } else if (regResult == AuthResult.cancelled) {
          return false; 
        } else {
          if (!context.mounted) return false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('That username is taken or an error occurred. Please try another.')),
          );
        }
      }

      if (registrationSuccessful && registeredUsername != null) {
        if (!context.mounted) return false;
        await executeSync(context);
        return true;
      }
    } else if (result == AuthResult.success) {
      await executeSync(context);
      return true;
    }

    return false;
  }
}
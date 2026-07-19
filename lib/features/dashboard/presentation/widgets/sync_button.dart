import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/extensions/content_extensions.dart';
import './registration_dialog.dart';

class SyncButton extends StatelessWidget {
  const SyncButton({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snapshot) {
        final results = snapshot.data ?? [ConnectivityResult.none];
        final bool isWifi = results.contains(ConnectivityResult.wifi);

        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: ElevatedButton.icon(
            onPressed: isWifi
                ? () async {
                    final authService = AuthService.instance;

                    if (await authService.isAuthenticated()) {
                      print("Syncing...");
                      return;
                    }

                    // Initial attempt
                    AuthResult result = await authService.loginWithGoogle();

                    // If the initial attempt was a failure (not cancelled), 
                    // enter the registration loop.
                    if (result == AuthResult.failed) {
                      bool registrationSuccessful = false;

                      while (!registrationSuccessful) {
                        if (!context.mounted) return;

                        final String? username = await showDialog<String>(
                          context: context,
                          builder: (context) => const RegistrationDialog(),
                        );

                        // User cancelled the dialog: break out of the loop and stop
                        if (username == null) break;

                        // Attempt to register with the chosen name
                        final AuthResult regResult = await authService.loginWithGoogle(username: username);
                        
                        if (regResult == AuthResult.success) {
                          registrationSuccessful = true;
                          print("Registered and Syncing...");
                        } else if (regResult == AuthResult.cancelled) {
                          // User cancelled the Google sign-in again during the loop
                          break; 
                        } else {
                          // regResult == AuthResult.failed
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('That username is taken or an error occurred. Please try another.')),
                          );
                        }
                      }
                    } else if (result == AuthResult.success) {
                      print("Auto-logged in and Syncing...");
                    }
                    // If result == AuthResult.cancelled, we do nothing and return to the UI.
                  }
                : null,
            icon: const Icon(Icons.cloud_upload),
            label: Text(isWifi ? context.i18n.sync : context.i18n.connectToSync),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(45),
            ),
          ),
        );
      },
    );
  }
}
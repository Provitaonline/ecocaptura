import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/extensions/content_extensions.dart';
import '../controllers/capture_controller.dart';
import './registration_dialog.dart';
import '../../data/models/capture_model.dart';

class SyncButton extends StatelessWidget {
  final CaptureController captureController;

  const SyncButton({
    super.key,
    required this.captureController,
  });

  Future<void> _executeSync(BuildContext context) async {
    try {
      await captureController.syncPendingCaptures();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sync completed successfully!')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sync failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: captureController,
      builder: (context, child) {
        final bool isSyncing = captureController.isSyncing;
        // Check if there are captures ready to sync
        final bool hasPending = captureController.captures.any((c) => c.status == CaptureStatus.ready);

        return StreamBuilder<List<ConnectivityResult>>(
          stream: Connectivity().onConnectivityChanged,
          builder: (context, snapshot) {
            final results = snapshot.data ?? [ConnectivityResult.none];
            final bool isWifi = results.contains(ConnectivityResult.wifi);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: ElevatedButton.icon(
                onPressed: (isWifi && !isSyncing && hasPending)
                    ? () async {
                        final authService = AuthService.instance;

                        if (await authService.isAuthenticated()) {
                          await _executeSync(context);
                          return;
                        }

                        // Initial login attempt
                        AuthResult result = await authService.loginWithGoogle();

                        if (result == AuthResult.failed) {
                          bool registrationSuccessful = false;
                          String? registeredUsername;

                          while (!registrationSuccessful) {
                            if (!context.mounted) return;

                            final String? username = await showDialog<String>(
                              context: context,
                              builder: (context) => const RegistrationDialog(),
                            );

                            if (username == null) break;

                            final AuthResult regResult = await authService.loginWithGoogle(username: username);
                            
                            if (regResult == AuthResult.success) {
                              registrationSuccessful = true;
                              registeredUsername = username;
                            } else if (regResult == AuthResult.cancelled) {
                              break; 
                            } else {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('That username is taken or an error occurred. Please try another.')),
                              );
                            }
                          }

                          if (registrationSuccessful && registeredUsername != null) {
                            if (!context.mounted) return;
                            await _executeSync(context);
                          }
                        } else if (result == AuthResult.success) {
                          await _executeSync(context);
                        }
                      }
                    : null,
                icon: isSyncing 
                    ? const SizedBox(
                        width: 18, 
                        height: 18, 
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.cloud_upload),
                label: Text(isSyncing ? 'Syncing...' : (isWifi ? context.i18n.sync : context.i18n.connectToSync)),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(45),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
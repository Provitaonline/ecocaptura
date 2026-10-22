import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:ecocaptura/core/extensions/content_extensions.dart';
import '../controllers/capture_controller.dart';
import 'package:ecocaptura/features/dashboard/data/models/capture_model.dart';
import '../helpers/sync_helper.dart';

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
        SnackBar(content: Text(context.i18n.syncCompleted)),
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
        final bool hasPending = captureController.captures.any((c) => c.status == CaptureStatus.ready);

        return StreamBuilder<List<ConnectivityResult>>(
          stream: Connectivity().onConnectivityChanged,
          builder: (context, snapshot) {
            final results = snapshot.data ?? [ConnectivityResult.none];
            final bool isWifi = results.contains(ConnectivityResult.wifi);

            // Determine icon state: Deterministic progress ring when uploading, standard cloud icon otherwise
            final Widget buttonIcon = isSyncing
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      value: captureController.syncProgress > 0 ? captureController.syncProgress : null,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                : const Icon(Icons.cloud_upload);

            // Determine label state
            final String buttonText = isSyncing
                ? '${context.i18n.syncing} (${captureController.syncProgressText})'
                : (isWifi ? context.i18n.sync : context.i18n.connectToSync);

            return ElevatedButton.icon(
              onPressed: (isWifi && !isSyncing && hasPending)
                  ? () => SyncHelper.ensureAuthenticatedAndSynced(context, _executeSync)
                  : null,
              icon: buttonIcon,
              label: Text(buttonText),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(45),
              ),
            );
          },
        );
      },
    );
  }
}
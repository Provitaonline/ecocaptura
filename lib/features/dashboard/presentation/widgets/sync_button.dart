import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/extensions/content_extensions.dart';

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
            onPressed: isWifi ? () => AuthService.instance.handleSyncRequest() : null,
            icon: const Icon(Icons.cloud_upload),
            label: Text(isWifi ? context.i18n.sync : context.i18n.connectToSync),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(45), // Full width
            ),
          ),
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ecocaptura/core/l10n/app_localizations.dart';
import 'package:ecocaptura/core/constants/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _version = "";

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = "${info.version}+${info.buildNumber}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(title: Text(l10n.menuAbout)),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48.0, // Account for padding
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Icon(Icons.eco, color: Colors.teal.shade300, size: 50),
                      const SizedBox(height: 20),

                      Text("ecocaptura", style: theme.textTheme.headlineMedium),
                      const SizedBox(height: 4),
                      Text(l10n.aboutAppVersion(_version)),
                      
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Divider(),
                      ),

                      // Explicit style fallback to ensure text visibility
                      Text(
                        l10n.aboutDescription,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const Spacer(),
                      const SizedBox(height: 24),
                      
                      Text(
                        l10n.aboutContactLabel,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      TextButton(
                        onPressed: () => _launchSupportEmail(AppInfo.supportEmail), 
                        child: const Text(AppInfo.supportEmail),
                      ),
                      const SizedBox(height: 10),
                      Image.asset(
                        'assets/org_logo.png',
                        height: 100,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox(height: 100); // Graceful fallback if logo fails
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

Future<void> _launchSupportEmail(String email) async {
  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: email,
    query: 'subject=Support for EcoCaptura&body=Hello,',
  );

  if (await canLaunchUrl(emailUri)) {
    await launchUrl(emailUri);
  } else {
    debugPrint('Could not launch $emailUri');
  }
}
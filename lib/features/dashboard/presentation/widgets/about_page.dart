import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '.././../../../core/l10n/app_localizations.dart';
import '../../../../core/constants/app_constants.dart';
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
    setState(() {
      _version = "${info.version}+${info.buildNumber}";
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(title: Text(l10n.menuAbout)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(Icons.eco, color: Colors.teal.shade300, size: 50),
            const SizedBox(height: 20),

            Text("ecocaptura", style: Theme.of(context).textTheme.headlineMedium),
            Text(l10n.aboutAppVersion(_version)),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30.0),
              child: Divider(),
            ),

            Text(
              l10n.aboutDescription,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            
            const Spacer(),
            
            Text(l10n.aboutContactLabel),
            TextButton(
              onPressed: () => _launchSupportEmail(AppInfo.supportEmail), 
              child: const Text('support@yourorg.com'),
            ),
            const SizedBox(height: 10),
            Image.asset(
              'assets/org_logo.png',
              height: 100,
              fit: BoxFit.contain,
            ),
          ],
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
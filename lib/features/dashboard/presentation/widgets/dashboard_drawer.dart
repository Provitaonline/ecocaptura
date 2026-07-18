import 'package:flutter/material.dart';
import '../../../../core/extensions/content_extensions.dart';
import '../../../../core/l10n/locale_controller.dart';
import '../../../../core/services/preferences_service.dart';
import '../widgets/about_page.dart';

class DashboardDrawer extends StatelessWidget {

  const DashboardDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.teal.shade800,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  context.i18n.drawerHeader,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SThemeText(text: context.i18n.drawerSubtitle, color: Colors.white70),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(context.i18n.menuLanguage),
            subtitle: Text(
              Localizations.localeOf(context).languageCode == 'es'
                  ? 'English'
                  : 'Español',
            ),
            onTap: () async {
              Navigator.pop(context); 
              
              final currentLanguage = Localizations.localeOf(context).languageCode;
              final newLocale = Locale(currentLanguage == 'es' ? 'en' : 'es');

              LocaleController.instance.setLocale(newLocale);
              
              await PreferencesService().setLanguage(newLocale.languageCode);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(context.i18n.menuAbout),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AboutPage()),
                  );
              },
          ),
        ],
      ),
    );
  }
}

/// Simple helper to keep styling consistent
class SThemeText extends StatelessWidget {
  final String text;
  final Color color;
  const SThemeText({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(color: color, fontSize: 14));
  }
}
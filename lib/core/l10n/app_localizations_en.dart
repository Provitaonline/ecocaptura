// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ecocaptura';

  @override
  String get drawerHeader => 'ecocaptura Settings';

  @override
  String get drawerSubtitle => 'Device Configuration Options';

  @override
  String get menuPairDevice => 'Pair Device to Site';

  @override
  String get menuPairSubtitle => 'Scan web QR authentication token';

  @override
  String get menuLanguage => 'Change Language';

  @override
  String get menuLanguageSubtitle => 'English / Español';

  @override
  String get menuAbout => 'About App';

  @override
  String get btnNewCaptura => 'New Capture';
}

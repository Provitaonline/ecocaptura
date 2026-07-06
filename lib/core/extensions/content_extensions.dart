import 'package:flutter/widgets.dart';
import '../l10n/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get i18n => AppLocalizations.of(this)!;
}
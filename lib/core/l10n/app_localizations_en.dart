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
  String get btnNewCapture => 'New Capture';

  @override
  String get recentCaptures => 'Recent Captures';

  @override
  String get noCaptures => 'No captures yet.';

  @override
  String get unnamedCapture => 'Unnamed Capture';

  @override
  String get newCapture => 'New Capture';

  @override
  String get editCapture => 'Edit Capture';

  @override
  String get photos => 'Photos';

  @override
  String get captureDetails => 'Capture Details';

  @override
  String get description => 'Description';

  @override
  String get descriptionHint => 'Enter capture description';

  @override
  String get saveCapture => 'Save capture';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get abortCapture => 'Abort capture';

  @override
  String get dataQuality => 'Rate data quality';

  @override
  String get qualityReason => 'Select a reason';

  @override
  String get cardinalDirections =>
      'N,NNE,NE,ENE,E,ESE,SE,SSE,S,SSW,SW,WSW,W,WNW,NW,NNW';

  @override
  String get tilt => 'Tilt';

  @override
  String get deletePhotoTitle => 'Delete Photo';

  @override
  String get deletePhotoMessage => 'Are you sure?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get reasonPoorGps => 'Poor GPS';

  @override
  String get reasonBlurry => 'Blurry';

  @override
  String get reasonObstructed => 'Obstructed';

  @override
  String get reasonOther => 'Other';

  @override
  String get discardChangesTitle => 'Discard changes?';

  @override
  String get discardChangesMessage =>
      'You have unsaved changes. Are you sure you want to leave?';

  @override
  String get keepEditing => 'Keep editing';

  @override
  String get discard => 'Discard';
}

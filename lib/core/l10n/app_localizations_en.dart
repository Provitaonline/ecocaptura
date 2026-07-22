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
  String get menuPairSubtitle => 'Scan QR code (coming soon)';

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

  @override
  String get captureInfo => 'Capture info';

  @override
  String get captureDeleted => 'Capture deleted';

  @override
  String exportCaptureMessage(String captureId, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos',
      one: '1 photo',
    );
    return 'Export of Capture $captureId containing $_temp0.';
  }

  @override
  String aboutAppVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutDescription =>
      'EcoCaptura is a field data collection tool to capture photographic evidence for ecosystem analysis.';

  @override
  String get aboutContactLabel => 'Contact our support team:';

  @override
  String photosCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos',
      one: '1 photo',
      zero: 'No photos',
    );
    return '$_temp0';
  }

  @override
  String get sync => 'Sync Captures';

  @override
  String get connectToSync => 'Connect to Wi-Fi to Sync';

  @override
  String get retain => 'Retain';

  @override
  String get register => 'Register...';

  @override
  String get chooseUsername => 'Choose a unique username to continue';

  @override
  String get username => 'Username';

  @override
  String get usernameFormatLabel => '3-20 letters, numbers, and -, +, \$, @, #';

  @override
  String get usernameEmpty => 'Cannot be empty';

  @override
  String get usernameLength => 'Must be 3-20 characters';
}

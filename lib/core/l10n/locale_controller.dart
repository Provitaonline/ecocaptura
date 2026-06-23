import 'package:flutter/material.dart';

class LocaleController {
  // Private constructor for singleton pattern
  LocaleController._internal();
  static final LocaleController instance = LocaleController._internal();

  // The notifier that widgets can listen to for changes. 
  // Passing null lets it fallback automatically to the device's native system language.
  final ValueNotifier<Locale?> localeNotifier = ValueNotifier<Locale?>(null);

  // Quick helper to change the language explicitly
  void setLocale(Locale? locale) {
    localeNotifier.value = locale;
  }
}
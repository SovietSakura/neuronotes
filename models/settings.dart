// models/settings.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsModel extends ChangeNotifier {
  Locale _locale = Locale('zh', 'CN');
  String _aiModel = 'gpt-4';
  String _apiKey = '';
  String _apiBaseUrl = 'https://api.openai.com/v1';

  Locale get locale => _locale;
  String get aiModel => _aiModel;
  String get apiKey => _apiKey;
  String get apiBaseUrl => _apiBaseUrl;

  SettingsModel() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final language = prefs.getString('language') ?? 'zh';
    final country = prefs.getString('country') ?? 'CN';
    _locale = Locale(language, country);
    _aiModel = prefs.getString('aiModel') ?? 'gpt-4';
    _apiKey = prefs.getString('apiKey') ?? '';
    _apiBaseUrl = prefs.getString('apiBaseUrl') ?? 'https://api.openai.com/v1';
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', locale.languageCode);
    await prefs.setString('country', locale.countryCode!);
    notifyListeners();
  }

  Future<void> setAiModel(String model) async {
    _aiModel = model;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('aiModel', model);
    notifyListeners();
  }

  Future<void> setApiKey(String key) async {
    _apiKey = key;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('apiKey', key);
    notifyListeners();
  }

  Future<void> setApiBaseUrl(String url) async {
    _apiBaseUrl = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('apiBaseUrl', url);
    notifyListeners();
  }
}
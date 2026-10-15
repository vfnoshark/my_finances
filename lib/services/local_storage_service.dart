import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  // Синглтон
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  static const String _animalsKey = 'animals_list';
  static const String _pinKey = 'user_pin';
  static const String _loggedInKey = 'is_logged_in';
  static const String _loginKey = 'user_login';
  static const String _nameKey = 'user_name';
  static const String _versionKey = 'storage_version';
  static const String _darkThemeKey = 'dark_theme_enabled';

  static const int _currentVersion = 2;

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<void> _ensureVersion() async {
    final prefs = await _prefs;
    final version = prefs.getInt(_versionKey) ?? 0;

    if (version < _currentVersion) {
      await prefs.remove(_animalsKey);
      await prefs.setInt(_versionKey, _currentVersion);
    }
  }

  // ==================== ЖИВОТНЫЕ ====================

  Future<List<Map<String, dynamic>>> loadAnimals() async {
    await _ensureVersion();
    final prefs = await _prefs;
    final raw = prefs.getString(_animalsKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveAnimals(List<Map<String, dynamic>> animals) async {
    final prefs = await _prefs;
    final raw = jsonEncode(animals);
    await prefs.setString(_animalsKey, raw);
  }

  // ==================== АВТОРИЗАЦИЯ ====================

  Future<void> savePin(String pin) async {
    final prefs = await _prefs;
    await prefs.setString(_pinKey, pin);
  }

  Future<String?> getPin() async {
    final prefs = await _prefs;
    return prefs.getString(_pinKey);
  }

  Future<void> setLoggedIn(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_loggedInKey, value);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await _prefs;
    return prefs.getBool(_loggedInKey) ?? false;
  }

  Future<void> saveUser({required String login, required String name}) async {
    final prefs = await _prefs;
    await prefs.setString(_loginKey, login);
    await prefs.setString(_nameKey, name);
  }

  Future<String> getUserLogin() async {
    final prefs = await _prefs;
    return prefs.getString(_loginKey) ?? '';
  }

  Future<String> getUserName() async {
    final prefs = await _prefs;
    return prefs.getString(_nameKey) ?? '';
  }

  // ==================== ТЕМА ====================

  Future<void> setDarkTheme(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_darkThemeKey, value);
  }

  Future<bool?> getDarkTheme() async {
    final prefs = await _prefs;
    return prefs.getBool(_darkThemeKey);
  }

  Future<void> clearTheme() async {
    final prefs = await _prefs;
    await prefs.remove(_darkThemeKey);
  }

  // ==================== ОБЩЕЕ ====================

  Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.remove(_animalsKey);
    await prefs.remove(_pinKey);
    await prefs.remove(_loggedInKey);
    await prefs.remove(_loginKey);
    await prefs.remove(_nameKey);
    await prefs.remove(_versionKey);
    await prefs.remove(_darkThemeKey);
  }

  Future<void> clearAnimals() async {
    final prefs = await _prefs;
    await prefs.remove(_animalsKey);
  }
}
import '../models/user.dart';
import 'local_storage_service.dart';

class AuthService {
  // Синглтон
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final LocalStorageService _storage = LocalStorageService();

  User? _currentUser;
  User? get currentUser => _currentUser;

  Future<User> login(String login, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (login == 'admin' && password == '12345') {
      final user = User(
        login: login,
        name: 'Администратор',
        token: 'mock_token_12345',
      );
      _currentUser = user;
      return user;
    } else {
      throw Exception('Неверный логин или пароль');
    }
  }

  Future<void> savePinAndLogin(String pin, User user) async {
    await _storage.savePin(pin);
    await _storage.setLoggedIn(true);
    await _storage.saveUser(login: user.login, name: user.name ?? '');
  }

  Future<bool> isLoggedIn() async {
    return _storage.isLoggedIn();
  }

  Future<bool> hasPin() async {
    final pin = await _storage.getPin();
    return pin != null && pin.isNotEmpty;
  }

  Future<bool> verifyPin(String pin) async {
    final saved = await _storage.getPin();
    return saved == pin;
  }

  Future<String> getUserName() async {
    final name = await _storage.getUserName();
    return name.isEmpty ? 'Пользователь' : name;
  }

  Future<String> getUserLogin() async {
    return _storage.getUserLogin();
  }

  Future<void> logout() async {
    _currentUser = null;
    await _storage.clearAll();
  }
}
import 'package:flutter_test/flutter_test.dart';
import 'package:somenotes/services/auth/auth_exceptions.dart';
import 'package:somenotes/services/auth/auth_provider.dart';
import 'package:somenotes/services/auth/auth_user.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();
    test('MockAuthProvider should not be initialized', () {
      expect(provider.isInitalized, false);
    });

    test('cannot log out if not initialized', () {
      expect(provider.logout(), throwsA(isA<NotInitializedException>()));
    });

    test('should be able to be initialized', () async {
      await provider.initialize();
      expect(provider.isInitalized, true);
    });

    test('user should be null after initialization', () {
      expect(provider.currentUser, null);
    });

    test('should be able to initialize in less than 2 seconds', () async {
      await provider.initialize();
      expect(provider.isInitalized, true);
    }, timeout: const Timeout(Duration(seconds: 2)));

    test('should throw error for bad email', () async {
      await provider.initialize();
      final badEmailUser = await provider.createUser(
          email: 'somebullshitassemail@gmail.com', password: 'fuck');

      expect(badEmailUser, throwsA(isA<UserNotFoundAuthException>()));
    });

    test('should throw error for bad password', () async {
      await provider.initialize();
      final badPasswordUser = await provider.createUser(
          email: 'cum@gmail.com', password: 'somebullshitasspassword');

      expect(badPasswordUser,
          throwsA(const TypeMatcher<UserNotFoundAuthException>()));
    });

    test('should login a good user', () async {
      await provider.initialize();
      final user = await provider.createUser(email: 'cum', password: 'fart');

      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });

    test('logged in user should be able to get verified', () async {
      await provider.initialize();
      final user = await provider.createUser(email: 'cum', password: 'fart');
      await provider.sendEmailVerification();
      expect(user, isNotNull);
      expect(provider.currentUser!.isEmailVerified, true);
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitalized => _isInitialized;

  @override
  Future<AuthUser> createUser(
      {required String email, required String password}) async {
    if (!isInitalized) throw NotInitializedException();
    await Future.delayed(const Duration(milliseconds: 500));
    return login(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> login({required String email, required String password}) {
    if (!isInitalized) throw NotInitializedException();
    if (email == 'somebullshitassemail@gmail.com') {
      throw UserNotFoundAuthException();
    }
    if (password == 'somebullshitasspassword') {
      throw WrongPasswordAuthException();
    }
    const user = AuthUser(isEmailVerified: false, email: 'email@email.com');
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logout() async {
    if (!isInitalized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(milliseconds: 500));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitalized) throw NotInitializedException();
    final user = _user;
    if (_user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(isEmailVerified: true, email: 'go@away.com');
    _user = newUser;
  }
}

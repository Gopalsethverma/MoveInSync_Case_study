import 'dart:async';
import '../models/user.dart';

class AuthService {
  // Mock
  final List<User> _users = [
    User(
      id: '1',
      name: 'Admin User',
      email: 'admin@example.com',
      role: 'admin',
    ),
    User(
      id: '2',
      name: 'Employee User',
      email: 'user@example.com',
      role: 'employee',
    ),
  ];

  Future<User> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    if (password == 'password123') {
      try {
        return _users.firstWhere((u) => u.email == email);
      } catch (e) {
        throw Exception('User not found');
      }
    } else {
      throw Exception('Invalid password');
    }
  }

  Future<User> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      role: role,
    );
    _users.add(newUser);
    return newUser;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/local_storage_service.dart';

class UserState {
  final int? id;
  final String? username;
  final String? token;
  final String? role;

  UserState({this.id, this.username, this.token, this.role});

  bool get isAuthenticated => token != null;
}

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(UserState()) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final token = LocalStorageService.read('auth_token');
    final id = LocalStorageService.read('user_id');
    final role = LocalStorageService.read('user_role');
    final username = LocalStorageService.read('user_username');

    if (token != null) {
      state = UserState(id: id, username: username, token: token, role: role);
    }
  }

  Future<void> login(int id, String username, String token, String role) async {
    await LocalStorageService.save('auth_token', token);
    await LocalStorageService.save('user_id', id);
    await LocalStorageService.save('user_role', role);
    await LocalStorageService.save('user_username', username);
    state = UserState(id: id, username: username, token: token, role: role);
  }

  Future<void> logout() async {
    await LocalStorageService.delete('auth_token');
    await LocalStorageService.delete('user_id');
    await LocalStorageService.delete('user_role');
    await LocalStorageService.delete('user_username');
    state = UserState();
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});

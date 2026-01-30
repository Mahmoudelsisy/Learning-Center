import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../services/notification_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _userModel;
  bool _isLoading = true;

  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _authService.userStream.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _userModel = null;
    } else {
      _userModel = await _authService.getUserData(firebaseUser.uid);
      if (_userModel != null) {
        NotificationService().initialize(_userModel!.uid);
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    UserCredential? result = await _authService.signIn(email, password);
    _isLoading = false;
    notifyListeners();
    return result != null;
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    required String phone,
  }) async {
    _isLoading = true;
    notifyListeners();
    UserCredential? result = await _authService.signUp(
      email: email,
      password: password,
      name: name,
      role: role,
      phone: phone,
    );
    _isLoading = false;
    notifyListeners();
    return result != null;
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}

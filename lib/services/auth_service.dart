import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Stream<User?> get userStream => _auth.authStateChanges();

  Future<UserCredential?> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    required String phone,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        UserModel newUser = UserModel(
          uid: user.uid,
          name: name,
          email: email,
          role: role,
          phone: phone,
          createdAt: DateTime.now(),
        );

        await _dbRef.child('users').child(user.uid).set(newUser.toMap());
      }
      return result;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<UserCredential?> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<UserModel?> getUserData(String uid) async {
    DataSnapshot snapshot = await _dbRef.child('users').child(uid).get();
    if (snapshot.exists) {
      return UserModel.fromMap(snapshot.value as Map, uid);
    }
    return null;
  }
}

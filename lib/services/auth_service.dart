import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

ValueNotifier<AuthService> authService = ValueNotifier(AuthService());

Future<void> createMongoUser(String idToken) async {
  final response = await http.post(
    Uri.parse("https://tu-backend.com/app/users"), // Cambia al dominio real
    headers: {
      "Authorization": "Bearer $idToken",
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Error al crear usuario en MongoDB: ${response.body}');
  }
}

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  Future<void> resetPassword({required String email}) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  // ✅ MÉTODO CORREGIDO
  Future<void> updateUsername({required String username}) async {
    final user = currentUser;
    if (user != null) {
      await user.updateDisplayName(username);
      await user.reload(); // 🔥 ESTO ES LO QUE FALTABA
      // Opcionalmente, puedes notificar el cambio
      authService.notifyListeners();
    }
  }

  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    final user = currentUser;
    if (user != null) {
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      await user.delete();
      await firebaseAuth.signOut();
    } else {
      throw FirebaseAuthException(
        code: 'no-user',
        message: 'No user is currently signed in.',
      );
    }
  }

  Future<void> resetPasswordFromCurrentPassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = firebaseAuth.currentUser;

    if (user != null) {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } else {
      throw FirebaseAuthException(
        code: 'no-user',
        message: 'No user is currently signed in.',
      );
    }
  }
}
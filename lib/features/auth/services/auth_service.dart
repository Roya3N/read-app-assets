import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==========================================
  // ⚙️ Security Settings (Brute-Force Protection)
  // ==========================================
  static const int _maxFailedAttempts = 5;
  static const int _lockoutDurationSeconds = 30;

  // ==========================================
  // 1. Sign Up (Parent)
  // ==========================================
  Future<String?> signUpParent({
    required String email,
    required String password,
    required String name,
    required String dob,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        try {
          await user.sendEmailVerification();
          debugPrint("✅ Verification email sent to: $email");
        } catch (emailError) {
          debugPrint("❌ Failed to send email: $emailError");
        }

        await _db.collection('parents').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': email,
          'dob': dob,
          'createdAt': FieldValue.serverTimestamp(),
          'role': 'parent',
        });

        return null;
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("🔥 Firebase Auth Error: ${e.code} - ${e.message}");
      return e.message;
    } catch (e) {
      debugPrint("⚠️ Unknown Error: $e");
      return e.toString();
    }
    return "An unknown error occurred.";
  }

  // ==========================================
  // 2. Sign In (with Brute-Force Lock 🛡️)
  // ==========================================
  Future<String?> signIn(String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int failedAttempts = prefs.getInt('failed_attempts_$email') ?? 0;
    String? lockoutTimeString = prefs.getString('lockout_until_$email');

    // 🛑 Check if account is currently locked
    if (lockoutTimeString != null) {
      DateTime lockoutUntil = DateTime.parse(lockoutTimeString);
      if (DateTime.now().isBefore(lockoutUntil)) {
        final secondsLeft = lockoutUntil.difference(DateTime.now()).inSeconds;
        return "🚨 Login is locked due to repeated failed attempts. Please try again in $secondsLeft seconds.";
      } else {
        // Lock expired, reset attempts
        await prefs.setInt('failed_attempts_$email', 0);
        await prefs.remove('lockout_until_$email');
        failedAttempts = 0;
      }
    }

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // ✅ Success: Reset failed attempts
      await prefs.setInt('failed_attempts_$email', 0);
      return null;
    } on FirebaseAuthException catch (e) {
      // ❌ Failed: Increment attempt counter
      failedAttempts++;

      if (failedAttempts >= _maxFailedAttempts) {
        // Trigger 30-second lockout
        DateTime lockUntil = DateTime.now().add(
          const Duration(seconds: _lockoutDurationSeconds),
        );
        await prefs.setString(
          'lockout_until_$email',
          lockUntil.toIso8601String(),
        );
        return "🚨 Too many failed attempts! For your security, login has been locked for 30 seconds.";
      } else {
        await prefs.setInt('failed_attempts_$email', failedAttempts);
      }
      return e.message;
    }
  }

  // ==========================================
  // 3. Reset Password
  // ==========================================
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ==========================================
  // 4. Sign Out
  // ==========================================
  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}

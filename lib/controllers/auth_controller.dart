import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthController with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;
  UserModel? get appUser => _currentUser;

  User? get firebaseUser => _auth.currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // 🔐 SIGN UP
  Future<void> signUp(String name, String email, String password) async {
    setLoading(true);
    _setError(null);
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;

      _currentUser = UserModel(
        uid: uid,
        name: name,
        email: email,
        imageUrl: '', // Default value for now
        phone: '',
        country: '',
        location: '',
      );

      await _firestore.collection("users").doc(uid).set(_currentUser!.toMap());
    } on FirebaseAuthException catch (e) {
      _setError(e.message);
    } finally {
      setLoading(false);
    }
  }

  // 🔐 SIGN IN
  Future<void> signIn(String email, String password) async {
    setLoading(true);
    _setError(null);
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final doc = await _firestore.collection("users").doc(credential.user!.uid).get();
      _currentUser = UserModel.fromMap(doc.data()!);
    } on FirebaseAuthException catch (e) {
      _setError(e.message);
    } finally {
      setLoading(false);
    }
  }

  // 🔐 GOOGLE SIGN-IN
  Future<void> signInWithGoogle() async {
    setLoading(true);
    _setError(null);
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        _setError("Google Sign-In cancelled.");
        setLoading(false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final uid = userCredential.user!.uid;

      final name = userCredential.user!.displayName ?? "No Name";
      final email = userCredential.user!.email ?? "No Email";
      final imageUrl = userCredential.user!.photoURL ?? "";

      _currentUser = UserModel(
        uid: uid,
        name: name,
        email: email,
        imageUrl: imageUrl,
        phone: '',
        country: '',
        location: '',
      );

      final doc = await _firestore.collection("users").doc(uid).get();
      if (!doc.exists) {
        await _firestore.collection("users").doc(uid).set(_currentUser!.toMap());
      } else {
        _currentUser = UserModel.fromMap(doc.data()!);
      }
    } on FirebaseAuthException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError("Unexpected error: $e");
    } finally {
      setLoading(false);
    }
  }

  // 🚪 SIGN OUT
  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  // ✏️ UPDATE USER DATA
  Future<void> updateUserData(UserModel updatedUser) async {
    try {
      await _firestore.collection("users").doc(updatedUser.uid).update(updatedUser.toMap());
      _currentUser = updatedUser;
      notifyListeners();
    } catch (e) {
      _setError("Failed to update user data.");
    }
  }

  // 🔁 FORGOT PASSWORD
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      _setError(e.message);
    }
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static String currentSessionId = '';

  String _generateSessionId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<String?> signUpUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await cred.user!.sendEmailVerification();
      currentSessionId = _generateSessionId();

      UserModel user = UserModel(
        uid: cred.user!.uid,
        name: name,
        email: email,
        createdAt: DateTime.now(),
        sessionId: currentSessionId,
      );

      await _firestore.collection('users').doc(cred.user!.uid).set(user.toMap());
      return "success";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'Yeh email pehle se registered hai';
      }
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      currentSessionId = _generateSessionId();
      await _firestore.collection('users').doc(cred.user!.uid).update({
        'sessionId': currentSessionId,
      });

      return "success";
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> updateSessionForAutoLogin() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      currentSessionId = _generateSessionId();
      await _firestore.collection('users').doc(currentUser.uid).update({
        'sessionId': currentSessionId,
      });
    }
  }

  Future<void> logoutUser() async {
    await _auth.signOut();
  }
}
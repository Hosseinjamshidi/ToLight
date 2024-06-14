import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todark/app/data/models.dart' as app_models;
import 'package:todark/main.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'displayName': user.displayName ?? '',
        });

        // Create initial settings document for the new user
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('settings')
            .doc('settings')
            .set({
          'id': DateTime.now().millisecondsSinceEpoch,
          'onboard': false,
          'theme': 'system',
          'amoledTheme': false,
          'materialColor': false,
          'isImage': true,
          'timeformat': '24',
          'firstDay': 'monday',
          'language': 'en_US',
          'userId': user.uid,
        });

        // Initialize settings after registration
        await _initSettings(user.uid);
      }

      return user;
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      if (user != null) {
        // Initialize settings after login
        await _initSettings(user.uid);
      }

      return user;
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (error) {
      print(error.toString());
    }
  }

  User? get currentUser {
    return _auth.currentUser;
  }

  Future<void> _initSettings(String userId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot settingsSnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('settings')
        .doc('settings')
        .get();

    if (settingsSnapshot.exists) {
      settings = app_models.Settings.fromFirestore(
          settingsSnapshot.data() as Map<String, dynamic>);
    } else {
      settings = app_models.Settings(
        id: DateTime.now().millisecondsSinceEpoch,
        onboard: false,
        theme: 'system',
        amoledTheme: false,
        materialColor: false,
        isImage: true,
        timeformat: '24',
        firstDay: 'monday',
        language: 'en_US',
        userId: userId,
      );
      await firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('settings')
          .set(settings!.toFirestore());
    }
  }
}

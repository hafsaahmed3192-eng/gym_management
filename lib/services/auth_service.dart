import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'referral_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;
  final ReferralService _referralService =
      ReferralService();

  Future<User?> signUp({
    required String name,
    required String email,
    required String password,
    String? referralCode, // ← NEW optional param
  }) async {
    // 1. Create Firebase Auth account
    UserCredential userCredential =
        await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = userCredential.user!.uid;

    // 2. Generate a unique referral code for this new user
    final newUserCode =
        _referralService.generateReferralCode(name);

    // 3. Create user document in Firestore
    await _firestore
        .collection('users')
        .doc(uid)
        .set({
      'name': name,
      'email': email,
      'role': 'member',
      'createdAt': Timestamp.now(),
      'referralCode': newUserCode, // ← NEW
      'points': 0,                 // ← NEW
      'referredBy': null,          // ← set below if code used
    });

    // 4. Process referral code if one was entered
    if (referralCode != null &&
        referralCode.trim().isNotEmpty) {
      final referrerId =
          await _referralService.validateReferralCode(
        code: referralCode.trim(),
        newUserId: uid,
      );

      if (referrerId != null) {
        // Valid code — credit both users
        await _referralService.processAppReferral(
          referrerId: referrerId,
          newUserId: uid,
          newUserName: name,
          referralCode:
              referralCode.trim().toUpperCase(),
        );
      }
      // If code is invalid, we silently ignore —
      // no error shown, signup proceeds normally.
    }

    return userCredential.user;
  }

  Future<User?> login({
    required String email,
    required String password,
  }) async {
    UserCredential userCredential =
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  Future<void> saveActivityLevel(String level) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'activityLevel': level});
    }
  }

  Future<void> saveHeight(int height) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'height': height});
    }
  }

  Future<void> saveGoal(String goal) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'goal': goal});
    }
  }

  Future<void> saveWeight(double weight) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'weight': weight});
    }
  }

  Future<void> saveAge(int age) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'age': age});
    }
  }

  Future<void> saveGender(String gender) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'gender': gender});
    }
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
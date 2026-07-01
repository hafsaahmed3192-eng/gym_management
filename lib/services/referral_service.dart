import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

// ─────────────────────────────────────────────
// POINTS CONSTANTS
// ─────────────────────────────────────────────
const int kAppReferralPoints  = 100; // referrer gets this when friend signs up
const int kGymReferralPoints  = 500; // referrer gets this when gym referral verified
const int kWelcomeBonusPoints = 50;  // new user gets this for using a referral code

class ReferralService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  //////////////////////////////////////////////////////
  /// GENERATE UNIQUE REFERRAL CODE
  /// Format: FIRSTNAME-XXXX (e.g. "HAFSA-K7X2")
  //////////////////////////////////////////////////////

  String generateReferralCode(String name) {
    final firstName =
        name.trim().split(' ').first.toUpperCase();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();
    final suffix = List.generate(
        4, (_) => chars[rand.nextInt(chars.length)]).join();
    return '$firstName-$suffix';
  }

  //////////////////////////////////////////////////////
  /// VALIDATE REFERRAL CODE
  /// Returns the referrer's userId if code is valid,
  /// null if invalid or self-referral.
  //////////////////////////////////////////////////////

  Future<String?> validateReferralCode({
    required String code,
    required String newUserId,
  }) async {
    if (code.trim().isEmpty) return null;

    try {
      final query = await _firestore
          .collection('users')
          .where('referralCode',
              isEqualTo: code.trim().toUpperCase())
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;

      final referrerDoc = query.docs.first;
      final referrerId = referrerDoc.id;

      // Prevent self-referral
      if (referrerId == newUserId) return null;

      return referrerId;
    } catch (e) {
      debugPrint('[ReferralService] validateReferralCode error: $e');
      return null;
    }
  }

  //////////////////////////////////////////////////////
  /// PROCESS APP REFERRAL
  /// Called after a new user signs up with a valid code.
  /// Credits points to referrer + welcome bonus to new user.
  //////////////////////////////////////////////////////

  Future<void> processAppReferral({
    required String referrerId,
    required String newUserId,
    required String newUserName,
    required String referralCode,
  }) async {
    final batch = _firestore.batch();

    // ── Credit referrer ──
    final referrerRef =
        _firestore.collection('users').doc(referrerId);
    batch.update(referrerRef, {
      'points': FieldValue.increment(kAppReferralPoints),
    });

    // Referrer's points history entry
    final referrerHistoryRef =
        referrerRef.collection('pointsHistory').doc();
    batch.set(referrerHistoryRef, {
      'type': 'earned',
      'reason': 'app_referral',
      'points': kAppReferralPoints,
      'description':
          '$newUserName joined using your referral code',
      'createdAt': Timestamp.now(),
    });

    // Referrer's referrals list entry
    final referrerReferralRef =
        referrerRef.collection('referrals').doc();
    batch.set(referrerReferralRef, {
      'type': 'app',
      'referredName': newUserName,
      'status': 'verified',
      'pointsAwarded': kAppReferralPoints,
      'createdAt': Timestamp.now(),
    });

    // ── Credit new user (welcome bonus) ──
    final newUserRef =
        _firestore.collection('users').doc(newUserId);
    batch.update(newUserRef, {
      'points': FieldValue.increment(kWelcomeBonusPoints),
      'referredBy': referralCode,
    });

    final newUserHistoryRef =
        newUserRef.collection('pointsHistory').doc();
    batch.set(newUserHistoryRef, {
      'type': 'earned',
      'reason': 'welcome_bonus',
      'points': kWelcomeBonusPoints,
      'description': 'Welcome bonus for joining via referral',
      'createdAt': Timestamp.now(),
    });

    await batch.commit();
    debugPrint(
        '[ReferralService] App referral processed — referrer: $referrerId, new user: $newUserId');
  }

  //////////////////////////////////////////////////////
  /// SUBMIT GYM REFERRAL
  /// User nominates a friend who they say will join
  /// the gym physically. Goes to admin for verification.
  //////////////////////////////////////////////////////

  Future<void> submitGymReferral({
    required String referredName,
    required String referredPhone,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not authenticated');

    // Get referrer's name for admin display
    final userDoc = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();
    final userName = userDoc.data()?['name'] ?? 'Unknown';

    final batch = _firestore.batch();

    // ── User's own referrals subcollection ──
    final userReferralRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('referrals')
        .doc();

    batch.set(userReferralRef, {
      'type': 'gym',
      'referredName': referredName,
      'referredPhone': referredPhone,
      'status': 'pending',
      'pointsAwarded': 0,
      'createdAt': Timestamp.now(),
    });

    // ── Top-level adminReferrals collection ──
    // Admin reads from here to verify and approve
    final adminReferralRef =
        _firestore.collection('adminReferrals').doc();
    batch.set(adminReferralRef, {
      'userId': user.uid,
      'userName': userName,
      'userReferralDocId': userReferralRef.id,
      'referredName': referredName,
      'referredPhone': referredPhone,
      'status': 'pending',
      'createdAt': Timestamp.now(),
    });

    await batch.commit();
    debugPrint(
        '[ReferralService] Gym referral submitted for: $referredName');
  }

  //////////////////////////////////////////////////////
  /// ADMIN: VERIFY GYM REFERRAL
  /// Called from an admin panel/screen.
  /// Awards points to the referrer and marks verified.
  //////////////////////////////////////////////////////

  Future<void> verifyGymReferral({
    required String adminReferralDocId,
    required String userId,
    required String userReferralDocId,
    required String referredName,
  }) async {
    final batch = _firestore.batch();

    // ── Mark admin doc as verified ──
    final adminRef = _firestore
        .collection('adminReferrals')
        .doc(adminReferralDocId);
    batch.update(adminRef, {'status': 'verified'});

    // ── Mark user's referral doc as verified ──
    final userReferralRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('referrals')
        .doc(userReferralDocId);
    batch.update(userReferralRef, {
      'status': 'verified',
      'pointsAwarded': kGymReferralPoints,
    });

    // ── Award points to user ──
    final userRef =
        _firestore.collection('users').doc(userId);
    batch.update(userRef, {
      'points': FieldValue.increment(kGymReferralPoints),
    });

    // ── Points history entry ──
    final historyRef = userRef
        .collection('pointsHistory')
        .doc();
    batch.set(historyRef, {
      'type': 'earned',
      'reason': 'gym_referral',
      'points': kGymReferralPoints,
      'description':
          '$referredName joined the gym — referral verified!',
      'createdAt': Timestamp.now(),
    });

    await batch.commit();
    debugPrint(
        '[ReferralService] Gym referral verified for user: $userId');
  }

  //////////////////////////////////////////////////////
  /// GET CURRENT USER'S POINTS BALANCE
  //////////////////////////////////////////////////////

  Future<int> getUserPoints() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 0;

    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    return (doc.data()?['points'] ?? 0).toInt();
  }

  /// Live stream of current points balance
  Stream<int> watchUserPoints() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value(0);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) =>
            (doc.data()?['points'] ?? 0).toInt());
  }

  //////////////////////////////////////////////////////
  /// GET USER'S REFERRAL CODE
  /// Creates one if it doesn't exist yet (migration
  /// safety for existing users created before this
  /// feature was added).
  //////////////////////////////////////////////////////

  Future<String> getOrCreateReferralCode(
      String userName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    final existing =
        doc.data()?['referralCode'] as String?;
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    // Generate and save a new code
    final newCode = generateReferralCode(userName);
    await _firestore
        .collection('users')
        .doc(user.uid)
        .update({'referralCode': newCode});

    return newCode;
  }
}
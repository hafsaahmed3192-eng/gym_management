import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/avatar_model.dart';

class UserProvider extends ChangeNotifier {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  Future<void> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      isLoading = false;
      notifyListeners();
      return;
    }

    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await docRef.get();
    final data = doc.data();

    // Self-heal any legacy .png avatar path left over from before the fix
    final avatar = data?['avatar'] as String?;
    if (avatar != null &&
        avatar.endsWith('.png') &&
        (avatar.contains('male') || avatar.contains('female'))) {
      final fixed = avatar.replaceAll('.png', '.jpg');
      await docRef.update({'avatar': fixed});
      data!['avatar'] = fixed;
      debugPrint('Fixed legacy avatar path: $avatar -> $fixed');
    }

    userData = data;
    isLoading = false;
    notifyListeners();
  }

  Future<void> updateAvatar(String avatarPath) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set({'avatar': avatarPath}, SetOptions(merge: true));

    userData ??= {};
    userData!['avatar'] = avatarPath;
    notifyListeners();
  }

  /// Call this on logout so the next user's data doesn't leak into the UI.
  void clear() {
    userData = null;
    isLoading = true;
    notifyListeners();
  }

  String get avatarPath {
    final saved = userData?['avatar'] as String?;
    if (saved != null && saved.isNotEmpty) return saved;

    final gender = userData?['gender'] as String?;
    return gender?.toLowerCase() == 'female'
        ? AvatarData.defaultFemale
        : AvatarData.defaultMale;
  }
}
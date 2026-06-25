import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'login_screen.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  File? _imageFile;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  //////////////////////////////////////////////////////
  /// FETCH USER DATA
  //////////////////////////////////////////////////////
  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      setState(() {
        userData = doc.data();
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }
  //////////////////////////////////////////////////////
  /// IMAGE PICK
  //////////////////////////////////////////////////////
  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 75,
    );

    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });

      await _uploadImage();
    }
  }

  //////////////////////////////////////////////////////
  /// UPLOAD IMAGE
  //////////////////////////////////////////////////////
  Future<void> _uploadImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _imageFile == null) return;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images/${user.uid}.jpg');

      print("Uploading image...");

      await storageRef.putFile(_imageFile!);

      final downloadUrl = await storageRef.getDownloadURL();

      print("Download URL: $downloadUrl");

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(
        {'profileImage': downloadUrl},
        SetOptions(merge: true),
      );

      print("Saved to Firestore ✅");

      setState(() {
        userData?['profileImage'] = downloadUrl;
      });

    } catch (e) {
      print("UPLOAD ERROR: $e");
    }
  }
  //////////////////////////////////////////////////////
  /// SHOW OPTIONS (Camera / Gallery)
  //////////////////////////////////////////////////////
  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1F26),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt,
                  color: Color(0xFFFFD700)),
              title: const Text("Take Photo",
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library,
                  color: Color(0xFFFFD700)),
              title: const Text("Choose from Gallery",
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  //////////////////////////////////////////////////////
  /// UI
  //////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return Scaffold(

    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(

          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          "My Profile",
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFFFD700)),
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFFD700),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            //////////////////////////////////////////////////////
            /// PROFILE IMAGE
            //////////////////////////////////////////////////////
            GestureDetector(
              onTap: _showImageOptions,
              child:CircleAvatar(
                radius: 55,
                backgroundColor: const Color(0xFF1C1F26),
                backgroundImage: _imageFile != null
                    ? FileImage(_imageFile!)
                    : (userData?['profileImage'] != null
                    ? NetworkImage(userData!['profileImage'])
                    : null) as ImageProvider?,
                child: _imageFile == null && userData?['profileImage'] == null
                    ? const Icon(
                  Icons.add_a_photo,
                  size: 35,
                  color: Color(0xFFFFD700),
                )
                    : null,
              ),
            ),

            const SizedBox(height: 15),

            Text(
              userData?['name'] ?? "Athlete",
              style: const TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              userData?['email'] ?? "",
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            //////////////////////////////////////////////////////
            /// STATS CARD
            //////////////////////////////////////////////////////
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _buildInfoRow("Age",
                      userData?['age']?.toString()),
                  _buildInfoRow(
                      "Weight",
                      userData?['weight'] != null
                          ? "${userData?['weight']} kg"
                          : "--"),
                  _buildInfoRow(
                      "Height",
                      userData?['height'] != null
                          ? "${userData?['height']} cm"
                          : "--"),
                  _buildInfoRow("Goal",
                      userData?['goal']),
                  _buildInfoRow("Activity Level",
                      userData?['activityLevel']),
                ],
              ),
            ),

            const SizedBox(height: 30),

            //////////////////////////////////////////////////////
            /// ALL MENU OPTIONS
            //////////////////////////////////////////////////////

            _buildMenuItem(Icons.dark_mode, "Theme", () {
              Provider.of<ThemeProvider>(context, listen: false)
                  .toggleTheme();
            }),
            _buildMenuItem(Icons.favorite, "Favorite", () {}),

            _buildMenuItem(Icons.lock, "Privacy Policy", () {}),

            _buildMenuItem(Icons.settings, "Settings", () {}),

            _buildMenuItem(Icons.help, "Help", () {}),

            _buildMenuItem(
              Icons.logout,
              "Logout",
                  () async {
                await FirebaseAuth.instance.signOut();
                if (!mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                      const LoginScreen()),
                      (route) => false,
                );
              },
              isLogout: true,
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  //////////////////////////////////////////////////////
  /// INFO ROW
  //////////////////////////////////////////////////////
  Widget _buildInfoRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.grey)),
          Text(
            value ?? "--",
            style: const TextStyle(
              color: Color(0xFFFFD700),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  //////////////////////////////////////////////////////
  /// MENU ITEM
  //////////////////////////////////////////////////////
  Widget _buildMenuItem(
      IconData icon,
      String title,
      VoidCallback onTap, {
        bool isLogout = false,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F26),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF0D0F14),
          ),
          child: Icon(
            icon,
            color: isLogout
                ? Colors.red
                : const Color(0xFFFFD700),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isLogout
                ? Colors.red
                : Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}
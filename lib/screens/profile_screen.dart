import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/user_provider.dart';
import 'avatar_picker_sheet.dart';
import 'login_screen.dart';
import 'theme_provider.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  //////////////////////////////////////////////////////
  /// UI
  //////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = context.watch<UserProvider>();
    final userData = userProvider.userData;
    final isLoading = userProvider.isLoading;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          "My Profile",
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: theme.colorScheme.primary,
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            //////////////////////////////////////////////////////
            /// PROFILE AVATAR (tap to pick from 6)
            //////////////////////////////////////////////////////
            GestureDetector(
              onTap: () => showAvatarPicker(context),
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: theme.cardColor,
                    backgroundImage: AssetImage(userProvider.avatarPath),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primary,
                        border: Border.all(
                          color: theme.scaffoldBackgroundColor,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            Text(
              userData?['name'] ?? "Athlete",
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              userData?['email'] ?? "",
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),

            const SizedBox(height: 30),

            //////////////////////////////////////////////////////
            /// STATS CARD
            //////////////////////////////////////////////////////
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _buildInfoRow(context, "Age", userData?['age']?.toString()),
                  _buildInfoRow(
                      context,
                      "Weight",
                      userData?['weight'] != null
                          ? "${userData?['weight']} kg"
                          : "--"),
                  _buildInfoRow(
                      context,
                      "Height",
                      userData?['height'] != null
                          ? "${userData?['height']} cm"
                          : "--"),
                  _buildInfoRow(context, "Goal", userData?['goal']),
                  _buildInfoRow(
                      context, "Activity Level", userData?['activityLevel']),
                ],
              ),
            ),

            const SizedBox(height: 30),

            //////////////////////////////////////////////////////
            /// MENU OPTIONS
            //////////////////////////////////////////////////////
            _buildMenuItem(context, Icons.dark_mode, "Theme", () {
              Provider.of<ThemeProvider>(context, listen: false)
                  .toggleTheme();
            }),
            _buildMenuItem(context, Icons.favorite, "Favorite", () {}),
            _buildMenuItem(context, Icons.lock, "Privacy Policy", () {}),
            _buildMenuItem(context, Icons.settings, "Settings", () {}),
            _buildMenuItem(context, Icons.help, "Help", () {}),
            _buildMenuItem(
              context,
              Icons.logout,
              "Logout",
                  () async {
                context.read<UserProvider>().clear();
                await FirebaseAuth.instance.signOut();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                );
              },
              isLogout: true,
            ),
          ],
        ),
      ),
    );
  }

  //////////////////////////////////////////////////////
  /// INFO ROW
  //////////////////////////////////////////////////////
  Widget _buildInfoRow(BuildContext context, String title, String? value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          Text(
            value ?? "--",
            style: TextStyle(
              color: theme.colorScheme.primary,
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
      BuildContext context,
      IconData icon,
      String title,
      VoidCallback onTap, {
        bool isLogout = false,
      }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.scaffoldBackgroundColor,
          ),
          child: Icon(
            icon,
            color: isLogout ? Colors.red : theme.colorScheme.primary,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isLogout ? Colors.red : theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: theme.colorScheme.onSurface.withOpacity(0.4),
        ),
        onTap: onTap,
      ),
    );
  }
}
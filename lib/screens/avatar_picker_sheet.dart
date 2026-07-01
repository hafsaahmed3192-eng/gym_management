import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/avatar_model.dart';
import '../services/user_provider.dart';


void showAvatarPicker(BuildContext context) {
  final userProvider = context.read<UserProvider>();
  final gender = userProvider.userData?['gender'] as String?;
  final avatars = AvatarData.avatarsForGender(gender);
  final theme = Theme.of(context);
  final currentAvatar = userProvider.avatarPath;

  showModalBottomSheet(
    context: context,
    backgroundColor: theme.cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Choose your avatar",
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: avatars.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemBuilder: (context, index) {
              final path = avatars[index];
              final isSelected = path == currentAvatar;

              return GestureDetector(
                onTap: () {
                  userProvider.updateAvatar(path);
                  Navigator.pop(context);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor: theme.scaffoldBackgroundColor,
                        backgroundImage: AssetImage(path),
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(height: 4),
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gym_management/screens/goal_selection_screen.dart';
import '../services/auth_service.dart';

class HeightSelectionScreen extends StatefulWidget {
  final int? savedHeight;

  const HeightSelectionScreen({super.key, this.savedHeight});

  @override
  State<HeightSelectionScreen> createState() =>
      _HeightSelectionScreenState();
}

class _HeightSelectionScreenState
    extends State<HeightSelectionScreen> {
  int selectedHeight = 165;
  bool _isLoadingData = true;

  final List<int> heightList =
      List.generate(71, (index) => index + 140); // 140–210

  late FixedExtentScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController =
        FixedExtentScrollController(initialItem: 15);
    _initHeight();
  }

  Future<void> _initHeight() async {
    int height = widget.savedHeight ?? 0;

    if (height == 0) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        height = (doc.data()?['height'] ?? 0).toInt();
      }
    }

    if (height == 0) height = 165;

    final index = heightList.indexOf(height);
    final safeIndex = index >= 0 ? index : 15;

    setState(() {
      selectedHeight = height;
      _isLoadingData = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpToItem(safeIndex);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: _isLoadingData
            ? Center(
                child: CircularProgressIndicator(
                    color: theme.colorScheme.primary))
            : Column(
                children: [
                  //////////////////////////////////////////////////////
                  /// BACK BUTTON
                  //////////////////////////////////////////////////////
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () =>
                          Navigator.pop(context),
                      icon: Icon(Icons.arrow_back,
                          color: theme.colorScheme.primary),
                      label: Text(
                        "Back",
                        style: TextStyle(
                            color: theme.colorScheme.primary),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  //////////////////////////////////////////////////////
                  /// TITLE
                  //////////////////////////////////////////////////////
                  Text(
                    "What Is Your Height?",
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40),
                    child: Text(
                      "This helps us calculate your BMI accurately.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface
                            .withOpacity(0.6),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  //////////////////////////////////////////////////////
                  /// BIG HEIGHT DISPLAY
                  //////////////////////////////////////////////////////
                  Text(
                    "$selectedHeight cm",
                    style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 30),

                  //////////////////////////////////////////////////////
                  /// VERTICAL RULER
                  //////////////////////////////////////////////////////
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C63FF)
                                .withOpacity(0.7),
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                        ),
                        ListWheelScrollView.useDelegate(
                          controller: _scrollController,
                          itemExtent: 50,
                          perspective: 0.003,
                          diameterRatio: 1.3,
                          physics:
                              const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            setState(() {
                              selectedHeight =
                                  heightList[index];
                            });
                          },
                          childDelegate:
                              ListWheelChildBuilderDelegate(
                            childCount: heightList.length,
                            builder: (context, index) {
                              final isSelected =
                                  heightList[index] ==
                                      selectedHeight;
                              return Center(
                                child: Text(
                                  heightList[index]
                                      .toString(),
                                  style: TextStyle(
                                    fontSize:
                                        isSelected ? 26 : 20,
                                    fontWeight:
                                        FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          right: 60,
                          child: Icon(
                            Icons.arrow_left,
                            color: theme.colorScheme.primary,
                            size: 35,
                          ),
                        ),
                      ],
                    ),
                  ),

                  //////////////////////////////////////////////////////
                  /// CONTINUE BUTTON
                  //////////////////////////////////////////////////////
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            await AuthService()
                                .saveHeight(selectedHeight);
                            if (!mounted) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    GoalSelectionScreen(
                                  savedGoal: null,
                                ),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(
                                    content:
                                        Text(e.toString())));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              theme.colorScheme.primary,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "Continue",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
      ),
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gym_management/screens/weight_selection_screen.dart';
import '../services/auth_service.dart';

class AgeSelectionScreen extends StatefulWidget {
  final int? savedAge; // passed from previous screen or loaded from Firestore

  const AgeSelectionScreen({super.key, this.savedAge});

  @override
  State<AgeSelectionScreen> createState() =>
      _AgeSelectionScreenState();
}

class _AgeSelectionScreenState
    extends State<AgeSelectionScreen> {
  int selectedAge = 28;
  bool _isLoadingData = true;

  final List<int> ages =
      List.generate(83, (index) => index + 18); // 18–100

  late FixedExtentScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    // Temporary controller — will be replaced after we know the age
    _scrollController =
        FixedExtentScrollController(initialItem: 10);
    _initAge();
  }

  Future<void> _initAge() async {
    int age = widget.savedAge ?? 0;

    // If not passed from previous screen, try Firestore
    if (age == 0) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        age = (doc.data()?['age'] ?? 0).toInt();
      }
    }

    // Default to 28 if nothing found
    if (age == 0) age = 28;

    final index = ages.indexOf(age);
    final safeIndex = index >= 0 ? index : 10;

    setState(() {
      selectedAge = age;
      _isLoadingData = false;
    });

    // Jump scroll wheel to the correct position
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
                    "How Old Are You?",
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
                      "This helps us create your personalized fitness plan.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface
                            .withOpacity(0.6),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  //////////////////////////////////////////////////////
                  /// SELECTED AGE BIG TEXT
                  //////////////////////////////////////////////////////
                  Text(
                    selectedAge.toString(),
                    style: TextStyle(
                      fontSize: 70,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Icon(Icons.arrow_drop_up,
                      color: theme.colorScheme.primary,
                      size: 40),

                  //////////////////////////////////////////////////////
                  /// AGE PICKER
                  //////////////////////////////////////////////////////
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 70,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C63FF)
                                .withOpacity(0.6),
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                        ),
                        ListWheelScrollView.useDelegate(
                          controller: _scrollController,
                          itemExtent: 60,
                          perspective: 0.003,
                          diameterRatio: 1.2,
                          physics:
                              const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            setState(() {
                              selectedAge = ages[index];
                            });
                          },
                          childDelegate:
                              ListWheelChildBuilderDelegate(
                            childCount: ages.length,
                            builder: (context, index) {
                              final isSelected =
                                  ages[index] == selectedAge;
                              return Center(
                                child: Text(
                                  ages[index].toString(),
                                  style: TextStyle(
                                    fontSize:
                                        isSelected ? 30 : 22,
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
                                .saveAge(selectedAge);
                            if (!mounted) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    WeightSelectionScreen(
                                  savedWeight: null,
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
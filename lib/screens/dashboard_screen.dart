import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  String userName = "Athlete";

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      setState(() {
        userName = doc.data()?['name'] ?? "Athlete";
      });
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F14),
      bottomNavigationBar: _buildBottomNav(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //////////////////////////////////////////////////////
              /// HEADER
              //////////////////////////////////////////////////////
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hi, $userName 👋",
                        style: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "Push your limits today.",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                  Row(
                    children: const [
                      Icon(Icons.search, color: Color(0xFFFFD700)),
                      SizedBox(width: 15),
                      Icon(Icons.notifications, color: Color(0xFFFFD700)),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 30),

              //////////////////////////////////////////////////////
              /// QUICK ACTIONS
              //////////////////////////////////////////////////////
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  _QuickAction(icon: Icons.fitness_center, label: "Workout"),
                  _QuickAction(icon: Icons.show_chart, label: "Progress"),
                  _QuickAction(icon: Icons.restaurant, label: "Nutrition"),
                  _QuickAction(icon: Icons.people, label: "Community"),
                ],
              ),

              const SizedBox(height: 35),

              //////////////////////////////////////////////////////
              /// RECOMMENDATIONS TITLE
              //////////////////////////////////////////////////////
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Recommended",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text("See All", style: TextStyle(color: Color(0xFFFFD700))),
                ],
              ),

              const SizedBox(height: 15),

              //////////////////////////////////////////////////////
              /// WORKOUT CARDS
              //////////////////////////////////////////////////////
              SizedBox(
                height: 190,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    _WorkoutCard(
                      title: "Squat Exercise",
                      duration: "12 Min",
                      calories: "120 Kcal",
                    ),
                    SizedBox(width: 15),
                    _WorkoutCard(
                      title: "Full Body Stretch",
                      duration: "15 Min",
                      calories: "150 Kcal",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              //////////////////////////////////////////////////////
              /// WEEKLY CHALLENGE
              //////////////////////////////////////////////////////
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1F26),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Weekly Challenge",
                            style: TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Plank 3x Everyday",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFFFD700),
                      ),
                      child: const Icon(Icons.play_arrow, color: Colors.black),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              //////////////////////////////////////////////////////
              /// ARTICLES
              //////////////////////////////////////////////////////
              const Text(
                "Articles & Tips",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Row(
                children: const [
                  Expanded(child: _ArticleCard(title: "Supplement Guide")),
                  SizedBox(width: 15),
                  Expanded(child: _ArticleCard(title: "15 Daily Routines")),
                ],
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  //////////////////////////////////////////////////////
  /// BOTTOM NAV
  //////////////////////////////////////////////////////

  Widget _buildBottomNav() {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Color(0xFF1C1F26),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.home, color: Color(0xFFFFD700)),
          Icon(Icons.bar_chart, color: Colors.grey),
          Icon(Icons.star, color: Colors.grey),
          Icon(Icons.person, color: Colors.grey),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// QUICK ACTION
////////////////////////////////////////////////////////////

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;

  const _QuickAction({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1F26),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: const Color(0xFFFFD700)),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

////////////////////////////////////////////////////////////
/// WORKOUT CARD
////////////////////////////////////////////////////////////

class _WorkoutCard extends StatelessWidget {
  final String title;
  final String duration;
  final String calories;

  const _WorkoutCard({
    required this.title,
    required this.duration,
    required this.calories,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F26),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "$duration • $calories",
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// ARTICLE CARD
////////////////////////////////////////////////////////////

class _ArticleCard extends StatelessWidget {
  final String title;

  const _ArticleCard({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F26),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

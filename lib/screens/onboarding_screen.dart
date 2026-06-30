import 'package:flutter/material.dart';

import '../model/OnboardData.dart';
import 'login_screen.dart';

////////////////////////////////////////////////////////////
/// ONBOARDING SCREEN
////////////////////////////////////////////////////////////

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  // ✅ Slides Data
  final List<OnboardModel> slides = [
    OnboardModel(
      image: 'assets/images/gym1.jpeg',
      text: 'Start Your Journey Towards A More Active Lifestyle',
      icon: Icons.directions_run,
    ),
    OnboardModel(
      image: 'assets/images/gym2.jpeg',
      text: 'Find Nutrition Tips That Fit Your Lifestyle',
      icon: Icons.fitness_center,
    ),
    OnboardModel(
      image: 'assets/images/gym3.webp',
      text: 'A Community For You,Challenge Yourself',
      icon: Icons.emoji_events,
    ),
  ];

  void nextPage() {
    if (currentIndex < slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // ✅ Navigate to Login Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          ////////////////////////////////////////////////////////////
          /// PAGE VIEW
          ////////////////////////////////////////////////////////////

          PageView.builder(
            controller: _controller,
            itemCount: slides.length,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final slide = slides[index];

              return Stack(
                fit: StackFit.expand,
                children: [
                  // ✅ Background Image
                  Image.asset(
                    slide.image,
                    fit: BoxFit.cover,
                  ),

                  // ✅ Dark Overlay (kept regardless of theme — needed for
                  // text legibility over photos)
                  Container(
                    color: Colors.black.withOpacity(0.6),
                  ),

                  //////////////////////////////////////////////////////
                  /// CONTENT
                  //////////////////////////////////////////////////////

                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(40),
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5E0B15)
                              .withOpacity(0.85), // Maroon Card (brand accent)
                        ),
                        child: Column(
                          children: [
                            Icon(
                              slide.icon,
                              color: theme.colorScheme.primary,
                              size: 40,
                            ),
                            const SizedBox(height: 15),
                            Text(
                              slide.text,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      //////////////////////////////////////////////////////
                      /// NEXT BUTTON
                      //////////////////////////////////////////////////////

                      ElevatedButton(
                        onPressed: nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          currentIndex == slides.length - 1
                              ? "Get Started"
                              : "Next",
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),

          ////////////////////////////////////////////////////////////
          /// DOT INDICATOR
          ////////////////////////////////////////////////////////////

          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                slides.length,
                    (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: currentIndex == index ? 12 : 8,
                  height: currentIndex == index ? 12 : 8,
                  decoration: BoxDecoration(
                    color: currentIndex == index
                        ? theme.colorScheme.primary
                        : Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
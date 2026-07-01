import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/referral_model.dart';
import '../services/referral_service.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() =>
      _ReferralScreenState();
}

class _ReferralScreenState
    extends State<ReferralScreen> {
  final ReferralService _referralService =
      ReferralService();

  String? _referralCode;
  bool _isLoadingCode = true;

  // Gym referral form
  final _gymFormKey = GlobalKey<FormState>();
  final _friendNameController =
      TextEditingController();
  final _friendPhoneController =
      TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadReferralCode();
  }

  @override
  void dispose() {
    _friendNameController.dispose();
    _friendPhoneController.dispose();
    super.dispose();
  }

  Future<void> _loadReferralCode() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final name =
          doc.data()?['name'] ?? 'User';

      final code = await _referralService
          .getOrCreateReferralCode(name);

      setState(() {
        _referralCode = code;
        _isLoadingCode = false;
      });
    } catch (e) {
      setState(() => _isLoadingCode = false);
    }
  }

  Future<void> _submitGymReferral() async {
    if (!_gymFormKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await _referralService.submitGymReferral(
        referredName:
            _friendNameController.text.trim(),
        referredPhone:
            _friendPhoneController.text.trim(),
      );

      if (!mounted) return;

      _friendNameController.clear();
      _friendPhoneController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Gym referral submitted! You\'ll earn 500 pts once verified ✅'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0F14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0F14),
        elevation: 0,
        title: const Text('Refer & Earn',
            style: TextStyle(color: Colors.white)),
        iconTheme:
            const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            //////////////////////////////////////////////////////
            /// YOUR REFERRAL CODE CARD
            //////////////////////////////////////////////////////

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1F26),
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(Icons.card_giftcard,
                      color: Color(0xFFFFD700),
                      size: 40),
                  const SizedBox(height: 12),
                  const Text(
                    'Your Referral Code',
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  _isLoadingCode
                      ? const CircularProgressIndicator(
                          color: Color(0xFFFFD700))
                      : Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                          children: [
                            Text(
                              _referralCode ?? '—',
                              style: const TextStyle(
                                color: Color(
                                    0xFFFFD700),
                                fontSize: 28,
                                fontWeight:
                                    FontWeight.bold,
                                letterSpacing: 3,
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: const Icon(
                                  Icons.copy,
                                  color: Colors.grey),
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(
                                      text: _referralCode ??
                                          ''),
                                );
                                ScaffoldMessenger.of(
                                        context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Code copied!'),
                                    duration: Duration(
                                        seconds: 2),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                  const SizedBox(height: 16),
                  const Text(
                    'Share this code with friends.\nYou earn 100 pts per app signup,\n500 pts when a friend joins the gym.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        height: 1.6),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            //////////////////////////////////////////////////////
            /// REWARDS BREAKDOWN
            //////////////////////////////////////////////////////

            const Text('How It Works',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),

            const SizedBox(height: 14),

            _rewardRow(
              icon: Icons.phone_android,
              title: 'Friend Downloads App',
              subtitle:
                  'They enter your code at signup',
              points: '+100 pts',
            ),
            const SizedBox(height: 10),
            _rewardRow(
              icon: Icons.fitness_center,
              title: 'Friend Joins the Gym',
              subtitle: 'Submit below — we verify it',
              points: '+500 pts',
            ),
            const SizedBox(height: 10),
            _rewardRow(
              icon: Icons.star,
              title: 'New Member Bonus',
              subtitle: 'For using someone\'s code',
              points: '+50 pts',
            ),

            const SizedBox(height: 30),

            //////////////////////////////////////////////////////
            /// GYM REFERRAL FORM
            //////////////////////////////////////////////////////

            const Text('Refer a Friend to the Gym',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),

            const SizedBox(height: 6),

            const Text(
              'Submit your friend\'s details. Once they join the gym and our team verifies it, you\'ll instantly receive 500 points.',
              style: TextStyle(
                  color: Colors.grey, fontSize: 13, height: 1.5),
            ),

            const SizedBox(height: 16),

            Form(
              key: _gymFormKey,
              child: Column(
                children: [
                  _buildFormField(
                    controller: _friendNameController,
                    hint: "Friend's Full Name",
                    icon: Icons.person_outline,
                    validator: (v) =>
                        v == null || v.trim().isEmpty
                            ? 'Name is required'
                            : null,
                  ),
                  const SizedBox(height: 14),
                  _buildFormField(
                    controller:
                        _friendPhoneController,
                    hint: "Friend's Phone Number",
                    icon: Icons.phone_outlined,
                    keyboardType:
                        TextInputType.phone,
                    validator: (v) =>
                        v == null || v.trim().isEmpty
                            ? 'Phone is required'
                            : null,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSubmitting
                          ? null
                          : _submitGymReferral,
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFFFD700),
                        foregroundColor:
                            Colors.black,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  14),
                        ),
                      ),
                      child: _isSubmitting
                          ? const CircularProgressIndicator(
                              color: Colors.black)
                          : const Text(
                              'Submit Gym Referral',
                              style: TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                  fontSize: 15),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            //////////////////////////////////////////////////////
            /// REFERRAL HISTORY
            //////////////////////////////////////////////////////

            const Text('Your Referrals',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),

            const SizedBox(height: 14),

            if (user != null)
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('referrals')
                    .orderBy('createdAt',
                        descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child:
                          CircularProgressIndicator(
                              color:
                                  Color(0xFFFFD700)),
                    );
                  }

                  final docs =
                      snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1F26),
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Text(
                          'No referrals yet — share your code!',
                          style: TextStyle(
                              color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  final referrals = docs
                      .map((doc) =>
                          Referral.fromFirestore(
                            doc.id,
                            doc.data() as Map<
                                String, dynamic>,
                          ))
                      .toList();

                  return Column(
                    children: referrals
                        .map((r) =>
                            _ReferralCard(referral: r))
                        .toList(),
                  );
                },
              ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _rewardRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required String points,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F26),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon,
              color: const Color(0xFFFFD700),
              size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                Text(subtitle,
                    style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12)),
              ],
            ),
          ),
          Text(points,
              style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType =
        TextInputType.text,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon,
            color: const Color(0xFFFFD700)),
        filled: true,
        fillColor: const Color(0xFF1C1F26),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// REFERRAL HISTORY CARD
////////////////////////////////////////////////////////////

class _ReferralCard extends StatelessWidget {
  final Referral referral;

  const _ReferralCard({required this.referral});

  Color _statusColor() {
    switch (referral.status) {
      case 'verified':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F26),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            referral.type == 'gym'
                ? Icons.fitness_center
                : Icons.phone_android,
            color: const Color(0xFFFFD700),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  referral.referredName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  referral.type == 'gym'
                      ? 'Gym referral'
                      : 'App referral',
                  style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      _statusColor().withOpacity(0.15),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Text(
                  referral.status.toUpperCase(),
                  style: TextStyle(
                    color: _statusColor(),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (referral.pointsAwarded > 0)
                Padding(
                  padding: const EdgeInsets.only(
                      top: 4),
                  child: Text(
                    '+${referral.pointsAwarded} pts',
                    style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
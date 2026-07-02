import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gym_management/widgets/banner_ad_widget.dart';
import 'package:intl/intl.dart';
import '../model/points_transaction_model.dart';
import '../services/referral_service.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final referralService = ReferralService();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0F14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0F14),
        elevation: 0,
        title: const Text('My Rewards',
            style: TextStyle(color: Colors.white)),
        iconTheme:
            const IconThemeData(color: Colors.white),
      ),
      body: user == null
          ? const Center(
              child: Text('Not signed in.',
                  style:
                      TextStyle(color: Colors.grey)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  //////////////////////////////////////////////////////
                  /// POINTS BALANCE CARD
                  //////////////////////////////////////////////////////

                  StreamBuilder<int>(
                    stream: referralService
                        .watchUserPoints(),
                    builder: (context, snapshot) {
                      final points =
                          snapshot.data ?? 0;

                      return Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          gradient:
                              const LinearGradient(
                            colors: [
                              Color(0xFF2A2500),
                              Color(0xFF1C1F26),
                            ],
                            begin: Alignment.topLeft,
                            end:
                                Alignment.bottomRight,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                                  22),
                          border: Border.all(
                            color: const Color(
                                    0xFFFFD700)
                                .withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.stars,
                                color:
                                    Color(0xFFFFD700),
                                size: 36),
                            const SizedBox(height: 10),
                            Text(
                              '$points',
                              style: const TextStyle(
                                color:
                                    Color(0xFFFFD700),
                                fontSize: 52,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'POINTS',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  //////////////////////////////////////////////////////
                  /// AVAILABLE REWARDS
                  //////////////////////////////////////////////////////

                  const Text('Redeem Rewards',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold)),

                  const SizedBox(height: 14),

                  _RewardItem(
                    icon: Icons.fitness_center,
                    title: 'Free Workout Session',
                    subtitle:
                        'One complimentary gym session',
                    pointsCost: 500,
                    onRedeem: (ctx) =>
                        _showRedeemConfirm(
                      ctx,
                      user.uid,
                      'Free Workout Session',
                      500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _RewardItem(
                    icon: Icons.percent,
                    title: '10% Membership Discount',
                    subtitle:
                        'Applied to next billing cycle',
                    pointsCost: 1000,
                    onRedeem: (ctx) =>
                        _showRedeemConfirm(
                      ctx,
                      user.uid,
                      '10% Membership Discount',
                      1000,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _RewardItem(
                    icon: Icons.person,
                    title: 'Personal Trainer Session',
                    subtitle: '1-hour session with a trainer',
                    pointsCost: 2000,
                    onRedeem: (ctx) =>
                        _showRedeemConfirm(
                      ctx,
                      user.uid,
                      'Personal Trainer Session',
                      2000,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _RewardItem(
                    icon: Icons.local_drink,
                    title: 'Free Protein Shake',
                    subtitle: 'Redeemable at gym counter',
                    pointsCost: 200,
                    onRedeem: (ctx) =>
                        _showRedeemConfirm(
                      ctx,
                      user.uid,
                      'Free Protein Shake',
                      200,
                    ),
                  ),

                  const SizedBox(height: 30),

                  //////////////////////////////////////////////////////
                  /// POINTS HISTORY
                  //////////////////////////////////////////////////////

                  const Text('Points History',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold)),

                  const SizedBox(height: 14),

                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('pointsHistory')
                        .orderBy('createdAt',
                            descending: true)
                        .limit(20)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child:
                              CircularProgressIndicator(
                                  color: Color(
                                      0xFFFFD700)),
                        );
                      }

                      final docs =
                          snapshot.data?.docs ?? [];

                      if (docs.isEmpty) {
                        return Container(
                          padding:
                              const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF1C1F26),
                            borderRadius:
                                BorderRadius.circular(
                                    14),
                          ),
                          child: const Center(
                            child: Text(
                              'No points activity yet.\nRefer friends to start earning!',
                              textAlign:
                                  TextAlign.center,
                              style: TextStyle(
                                  color: Colors.grey),
                            ),
                          ),
                        );
                      }

                      final transactions = docs
                          .map((doc) =>
                              PointsTransaction
                                  .fromFirestore(
                                doc.id,
                                doc.data() as Map<
                                    String, dynamic>,
                              ))
                          .toList();

                      return Column(
                        children: transactions
                            .map((txn) =>
                                _TransactionCard(
                                    txn: txn))
                            .toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
            bottomNavigationBar: const BannerAdWidget(),
    );
  }

  void _showRedeemConfirm(
    BuildContext context,
    String userId,
    String rewardName,
    int pointsCost,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1F26),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Redemption',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold)),
        content: Text(
          'Redeem "$rewardName" for $pointsCost points?\n\nOur team will contact you within 24 hours to arrange this.',
          style: const TextStyle(
              color: Colors.grey, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style:
                    TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _processRedemption(
                context,
                userId,
                rewardName,
                pointsCost,
              );
            },
            child: const Text('Redeem',
                style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _processRedemption(
    BuildContext context,
    String userId,
    String rewardName,
    int pointsCost,
  ) async {
    try {
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId);

      final doc = await userRef.get();
      final currentPoints =
          (doc.data()?['points'] ?? 0).toInt();

      if (currentPoints < pointsCost) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Not enough points for this reward.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final batch =
          FirebaseFirestore.instance.batch();

      // Deduct points
      batch.update(userRef, {
        'points':
            FieldValue.increment(-pointsCost),
      });

      // Add to points history
      final historyRef = userRef
          .collection('pointsHistory')
          .doc();
      batch.set(historyRef, {
        'type': 'redeemed',
        'reason': 'redemption',
        'points': -pointsCost,
        'description': 'Redeemed: $rewardName',
        'createdAt': Timestamp.now(),
      });

      // Add redemption request for admin
      final redemptionRef = FirebaseFirestore
          .instance
          .collection('redemptionRequests')
          .doc();
      batch.set(redemptionRef, {
        'userId': userId,
        'rewardName': rewardName,
        'pointsCost': pointsCost,
        'status': 'pending',
        'createdAt': Timestamp.now(),
      });

      await batch.commit();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '🎉 "$rewardName" redeemed! We\'ll be in touch soon.'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}

////////////////////////////////////////////////////////////
/// REWARD ITEM WIDGET
////////////////////////////////////////////////////////////

class _RewardItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int pointsCost;
  final void Function(BuildContext) onRedeem;

  const _RewardItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.pointsCost,
    required this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          GestureDetector(
            onTap: () => onRedeem(context),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700),
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: Text(
                '$pointsCost pts',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// POINTS TRANSACTION CARD
////////////////////////////////////////////////////////////

class _TransactionCard extends StatelessWidget {
  final PointsTransaction txn;

  const _TransactionCard({required this.txn});

  @override
  Widget build(BuildContext context) {
    final isEarned = txn.type == 'earned';
    final pointsText = isEarned
        ? '+${txn.points} pts'
        : '${txn.points} pts';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F26),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isEarned
                      ? Colors.green
                      : Colors.red)
                  .withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isEarned
                  ? Icons.arrow_downward
                  : Icons.arrow_upward,
              color: isEarned
                  ? Colors.green
                  : Colors.red,
              size: 16,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(txn.description,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13)),
                Text(
                  DateFormat('MMM d, h:mm a')
                      .format(txn.createdAt),
                  style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            pointsText,
            style: TextStyle(
              color: isEarned
                  ? Colors.green
                  : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
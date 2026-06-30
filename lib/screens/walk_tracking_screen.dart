// import 'dart:async';

// import 'package:flutter/material.dart';

// import '../model/walk_session_model.dart';
// import '../services/walk_tracking_service.dart';

// class WalkTrackingScreen extends StatefulWidget {
//   const WalkTrackingScreen({super.key});

//   @override
//   State<WalkTrackingScreen> createState() =>
//       _WalkTrackingScreenState();
// }

// class _WalkTrackingScreenState
//     extends State<WalkTrackingScreen> {
//   // final WalkTrackingService _walkService =
//   //     WalkTrackingService();

//   bool _isTracking = false;
//   bool _isSaving = false;
//   double _liveDistanceMeters = 0;
//   Timer? _uiTimer;
//   Duration _elapsed = Duration.zero;

//   StreamSubscription<double>? _distanceSub;

//   @override
//   void dispose() {
//     _uiTimer?.cancel();
//     _distanceSub?.cancel();
//     _walkService.dispose();
//     super.dispose();
//   }

//   //////////////////////////////////////////////////////
//   /// START WALK
//   //////////////////////////////////////////////////////

//   Future<void> _handleStart() async {
//     debugPrint('[WalkScreen] Play button tapped — _handleStart() running');

//     try {
//       debugPrint('[WalkScreen] Calling ensurePermission()...');
//       final hasPermission =
//           await _walkService.ensurePermission();
//       debugPrint(
//           '[WalkScreen] ensurePermission() returned: $hasPermission');

//       if (!hasPermission) {
//         debugPrint(
//             '[WalkScreen] No permission — showing dialog');
//         if (!mounted) return;
//         _showPermissionDeniedDialog();
//         return;
//       }

//       debugPrint('[WalkScreen] Starting GPS tracking...');
//       await _walkService.startTracking();
//       debugPrint('[WalkScreen] Tracking started successfully');

//       _distanceSub =
//           _walkService.distanceStream.listen((meters) {
//         setState(() => _liveDistanceMeters = meters);
//       });

//       // Tick every second to update the live timer display
//       _uiTimer = Timer.periodic(
//           const Duration(seconds: 1), (_) {
//         setState(() {
//           _elapsed = _walkService.currentDuration;
//         });
//       });

//       setState(() => _isTracking = true);
//     } catch (e, stackTrace) {
//       debugPrint('[WalkScreen] ERROR in _handleStart: $e');
//       debugPrint('[WalkScreen] Stack trace: $stackTrace');
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error starting walk: $e'),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 6),
//         ),
//       );
//     }
//   }

//   //////////////////////////////////////////////////////
//   /// STOP WALK
//   //////////////////////////////////////////////////////

//   Future<void> _handleStop() async {
//     _uiTimer?.cancel();
//     _distanceSub?.cancel();

//     final WalkSession session = _walkService.stopTracking();

//     setState(() {
//       _isTracking = false;
//       _isSaving = true;
//     });

//     try {
//       await _walkService.saveWalkSession(session);
//       if (!mounted) return;
//       _showSummary(session);
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//             content:
//                 Text('Failed to save walk: $e')),
//       );
//     } finally {
//       if (mounted) setState(() => _isSaving = false);
//     }
//   }

//   //////////////////////////////////////////////////////
//   /// DIALOGS
//   //////////////////////////////////////////////////////

//   void _showPermissionDeniedDialog() {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         backgroundColor: const Color(0xFF1C1F26),
//         title: const Text('Location Needed',
//             style: TextStyle(color: Colors.white)),
//         content: const Text(
//           'Walk tracking needs location access to measure '
//           'your distance. Please enable location permission '
//           'in your device settings.',
//           style: TextStyle(color: Colors.grey),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () =>
//                 Navigator.pop(context),
//             child: const Text('OK',
//                 style: TextStyle(
//                     color: Color(0xFFFFD700))),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showSummary(WalkSession session) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => AlertDialog(
//         backgroundColor: const Color(0xFF1C1F26),
//         shape: RoundedRectangleBorder(
//             borderRadius:
//                 BorderRadius.circular(20)),
//         title: const Text('Walk Complete 🎉',
//             style: TextStyle(
//                 color: Color(0xFFFFD700),
//                 fontWeight: FontWeight.bold)),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment:
//               CrossAxisAlignment.start,
//           children: [
//             _summaryRow('Distance',
//                 '${session.distanceKm.toStringAsFixed(2)} km'),
//             _summaryRow('Duration',
//                 _formatDuration(Duration(
//                     seconds:
//                         session.durationSeconds))),
//             _summaryRow('Calories',
//                 '${session.caloriesBurned.toStringAsFixed(0)} kcal'),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context); // close dialog
//               Navigator.pop(
//                   context, true); // close screen, return true
//             },
//             child: const Text('Done',
//                 style: TextStyle(
//                     color: Color(0xFFFFD700))),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _summaryRow(String label, String value) {
//     return Padding(
//       padding:
//           const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         mainAxisAlignment:
//             MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label,
//               style: const TextStyle(
//                   color: Colors.grey)),
//           Text(value,
//               style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold)),
//         ],
//       ),
//     );
//   }

//   String _formatDuration(Duration d) {
//     final minutes = d.inMinutes;
//     final seconds = d.inSeconds % 60;
//     return "${minutes}m ${seconds}s";
//   }

//   //////////////////////////////////////////////////////
//   /// UI
//   //////////////////////////////////////////////////////

//   @override
//   Widget build(BuildContext context) {
//     final distanceKm = _liveDistanceMeters / 1000;

//     return Scaffold(
//       backgroundColor: const Color(0xFF0D0F14),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF0D0F14),
//         elevation: 0,
//         title: const Text('Track Walk',
//             style: TextStyle(color: Colors.white)),
//         iconTheme:
//             const IconThemeData(color: Colors.white),
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             children: [
//               const SizedBox(height: 40),

//               // ── Distance Display ──
//               Container(
//                 width: double.infinity,
//                 padding:
//                     const EdgeInsets.all(30),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF1C1F26),
//                   borderRadius:
//                       BorderRadius.circular(24),
//                 ),
//                 child: Column(
//                   children: [
//                     Text(
//                       distanceKm
//                           .toStringAsFixed(2),
//                       style: const TextStyle(
//                         color: Color(0xFFFFD700),
//                         fontSize: 56,
//                         fontWeight:
//                             FontWeight.bold,
//                       ),
//                     ),
//                     const Text('kilometers',
//                         style: TextStyle(
//                             color: Colors.grey,
//                             fontSize: 14)),
//                     const SizedBox(height: 25),
//                     Row(
//                       mainAxisAlignment:
//                           MainAxisAlignment
//                               .spaceEvenly,
//                       children: [
//                         _statColumn(
//                           icon: Icons.timer,
//                           label: 'Time',
//                           value: _formatDuration(
//                               _elapsed),
//                         ),
//                         _statColumn(
//                           icon: Icons
//                               .local_fire_department,
//                           label: 'Calories',
//                           value:
//                               '${(distanceKm * 50).toStringAsFixed(0)} kcal',
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 50),

//               // ── Start / Stop Button ──
//               _isSaving
//                   ? const CircularProgressIndicator(
//                       color: Color(0xFFFFD700))
//                   : GestureDetector(
//                       onTap: _isTracking
//                           ? _handleStop
//                           : _handleStart,
//                       child: Container(
//                         width: 100,
//                         height: 100,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: _isTracking
//                               ? Colors.redAccent
//                               : const Color(
//                                   0xFFFFD700),
//                         ),
//                         child: Icon(
//                           _isTracking
//                               ? Icons.stop
//                               : Icons.play_arrow,
//                           color: Colors.black,
//                           size: 44,
//                         ),
//                       ),
//                     ),

//               const SizedBox(height: 15),

//               Text(
//                 _isTracking
//                     ? 'Tap to stop'
//                     : 'Tap to start walking',
//                 style: const TextStyle(
//                     color: Colors.grey),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _statColumn({
//     required IconData icon,
//     required String label,
//     required String value,
//   }) {
//     return Column(
//       children: [
//         Icon(icon, color: Colors.white70, size: 20),
//         const SizedBox(height: 6),
//         Text(value,
//             style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16)),
//         Text(label,
//             style: const TextStyle(
//                 color: Colors.grey, fontSize: 12)),
//       ],
//     );
//   }
// }
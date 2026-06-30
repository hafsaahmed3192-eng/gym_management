// import 'dart:async';
// import 'dart:math';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart';
// import 'package:geolocator/geolocator.dart';

// import '../model/walk_session_model.dart';

// /// Average calories burned per kilometer walked, used for
// /// a simple estimate. ~50 kcal/km is a reasonable average
// /// for moderate walking pace; adjust per user weight later
// /// if you want a more accurate formula.
// const double _kcalPerKm = 50.0;

// class WalkTrackingService {
//   StreamSubscription<Position>? _positionStream;

//   Position? _lastPosition;
//   double _totalDistanceMeters = 0;
//   DateTime? _startTime;
//   final List<Map<String, double>> _routePoints = [];

//   bool get isTracking => _positionStream != null;
//   double get currentDistanceMeters => _totalDistanceMeters;
//   double get currentDistanceKm => _totalDistanceMeters / 1000;

//   Duration get currentDuration {
//     if (_startTime == null) return Duration.zero;
//     return DateTime.now().difference(_startTime!);
//   }

//   /// Emits live distance updates (meters) while tracking.
//   final _distanceController =
//       StreamController<double>.broadcast();
//   Stream<double> get distanceStream =>
//       _distanceController.stream;

//   //////////////////////////////////////////////////////
//   /// PERMISSION HANDLING
//   //////////////////////////////////////////////////////

//   /// Checks and requests location permission.
//   /// Returns true if permission granted and ready to track.
//   Future<bool> ensurePermission() async {
//     debugPrint('[WalkTracking] ensurePermission() called');

//     bool serviceEnabled =
//         await Geolocator.isLocationServiceEnabled();
//     debugPrint(
//         '[WalkTracking] Location service enabled: $serviceEnabled');

//     if (!serviceEnabled) {
//       debugPrint(
//           '[WalkTracking] BLOCKED: device location services are OFF');
//       return false; // Location services off at OS level
//     }

//     LocationPermission permission =
//         await Geolocator.checkPermission();
//     debugPrint(
//         '[WalkTracking] Current permission status: $permission');

//     if (permission == LocationPermission.denied) {
//       debugPrint(
//           '[WalkTracking] Permission denied — requesting now...');
//       permission =
//           await Geolocator.requestPermission();
//       debugPrint(
//           '[WalkTracking] Permission after request: $permission');
//       if (permission == LocationPermission.denied) {
//         debugPrint(
//             '[WalkTracking] User denied the permission request');
//         return false;
//       }
//     }

//     if (permission ==
//         LocationPermission.deniedForever) {
//       debugPrint(
//           '[WalkTracking] BLOCKED: permission denied forever — must enable in app settings');
//       return false;
//     }

//     debugPrint('[WalkTracking] Permission granted! Returning true');
//     return true;
//   }

//   //////////////////////////////////////////////////////
//   /// START / STOP TRACKING
//   //////////////////////////////////////////////////////

//   /// Begins a new walk session. Call [ensurePermission] first.
//   Future<void> startTracking() async {
//     _totalDistanceMeters = 0;
//     _lastPosition = null;
//     _routePoints.clear();
//     _startTime = DateTime.now();

//     const locationSettings = LocationSettings(
//       accuracy: LocationAccuracy.high,
//       distanceFilter: 5, // meters — ignores GPS jitter under 5m
//     );

//     _positionStream = Geolocator.getPositionStream(
//       locationSettings: locationSettings,
//     ).listen((Position position) {
//       _onNewPosition(position);
//     });
//   }

//   void _onNewPosition(Position position) {
//     if (_lastPosition != null) {
//       final segmentDistance = _haversineDistance(
//         _lastPosition!.latitude,
//         _lastPosition!.longitude,
//         position.latitude,
//         position.longitude,
//       );

//       // Filter out GPS noise — ignore jumps that are
//       // physically implausible for walking pace (>15 m/s)
//       final timeDeltaSeconds = position.timestamp
//               .difference(_lastPosition!.timestamp)
//               .inMilliseconds /
//           1000.0;
//       final impliedSpeed = timeDeltaSeconds > 0
//           ? segmentDistance / timeDeltaSeconds
//           : 0;

//       if (impliedSpeed < 15) {
//         _totalDistanceMeters += segmentDistance;
//       }
//     }

//     _lastPosition = position;
//     _routePoints.add({
//       'lat': position.latitude,
//       'lng': position.longitude,
//     });

//     _distanceController.add(_totalDistanceMeters);
//   }

//   /// Stops tracking and returns the completed [WalkSession].
//   /// Does NOT save to Firestore — call [saveWalkSession]
//   /// separately so the UI can show a summary/confirm screen first.
//   WalkSession stopTracking() {
//     _positionStream?.cancel();
//     _positionStream = null;

//     final duration = _startTime != null
//         ? DateTime.now().difference(_startTime!)
//         : Duration.zero;

//     final distanceKm = _totalDistanceMeters / 1000;
//     final calories = distanceKm * _kcalPerKm;

//     return WalkSession(
//       id: '', // assigned by Firestore on save
//       distanceMeters: _totalDistanceMeters,
//       durationSeconds: duration.inSeconds,
//       caloriesBurned: calories,
//       date: _startTime ?? DateTime.now(),
//       routePoints: List.from(_routePoints),
//     );
//   }

//   /// Cancels tracking without producing a session
//   /// (e.g. user backed out without finishing).
//   void cancelTracking() {
//     _positionStream?.cancel();
//     _positionStream = null;
//     _totalDistanceMeters = 0;
//     _lastPosition = null;
//     _routePoints.clear();
//     _startTime = null;
//   }

//   //////////////////////////////////////////////////////
//   /// SAVE TO FIRESTORE
//   //////////////////////////////////////////////////////

//   Future<void> saveWalkSession(WalkSession session) async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       throw Exception(
//           'No authenticated user to save walk session for.');
//     }

//     await FirebaseFirestore.instance
//         .collection('users')
//         .doc(user.uid)
//         .collection('walkHistory')
//         .add(session.toFirestore());
//   }

//   //////////////////////////////////////////////////////
//   /// HAVERSINE DISTANCE (meters between two GPS points)
//   //////////////////////////////////////////////////////

//   double _haversineDistance(
//       double lat1, double lon1, double lat2, double lon2) {
//     const earthRadiusMeters = 6371000;

//     final dLat = _degreesToRadians(lat2 - lat1);
//     final dLon = _degreesToRadians(lon2 - lon1);

//     final a = sin(dLat / 2) * sin(dLat / 2) +
//         cos(_degreesToRadians(lat1)) *
//             cos(_degreesToRadians(lat2)) *
//             sin(dLon / 2) *
//             sin(dLon / 2);

//     final c = 2 * atan2(sqrt(a), sqrt(1 - a));

//     return earthRadiusMeters * c;
//   }

//   double _degreesToRadians(double degrees) =>
//       degrees * pi / 180;

//   void dispose() {
//     _positionStream?.cancel();
//     _distanceController.close();
//   }
// }
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

import '../model/daily_steps_model.dart';

class StepTrackingService {
  StreamSubscription<StepCount>? _stepCountSub;
  StreamSubscription<PedestrianStatus>? _statusSub;

  /// The raw cumulative step count reported by the OS sensor
  /// since the phone last rebooted. This number only ever goes
  /// up — it does NOT reset daily on its own. We calculate
  /// "today's steps" by storing the sensor value at the start
  /// of each day and subtracting.
  int? _sensorStepsAtDayStart;
  int _todaySteps = 0;

  final _stepsController = StreamController<int>.broadcast();
  Stream<int> get todayStepsStream => _stepsController.stream;

  bool _isInitialized = false;

  //////////////////////////////////////////////////////
  /// PERMISSION
  //////////////////////////////////////////////////////

  /// On Android 10+, reading the step sensor requires the
  /// ACTIVITY_RECOGNITION runtime permission.
  Future<bool> ensurePermission() async {
    debugPrint('[StepTracking] Checking activity recognition permission');

    final status = await Permission.activityRecognition.status;
    debugPrint('[StepTracking] Current status: $status');

    if (status.isGranted) return true;

    final result =
        await Permission.activityRecognition.request();
    debugPrint('[StepTracking] After request: $result');

    return result.isGranted;
  }

  //////////////////////////////////////////////////////
  /// INITIALIZE — call once, e.g. in main.dart or on
  /// dashboard load. Sets up the listener that runs for
  /// as long as the app process is alive. Combined with
  /// the OS-level sensor (which keeps counting even when
  /// our listener isn't attached), this gives an
  /// always-accumulating step count.
  //////////////////////////////////////////////////////

  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('[StepTracking] Already initialized, skipping');
      return;
    }

    final hasPermission = await ensurePermission();
    if (!hasPermission) {
      debugPrint('[StepTracking] Permission denied — cannot track steps');
      return;
    }

    await _loadOrResetDayBaseline();

    _stepCountSub = Pedometer.stepCountStream.listen(
      _onStepCount,
      onError: (e) =>
          debugPrint('[StepTracking] Step stream error: $e'),
      cancelOnError: false,
    );

    _statusSub = Pedometer.pedestrianStatusStream.listen(
      (status) =>
          debugPrint('[StepTracking] Pedestrian status: ${status.status}'),
      onError: (e) =>
          debugPrint('[StepTracking] Status stream error: $e'),
      cancelOnError: false,
    );

    _isInitialized = true;
    debugPrint('[StepTracking] Initialized successfully');
  }

  //////////////////////////////////////////////////////
  /// DAY BASELINE HANDLING
  //////////////////////////////////////////////////////

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Loads today's saved step baseline from Firestore, or
  /// creates a fresh one if this is a new day.
  Future<void> _loadOrResetDayBaseline() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final todayKey = _todayKey();
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('dailySteps')
        .doc(todayKey);

    final doc = await docRef.get();

    if (doc.exists) {
      // Resuming an already-started day
      _todaySteps = (doc.data()?['steps'] ?? 0).toInt();
      debugPrint(
          '[StepTracking] Resumed today with $_todaySteps steps already saved');
    } else {
      // Fresh day, starting from zero
      _todaySteps = 0;
      await docRef.set(
        DailySteps.empty(todayKey).toFirestore(),
      );
      debugPrint('[StepTracking] Started fresh day at 0 steps');
    }

    // We don't yet know the OS sensor's raw cumulative value
    // until the first event arrives — see _onStepCount below.
    _sensorStepsAtDayStart = null;

    _stepsController.add(_todaySteps);
  }

  //////////////////////////////////////////////////////
  /// STEP COUNT HANDLER
  //////////////////////////////////////////////////////

  void _onStepCount(StepCount event) {
    debugPrint('[StepTracking] Raw sensor steps: ${event.steps}');

    // First event after init/resume — establish baseline.
    // Sensor value minus baseline = steps walked since we
    // started observing in this session.
    if (_sensorStepsAtDayStart == null) {
      _sensorStepsAtDayStart = event.steps - _todaySteps;
      debugPrint(
          '[StepTracking] Baseline set: ${_sensorStepsAtDayStart}');
      return;
    }

    final newTodaySteps =
        event.steps - _sensorStepsAtDayStart!;

    if (newTodaySteps != _todaySteps && newTodaySteps >= 0) {
      _todaySteps = newTodaySteps;
      _stepsController.add(_todaySteps);
      _saveStepsToFirestore(_todaySteps);
    }
  }

  //////////////////////////////////////////////////////
  /// SAVE TO FIRESTORE (debounced via simple throttle)
  //////////////////////////////////////////////////////

  DateTime? _lastSaveTime;

  Future<void> _saveStepsToFirestore(int steps) async {
    // Throttle writes to roughly once every 5 seconds to
    // avoid excessive Firestore writes on every single step.
    final now = DateTime.now();
    if (_lastSaveTime != null &&
        now.difference(_lastSaveTime!).inSeconds < 5) {
      return;
    }
    _lastSaveTime = now;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final todayKey = _todayKey();

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('dailySteps')
          .doc(todayKey)
          .set(
        {
          'steps': steps,
          'lastUpdated': Timestamp.now(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('[StepTracking] Failed to save steps: $e');
    }
  }

  //////////////////////////////////////////////////////
  /// CURRENT STATE GETTERS
  //////////////////////////////////////////////////////

  int get currentTodaySteps => _todaySteps;

  double get currentDistanceKm =>
      (_todaySteps * averageStrideLengthMeters) / 1000;

  double get currentCaloriesBurned =>
      _todaySteps * caloriesPerStep;

  //////////////////////////////////////////////////////
  /// CLEANUP
  //////////////////////////////////////////////////////

  void dispose() {
    _stepCountSub?.cancel();
    _statusSub?.cancel();
    _stepsController.close();
    _isInitialized = false;
  }
}
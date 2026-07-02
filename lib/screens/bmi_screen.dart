import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../services/bmi_service.dart';
import '../services/user_provider.dart';

class BMIScreen extends StatefulWidget {
  const BMIScreen({super.key});

  @override
  State<BMIScreen> createState() => _BMIScreenState();
}

class _BMIScreenState extends State<BMIScreen> {
  final BMIService _bmiService = BMIService();

  late TextEditingController _weightController;
  late TextEditingController _heightController;

  BMIResult? _result;
  bool _initialized = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _initializeFromProfile(Map<String, dynamic>? userData) {
    if (_initialized) return;

    final weight = (userData?['weight'] as num?)?.toDouble() ?? 70;
    final height = (userData?['height'] as num?)?.toDouble() ?? 170;

    _weightController = TextEditingController(text: weight.toStringAsFixed(0));
    _heightController = TextEditingController(text: height.toStringAsFixed(0));
    _result = BMIService.calculate(weight, height);
    _initialized = true;
  }

  void _recalculate() {
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);

    if (weight == null || weight <= 0 || height == null || height <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid weight and height.")),
      );
      return;
    }

    setState(() {
      _result = BMIService.calculate(weight, height);
    });
  }

  Future<void> _saveEntry() async {
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);

    if (weight == null || weight <= 0 || height == null || height <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid weight and height.")),
      );
      return;
    }

    setState(() => _isSaving = true);

    await _bmiService.saveEntry(weightKg: weight, heightCm: height);

    // Refresh the shared UserProvider so Profile stays in sync too.
    if (mounted) {
      await context.read<UserProvider>().fetchUserData();
    }

    setState(() {
      _result = BMIService.calculate(weight, height);
      _isSaving = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("BMI saved.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = context.watch<UserProvider>();
    _initializeFromProfile(userProvider.userData);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "BMI Calculator",
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildResultCard(theme),
              const SizedBox(height: 24),
              _buildInputCard(theme),
              const SizedBox(height: 30),
              Text(
                "History",
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Your past BMI entries",
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 15),
              _buildHistoryList(theme),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  //////////////////////////////////////////////////////
  /// RESULT CARD + GAUGE
  //////////////////////////////////////////////////////

  Widget _buildResultCard(ThemeData theme) {
    final result = _result;
    if (result == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            result.bmi.toStringAsFixed(1),
            style: TextStyle(
              color: result.color,
              fontSize: 44,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: result.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              result.label,
              style: TextStyle(
                color: result.color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildGauge(theme, result.bmi),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _legendDot(const Color(0xFF4FC3F7), "Under"),
              _legendDot(const Color(0xFF66BB6A), "Normal"),
              _legendDot(const Color(0xFFFFA726), "Over"),
              _legendDot(const Color(0xFFEF5350), "Obese"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(color: color, fontSize: 11)),
      ],
    );
  }

  /// Continuous gradient gauge spanning BMI 15–35. The track blends
  /// smoothly blue → green → orange → red instead of switching
  /// abruptly between category blocks, with a marker sitting directly
  /// on the track showing exactly where the current value falls.
  /// Gradient stops line up with the real clinical boundaries
  /// (18.5, 25, 30) so the blend still reads accurately against the
  /// Under/Normal/Over/Obese legend below it.
  Widget _buildGauge(ThemeData theme, double bmi) {
    const double minBmi = 15;
    const double maxBmi = 35;
    final clamped = bmi.clamp(minBmi, maxBmi);
    final markerPosition = (clamped - minBmi) / (maxBmi - minBmi); // 0..1

    return SizedBox(
      width: double.infinity,
      height: 26,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Container(
            width: double.infinity,
            height: 10,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF4FC3F7), // blue — underweight
                  Color(0xFF66BB6A), // green — normal
                  Color(0xFFFFA726), // orange — overweight
                  Color(0xFFEF5350), // red — obese
                ],
                stops: [0.0, 0.175, 0.5, 0.75],
              ),
            ),
          ),
          Align(
            alignment: Alignment(markerPosition * 2 - 1, 0),
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: theme.scaffoldBackgroundColor,
                  width: 3,
                ),
                boxShadow: const [
                  BoxShadow(color: Colors.black45, blurRadius: 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  //////////////////////////////////////////////////////
  /// INPUT CARD
  //////////////////////////////////////////////////////

  Widget _buildInputCard(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Update measurements",
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildNumberField(
                  theme,
                  controller: _weightController,
                  label: "Weight (kg)",
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNumberField(
                  theme,
                  controller: _heightController,
                  label: "Height (cm)",
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _recalculate,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: theme.colorScheme.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    "Recalculate",
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveEntry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Text(
                          "Save",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField(
    ThemeData theme, {
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: theme.colorScheme.onSurface.withOpacity(0.5),
          fontSize: 12,
        ),
        filled: true,
        fillColor: theme.scaffoldBackgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  //////////////////////////////////////////////////////
  /// HISTORY LIST
  //////////////////////////////////////////////////////

  Widget _buildHistoryList(ThemeData theme) {
    return StreamBuilder<List<BMIEntry>>(
      stream: _bmiService.watchHistory(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(color: theme.colorScheme.primary),
          );
        }

        final entries = snapshot.data!;
        if (entries.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              "No entries yet — save your first BMI above.",
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                fontSize: 13,
              ),
            ),
          );
        }

        return Column(
          children: entries.map((entry) {
            final result = BMIService.calculate(entry.weight, entry.height);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: result.color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${entry.bmi.toStringAsFixed(1)} — ${entry.category}',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${entry.weight.toStringAsFixed(0)} kg · ${entry.height.toStringAsFixed(0)} cm',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    DateFormat('MMM d').format(entry.createdAt),
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
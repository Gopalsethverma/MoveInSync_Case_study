import 'dart:async';
import 'dart:math';
import '../models/floor_plan.dart';

class FloorPlanService {
  final List<FloorPlan> _plans = [
    FloorPlan(
      id: '1',
      name: 'Ground Floor',
      imageUrl: 'https://via.placeholder.com/600x400',
      uploadedAt: DateTime.now().subtract(const Duration(days: 2)),
      version: 1,
    ),
    FloorPlan(
      id: '2',
      name: 'First Floor',
      imageUrl: 'https://via.placeholder.com/600x400',
      uploadedAt: DateTime.now().subtract(const Duration(days: 1)),
      version: 1,
    ),
  ];

  Future<List<FloorPlan>> getPlans() async {
    await Future.delayed(const Duration(seconds: 1));
    return _plans;
  }

  Future<void> uploadPlan(String name, String filePath) async {
    await Future.delayed(const Duration(seconds: 2));

    if (Random().nextBool()) {
      throw Exception(
        'Conflict detected: A newer version of this floor plan exists.',
      );
    }

    _plans.add(
      FloorPlan(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        imageUrl: 'https://via.placeholder.com/600x400',
        uploadedAt: DateTime.now(),
        version: 1,
      ),
    );
  }

  Future<void> resolveConflictAndUpload(String name, String filePath) async {
    await Future.delayed(const Duration(seconds: 1));
    // Force upload (increment version)
    _plans.add(
      FloorPlan(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        imageUrl: 'https://via.placeholder.com/600x400',
        uploadedAt: DateTime.now(),
        version: 2, // Incremented version
      ),
    );
  }
}

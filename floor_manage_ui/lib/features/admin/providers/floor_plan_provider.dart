import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/floor_plan.dart';
import '../services/floor_plan_service.dart';

final floorPlanServiceProvider = Provider((ref) => FloorPlanService());

final floorPlansProvider = FutureProvider<List<FloorPlan>>((ref) async {
  final service = ref.watch(floorPlanServiceProvider);
  return service.getPlans();
});

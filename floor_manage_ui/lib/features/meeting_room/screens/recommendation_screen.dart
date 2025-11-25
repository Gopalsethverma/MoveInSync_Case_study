import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../../auth/providers/user_provider.dart';

class RecommendationScreen extends ConsumerStatefulWidget {
  const RecommendationScreen({super.key});

  @override
  ConsumerState<RecommendationScreen> createState() =>
      _RecommendationScreenState();
}

class _RecommendationScreenState extends ConsumerState<RecommendationScreen> {
  final _capacityController = TextEditingController();
  final _apiService = ApiService();
  List<dynamic> _recommendedRooms = [];
  bool _isLoading = false;

  Future<void> _getRecommendations() async {
    setState(() => _isLoading = true);
    try {
      final user = ref.read(userProvider);
      final response = await _apiService.get(
        '/meeting-rooms/recommend',
        queryParameters: {
          'capacity': _capacityController.text,
          'start_time': DateTime.now().toUtc().toIso8601String(),
          'end_time':
              DateTime.now()
                  .add(const Duration(hours: 1))
                  .toUtc()
                  .toIso8601String(),
          'user_id': user.id,
        },
      );

      if (response.statusCode == 200) {
        setState(() => _recommendedRooms = response.data);
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Room Recommendations')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _capacityController,
              decoration: const InputDecoration(labelText: 'Required Capacity'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: _getRecommendations,
              child: const Text('Find Rooms'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _recommendedRooms.length,
                itemBuilder: (context, index) {
                  final room = _recommendedRooms[index];
                  return ListTile(
                    title: Text(room['name']),
                    subtitle: Text('Capacity: ${room['capacity']}'),
                    trailing: ElevatedButton(
                      onPressed: () => context.push('/rooms/book', extra: room),
                      child: const Text('Book'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

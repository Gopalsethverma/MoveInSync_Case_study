import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';

class FloorMapScreen extends ConsumerStatefulWidget {
  const FloorMapScreen({super.key});

  @override
  ConsumerState<FloorMapScreen> createState() => _FloorMapScreenState();
}

class _FloorMapScreenState extends ConsumerState<FloorMapScreen> {
  final _apiService = ApiService();
  Map<String, dynamic>? _floorPlan;
  List<dynamic> _rooms = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final planResponse = await _apiService.get('/floor-plans/latest');
      final roomsResponse = await _apiService.get('/meeting-rooms');

      if (mounted) {
        setState(() {
          _floorPlan = planResponse.data;
          _rooms = roomsResponse.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Floor Map')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text('Error: $_error'))
              : _floorPlan == null
              ? const Center(child: Text('No floor plan available'))
              : LayoutBuilder(
                builder: (context, constraints) {
                  return InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Stack(
                      children: [
                        Image.network(
                          '${_apiService.baseUrl.replaceAll('/api', '')}/${_floorPlan!['image_url']}',
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(Icons.broken_image, size: 50),
                            );
                          },
                        ),
                        ..._rooms.map((room) {
                          return Positioned(
                            left: (room['x_coord'] as num).toDouble(),
                            top: (room['y_coord'] as num).toDouble(),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.meeting_room,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  Text(
                                    room['name'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}

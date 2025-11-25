import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/api_service.dart';

class RoomListScreen extends StatefulWidget {
  const RoomListScreen({super.key});

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  final _apiService = ApiService();
  List<dynamic> _rooms = [];
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);
  bool _filterApplied = false;

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    setState(() => _isLoading = true);
    try {
      Map<String, dynamic>? queryParams;
      if (_filterApplied) {
        final startDateTime = DateTime(
          _selectedDate.year, _selectedDate.month, _selectedDate.day,
          _startTime.hour, _startTime.minute
        );
        final endDateTime = DateTime(
          _selectedDate.year, _selectedDate.month, _selectedDate.day,
          _endTime.hour, _endTime.minute
        );
        queryParams = {
          'start_time': startDateTime.toUtc().toIso8601String(),
          'end_time': endDateTime.toUtc().toIso8601String(),
        };
      }

      final response = await _apiService.get('/meeting-rooms', queryParameters: queryParams);
      if (response.statusCode == 200) {
        setState(() {
          _rooms = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting Rooms'),
        actions: [
          IconButton(
            icon: const Icon(Icons.recommend),
            onPressed: () => context.push('/rooms/recommend'),
          ),
        ],
      ),
      body: Column(
        children: [
          ExpansionTile(
            title: const Text('Check Availability'),
            subtitle: Text(_filterApplied 
              ? 'Filtering: ${_startTime.format(context)} - ${_endTime.format(context)}' 
              : 'Tap to filter by time'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2101),
                              );
                              if (picked != null) setState(() => _selectedDate = picked);
                            },
                            child: Text('${_selectedDate.toLocal()}'.split(' ')[0]),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final picked = await showTimePicker(context: context, initialTime: _startTime);
                              if (picked != null) setState(() => _startTime = picked);
                            },
                            child: Text('Start: ${_startTime.format(context)}'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final picked = await showTimePicker(context: context, initialTime: _endTime);
                              if (picked != null) setState(() => _endTime = picked);
                            },
                            child: Text('End: ${_endTime.format(context)}'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() => _filterApplied = true);
                              _fetchRooms();
                            },
                            child: const Text('Check Availability'),
                          ),
                        ),
                        if (_filterApplied)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() => _filterApplied = false);
                              _fetchRooms();
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _rooms.isEmpty
                    ? const Center(child: Text('No rooms available for this time'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _rooms.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final room = _rooms[index];
                          return Card(
                            elevation: 0,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey.shade200),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurple.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.meeting_room, color: Colors.deepPurple),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          room['name'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.people, size: 16, color: Colors.grey.shade600),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Capacity: ${room['capacity']}',
                                              style: TextStyle(color: Colors.grey.shade600),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => context.push('/rooms/book', extra: room),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      minimumSize: Size.zero,
                                    ),
                                    child: const Text('Book'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

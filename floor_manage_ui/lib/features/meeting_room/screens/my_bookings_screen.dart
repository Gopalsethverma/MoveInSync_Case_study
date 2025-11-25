import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/services/api_service.dart';
import '../../auth/providers/user_provider.dart';

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen> {
  final _apiService = ApiService();
  List<dynamic> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    final user = ref.read(userProvider);
    if (user.id == null) return;

    try {
      final response = await _apiService.get('/meeting-rooms/bookings', queryParameters: {'user_id': user.id});
      if (mounted) {
        setState(() {
          _bookings = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? const Center(child: Text('No bookings found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _bookings.length,
                  itemBuilder: (context, index) {
                    final booking = _bookings[index];
                    final roomName = booking['MeetingRoom']?['name'] ?? 'Unknown Room';
                    final startTime = DateTime.parse(booking['start_time']).toLocal();
                    final endTime = DateTime.parse(booking['end_time']).toLocal();
                    final dateFormat = DateFormat('MMM d, yyyy');
                    final timeFormat = DateFormat('h:mm a');

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFEADDFF),
                          child: Icon(Icons.event, color: Color(0xFF21005D)),
                        ),
                        title: Text(roomName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          '${dateFormat.format(startTime)}\n${timeFormat.format(startTime)} - ${timeFormat.format(endTime)}',
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
    );
  }
}

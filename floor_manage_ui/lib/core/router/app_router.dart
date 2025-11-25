import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/admin/screens/upload_floor_plan_screen.dart';
import '../../features/meeting_room/screens/room_list_screen.dart';
import '../../features/meeting_room/screens/booking_screen.dart';
import '../../features/meeting_room/screens/recommendation_screen.dart';
import '../../features/floor_map/screens/floor_map_screen.dart';
import '../../features/meeting_room/screens/my_bookings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/admin/upload',
        builder: (context, state) => const UploadFloorPlanScreen(),
      ),
      GoRoute(
        path: '/rooms',
        builder: (context, state) => const RoomListScreen(),
        routes: [
          GoRoute(
            path: 'book',
            builder: (context, state) {
              final room = state.extra as Map<String, dynamic>;
              return BookingScreen(room: room);
            },
          ),
          GoRoute(
            path: 'recommend',
            builder: (context, state) => const RecommendationScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/floor-map',
        builder: (context, state) => const FloorMapScreen(),
      ),
      GoRoute(
        path: '/my-bookings',
        builder: (context, state) => const MyBookingsScreen(),
      ),
    ],
  );
});

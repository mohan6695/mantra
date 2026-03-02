import 'package:go_router/go_router.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/session/session_screen.dart';
import '../features/calibration/calibration_screen.dart';
import '../features/settings/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/session/:mantraId',
      builder: (context, state) {
        final mantraId = int.parse(state.pathParameters['mantraId']!);
        return SessionScreen(mantraId: mantraId);
      },
    ),
    GoRoute(
      path: '/calibration',
      builder: (context, state) => const CalibrationScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);

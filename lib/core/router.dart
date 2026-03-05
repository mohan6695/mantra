import 'package:go_router/go_router.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/dashboard/mantra_detail_screen.dart';
import '../features/session/session_screen.dart';
import '../features/calibration/calibration_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/verse/verse_picker_screen.dart';
import '../features/verse/verse_session_screen.dart';
import '../features/insights/insights_screen.dart';
import '../features/leaderboard/leaderboard_screen.dart';
import '../features/congregation/congregation_list_screen.dart';
import '../features/congregation/congregation_session_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/mantra/:mantraKey',
      builder: (context, state) {
        final mantraKey = state.pathParameters['mantraKey']!;
        return MantraDetailScreen(mantraKey: mantraKey);
      },
    ),
    GoRoute(
      path: '/session/:mantraId',
      builder: (context, state) {
        final mantraId = int.parse(state.pathParameters['mantraId']!);
        return SessionScreen(mantraId: mantraId);
      },
    ),
    GoRoute(
      path: '/verses',
      builder: (context, state) => const VersePickerScreen(),
    ),
    GoRoute(
      path: '/verse/:verseId',
      builder: (context, state) {
        final verseId = state.pathParameters['verseId']!;
        return VerseSessionScreen(verseId: verseId);
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
    GoRoute(
      path: '/insights',
      builder: (context, state) => const InsightsScreen(),
    ),
    GoRoute(
      path: '/leaderboard',
      builder: (context, state) => const LeaderboardScreen(),
    ),
    GoRoute(
      path: '/congregation',
      builder: (context, state) => const CongregationListScreen(),
    ),
    GoRoute(
      path: '/congregation/active',
      builder: (context, state) => const CongregationSessionScreen(),
    ),
  ],
);

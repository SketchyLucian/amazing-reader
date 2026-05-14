import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/reading_workflow/presentation/reading_dashboard_screen.dart';
import '../features/reading_workflow/presentation/reading_project_setup_screen.dart';
import '../features/reading_workflow/presentation/reading_workspace_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        name: 'dashboard',
        builder: (context, state) => const ReadingDashboardScreen(),
      ),
      GoRoute(
        path: '/projects/new',
        name: 'newReadingProject',
        builder: (context, state) => const ReadingProjectSetupScreen(),
      ),
      GoRoute(
        path: '/projects/:projectId',
        name: 'readingWorkspace',
        builder: (context, state) => ReadingWorkspaceScreen(
          projectId: state.pathParameters['projectId']!,
        ),
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/reader/presentation/reader_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        name: 'reader',
        builder: (context, state) => const ReaderScreen(),
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});

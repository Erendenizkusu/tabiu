import 'package:go_router/go_router.dart';

import '../features/create_room/create_room_screen.dart';
import '../features/home/home_screen.dart';
import '../features/join_room/join_room_screen.dart';
import '../features/room/room_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
    GoRoute(path: '/create', builder: (_, _) => const CreateRoomScreen()),
    GoRoute(path: '/join', builder: (_, _) => const JoinRoomScreen()),
    GoRoute(
      path: '/room/:code',
      builder: (_, state) => RoomShell(code: state.pathParameters['code']!),
    ),
  ],
);

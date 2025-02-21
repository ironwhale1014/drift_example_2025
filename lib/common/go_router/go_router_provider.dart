import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_drift_train/memo/screen/edit_memo_screen.dart';
import 'package:my_drift_train/memo/screen/memo_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../database/database_connector.dart';

part 'go_router_provider.g.dart';

@Riverpod(keepAlive: true)
GoRouter goRouter(Ref ref) {
  return GoRouter(initialLocation: '/memo', routes: routes);
}

final List<GoRoute> routes = [
  GoRoute(
    path: '/memo',
    name: MemoScreen.routeName,
    builder: (context, state) => MemoScreen(),

    routes: [
      GoRoute(
        path: '/write',
        name: EditMemoScreen.routeName,
        builder: (context, state) {
          if (state.extra == null) {
            return EditMemoScreen();
          }
          final Memo memo = state.extra as Memo;
          return EditMemoScreen(memo: memo);
        },
      ),
    ],
  ),
];

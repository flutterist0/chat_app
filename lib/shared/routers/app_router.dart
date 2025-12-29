import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:test_app/feature/auth/presentation/login_screen.dart';
import 'package:test_app/feature/auth/presentation/register_screen.dart';
import 'package:test_app/feature/chat/data/models/chat.dart';
import 'package:test_app/feature/chat/presentation/screens/chat_list_screen.dart';
import 'package:test_app/feature/chat/presentation/screens/chat_screen.dart';
import 'package:test_app/feature/chat/presentation/screens/search_users_screen.dart';
part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
        /// routes go here
        AutoRoute(page: ChatsListRoute.page, initial: true),
        AutoRoute(page: ChatRoute.page),
        AutoRoute(page: SearchUsersRoute.page),
        AutoRoute(page: LoginRoute.page),
        AutoRoute(page: RegisterRoute.page)
      ];
}

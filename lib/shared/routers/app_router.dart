import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:test_app/feature/account/presentation/screens/account_center_screen.dart';
import 'package:test_app/feature/auth/presentation/login_screen.dart';
import 'package:test_app/feature/auth/presentation/register_screen.dart';
import 'package:test_app/feature/chat/data/models/chat.dart';
import 'package:test_app/feature/chat/presentation/screens/chat_list_screen.dart';
import 'package:test_app/feature/chat/presentation/screens/chat_screen.dart';
import 'package:test_app/feature/chat/presentation/screens/search_users_screen.dart';
import 'package:test_app/feature/chat/presentation/screens/relationship_screens.dart';
import 'package:test_app/feature/notification/presentation/screens/notification_screen.dart';
import 'package:test_app/feature/settings/presentation/screens/edit_profile_screen.dart';
import 'package:test_app/feature/settings/presentation/screens/settings_screen.dart';

import '../../splash_screen.dart';
part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: SplashRoute.page, initial: true),
        /// routes go here
        AutoRoute(page: LoginRoute.page),
      AutoRoute(page: RegisterRoute.page),
      AutoRoute(page: EditProfileRoute.page),
      AutoRoute(page: SettingsRoute.page),
      AutoRoute(page: AccountCenterRoute.page),
      AutoRoute(page: ChatsListRoute.page),
      AutoRoute(page: ChatRoute.page),
      AutoRoute(page: SearchUsersRoute.page),
      AutoRoute(page: FollowersRoute.page),
      AutoRoute(page: FollowingRoute.page),
      AutoRoute(page: EditProfileRoute.page),
      AutoRoute(page: NotificationRoute.page)
  ];
}

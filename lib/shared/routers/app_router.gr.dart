// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    ChatRoute.name: (routeData) {
      final args = routeData.argsAs<ChatRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ChatScreen(chat: args.chat),
      );
    },
    ChatsListRoute.name: (routeData) {
      final args = routeData.argsAs<ChatsListRouteArgs>(
          orElse: () => const ChatsListRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ChatsListScreen(key: args.key),
      );
    },
    LoginRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: LoginScreen(),
      );
    },
    RegisterRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: RegisterScreen(),
      );
    },
    SearchUsersRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: SearchUsersScreen(),
      );
    },
  };
}

/// generated route for
/// [ChatScreen]
class ChatRoute extends PageRouteInfo<ChatRouteArgs> {
  ChatRoute({
    required Chat chat,
    List<PageRouteInfo>? children,
  }) : super(
          ChatRoute.name,
          args: ChatRouteArgs(chat: chat),
          initialChildren: children,
        );

  static const String name = 'ChatRoute';

  static const PageInfo<ChatRouteArgs> page = PageInfo<ChatRouteArgs>(name);
}

class ChatRouteArgs {
  const ChatRouteArgs({required this.chat});

  final Chat chat;

  @override
  String toString() {
    return 'ChatRouteArgs{chat: $chat}';
  }
}

/// generated route for
/// [ChatsListScreen]
class ChatsListRoute extends PageRouteInfo<ChatsListRouteArgs> {
  ChatsListRoute({
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          ChatsListRoute.name,
          args: ChatsListRouteArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'ChatsListRoute';

  static const PageInfo<ChatsListRouteArgs> page =
      PageInfo<ChatsListRouteArgs>(name);
}

class ChatsListRouteArgs {
  const ChatsListRouteArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'ChatsListRouteArgs{key: $key}';
  }
}

/// generated route for
/// [LoginScreen]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
      : super(
          LoginRoute.name,
          initialChildren: children,
        );

  static const String name = 'LoginRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [RegisterScreen]
class RegisterRoute extends PageRouteInfo<void> {
  const RegisterRoute({List<PageRouteInfo>? children})
      : super(
          RegisterRoute.name,
          initialChildren: children,
        );

  static const String name = 'RegisterRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SearchUsersScreen]
class SearchUsersRoute extends PageRouteInfo<void> {
  const SearchUsersRoute({List<PageRouteInfo>? children})
      : super(
          SearchUsersRoute.name,
          initialChildren: children,
        );

  static const String name = 'SearchUsersRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

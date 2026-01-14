import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_app/feature/auth/service/auth_service.dart';
import 'package:test_app/feature/chat/logic/bloc/chat_list/chat_list_bloc.dart';
import 'package:test_app/feature/chat/presentation/screens/chat_Screen.dart';
import 'package:test_app/feature/chat/presentation/screens/search_users_screen.dart';
import 'package:test_app/feature/chat/presentation/widgets/chat_list_header.dart';
import 'package:test_app/feature/chat/presentation/widgets/chat_list_item.dart';
import 'package:test_app/feature/chat/presentation/widgets/custom_drawer.dart';
import 'package:test_app/l10n/app_localizations.dart';
import 'package:test_app/shared/injection_container.dart';
import 'package:test_app/shared/routers/app_router.dart';
import 'package:test_app/shared/themes/app_styles.dart';

@RoutePage()
class ChatsListScreen extends StatelessWidget {
  const ChatsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ChatListBloc>()..add(LoadChats()),
      child: const _ChatsListView(),
    );
  }
}

class _ChatsListView extends StatefulWidget {
  const _ChatsListView();

  @override
  State<_ChatsListView> createState() => _ChatsListViewState();
}

class _ChatsListViewState extends State<_ChatsListView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        final currentUser = snapshot.data;
        
        return Scaffold(
          key: _scaffoldKey,
          drawer: CustomDrawer(
            userName: currentUser?.displayName ?? '',
            userEmail: currentUser?.email ?? '',
            userImageUrl: currentUser?.photoURL,
            logout: () {
               getIt<AuthService>().signOut();
               context.router.replace(LoginRoute());
            },
          ),
          body: Column(
            children: [
              ChatListHeader(
                onMenuPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),

              Expanded(
                child: BlocBuilder<ChatListBloc, ChatListState>(
                  builder: (context, state) {
                    if (state is ChatListLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ChatListFailure) {
                      return Center(child: Text("Xəta: ${state.message}"));
                    } else if (state is ChatListLoaded) {
                      if (state.chats.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_bubble_outline, size: 64.sp, color: Colors.grey),
                              SizedBox(height: 16.h),
                              Text(AppLocalizations.of(context)!.noChats),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: state.chats.length,
                        itemBuilder: (context, index) {
                          final chat = state.chats[index];
                          return ChatListItem(
                            chat: chat,
                            onTap: () {
                              context.router.push(ChatRoute(chat: chat));
                            },
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              context.router.push(SearchUsersRoute());
            },
            backgroundColor: AppStyles.primaryBlue,
            elevation: 4.sp,
            child: const Icon(Icons.add),
          ),
        );
      }
    );
  }
}
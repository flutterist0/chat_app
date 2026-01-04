import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_app/feature/auth/service/auth_service.dart';
import 'package:test_app/feature/chat/logic/bloc/chat_list/chat_list_bloc.dart';
import 'package:test_app/feature/chat/presentation/screens/chat_Screen.dart';
import 'package:test_app/feature/chat/presentation/screens/search_users_screen.dart';
import 'package:test_app/feature/chat/presentation/widgets/chat_list_item.dart';
import 'package:test_app/feature/chat/presentation/widgets/custom_drawer.dart';
import 'package:test_app/shared/injection_container.dart';
import 'package:test_app/shared/routers/app_router.dart';

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
  
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomDrawer(
        userName: currentUser?.displayName ?? '',
        userEmail: currentUser?.email ?? '',
        userImageUrl: null,
        logout: () {
          authService.signOut();
          context.router.replace(LoginRoute());
        },
      ),
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Mesajlar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_vert, color: Colors.white),
                          onPressed: () {
                            _scaffoldKey.currentState?.openDrawer();
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Axtar...',
                          hintStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(Icons.search, color: Colors.white70),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20.sp,
                            vertical: 15.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
                          const Text("Hələ heç kimlə danışmamısınız"),
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
        backgroundColor: const Color(0xFF2563EB),
        elevation: 4.sp,
        child: const Icon(Icons.add),
      ),
    );
  }
}
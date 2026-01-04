import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_app/feature/chat/data/models/chat.dart';
import 'package:test_app/feature/chat/data/models/user_profile.dart';
import 'package:test_app/feature/chat/logic/bloc/search_user/search_user_bloc.dart';
import 'package:test_app/feature/chat/presentation/widgets/user_list_item.dart';
import 'package:test_app/shared/injection_container.dart';
import 'package:test_app/shared/routers/app_router.dart';

@RoutePage()
class SearchUsersScreen extends StatelessWidget {
  const SearchUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SearchUserBloc>()..add(LoadUsers()),
      child: const _SearchUsersView(),
    );
  }
}

class _SearchUsersView extends StatefulWidget {
  const _SearchUsersView();

  @override
  State<_SearchUsersView> createState() => _SearchUsersViewState();
}

class _SearchUsersViewState extends State<_SearchUsersView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _startChat(BuildContext context, UserProfile user) {
    Chat newChat = Chat(
      id: user.id,
      name: user.name,
      lastMessage: 'Yeni söhbət',
      time: 'İndi',
      unreadCount: 0,
      isOnline: user.isOnline,
    );

    context.router.push(ChatRoute(chat: newChat));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.sp),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Yeni Mesaj',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.sp, 0.sp, 16.sp, 16.sp),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (query) {
                          context.read<SearchUserBloc>().add(SearchQueryChanged(query));
                        },
                        decoration: InputDecoration(
                          hintText: 'İstifadəçi axtar...',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, color: Colors.grey[600]),
                                  onPressed: () {
                                    _searchController.clear();
                                    context.read<SearchUserBloc>().add(SearchQueryChanged(''));
                                    setState(() {}); 
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20.sp,
                            vertical: 15.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: BlocBuilder<SearchUserBloc, SearchUserState>(
              builder: (context, state) {
                if (state.status == SearchStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state.status == SearchStatus.failure) {
                  return Center(child: Text('Xəta: ${state.errorMessage}'));
                } else if (state.filteredUsers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_search,
                          size: 80.sp,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.allUsers.isEmpty 
                              ? 'Hələ heç kim yoxdur' 
                              : 'İstifadəçi tapılmadı',
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: state.filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = state.filteredUsers[index];
                    return UserListItem(
                      user: user,
                      onTap: () => _startChat(context, user),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
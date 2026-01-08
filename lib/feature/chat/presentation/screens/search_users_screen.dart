import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_app/feature/chat/data/models/chat.dart';
import 'package:test_app/feature/chat/data/models/user_profile.dart';
import 'package:test_app/feature/chat/logic/bloc/search_user/search_user_bloc.dart';
import 'package:test_app/feature/chat/presentation/widgets/search_user_header.dart';
import 'package:test_app/feature/chat/presentation/widgets/user_list_item.dart';
import 'package:test_app/shared/injection_container.dart';
import 'package:test_app/shared/routers/app_router.dart';
import 'package:test_app/shared/themes/app_styles.dart';
import 'package:test_app/shared/utils/app_strings.dart';

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
      lastMessage: AppStrings.newChat,
      time: AppStrings.now,
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
          SearchUserHeader(
            searchController: _searchController,
            onSearchChanged: (query) {
              context.read<SearchUserBloc>().add(SearchQueryChanged(query));
            },
            onClearPressed: () {
              _searchController.clear();
              context.read<SearchUserBloc>().add(SearchQueryChanged(''));
              setState(() {});
            },
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
                          color: AppStyles.grey400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.allUsers.isEmpty 
                              ? AppStrings.noUsersYet 
                              : AppStrings.noUsersFound,
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: AppStyles.grey600,
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
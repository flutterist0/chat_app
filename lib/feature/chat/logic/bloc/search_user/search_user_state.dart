part of 'search_user_bloc.dart';

enum SearchStatus { initial, loading, success, failure }

class SearchUserState {
  final SearchStatus status;
  final List<UserProfile> allUsers;      
  final List<UserProfile> filteredUsers; 
  final String errorMessage;

  const SearchUserState({
    this.status = SearchStatus.initial,
    this.allUsers = const [],
    this.filteredUsers = const [],
    this.errorMessage = '',
  });

  SearchUserState copyWith({
    SearchStatus? status,
    List<UserProfile>? allUsers,
    List<UserProfile>? filteredUsers,
    String? errorMessage,
  }) {
    return SearchUserState(
      status: status ?? this.status,
      allUsers: allUsers ?? this.allUsers,
      filteredUsers: filteredUsers ?? this.filteredUsers,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
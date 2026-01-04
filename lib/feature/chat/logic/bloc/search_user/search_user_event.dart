part of 'search_user_bloc.dart';

@immutable
abstract class SearchUserEvent {}

class LoadUsers extends SearchUserEvent {}

class SearchQueryChanged extends SearchUserEvent {
  final String query;
  SearchQueryChanged(this.query);
}

class UpdateUsersList extends SearchUserEvent {
  final List<UserProfile> users;
  UpdateUsersList(this.users);
}

class SearchErrorOccurred extends SearchUserEvent {
  final String error;
  SearchErrorOccurred(this.error);
}
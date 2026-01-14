part of 'chat_list_bloc.dart';

enum ChatFilter { all, read, unread }
enum ChatSort { date, name }

@immutable
abstract class ChatListEvent {}

class LoadChats extends ChatListEvent {}

class UpdateChats extends ChatListEvent {
  final List<Chat> chats;
  UpdateChats(this.chats);
}

class ChangeFilter extends ChatListEvent {
  final ChatFilter filter;
  ChangeFilter(this.filter);
}

class ChangeSort extends ChatListEvent {
  final ChatSort sort;
  ChangeSort(this.sort);
}

class ChatListError extends ChatListEvent {
  final String message;
  ChatListError(this.message);
}
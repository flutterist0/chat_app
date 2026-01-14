part of 'chat_list_bloc.dart';

@immutable
abstract class ChatListState {}

class ChatListInitial extends ChatListState {}

class ChatListLoading extends ChatListState {}

class ChatListLoaded extends ChatListState {
  final List<Chat> chats;
  final ChatFilter filter;
  final ChatSort sort;

  ChatListLoaded(this.chats, {this.filter = ChatFilter.all, this.sort = ChatSort.date});
}

class ChatListFailure extends ChatListState {
  final String message;
  ChatListFailure(this.message);
}
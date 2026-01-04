part of 'chat_list_bloc.dart';

@immutable
abstract class ChatListState {}

class ChatListInitial extends ChatListState {}

class ChatListLoading extends ChatListState {}

class ChatListLoaded extends ChatListState {
  final List<Chat> chats;
  ChatListLoaded(this.chats);
}

class ChatListFailure extends ChatListState {
  final String message;
  ChatListFailure(this.message);
}
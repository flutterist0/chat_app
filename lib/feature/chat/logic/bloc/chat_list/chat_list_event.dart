part of 'chat_list_bloc.dart';

@immutable
abstract class ChatListEvent {}

class LoadChats extends ChatListEvent {}

class UpdateChats extends ChatListEvent {
  final List<Chat> chats;
  UpdateChats(this.chats);
}

class ChatListError extends ChatListEvent {
  final String message;
  ChatListError(this.message);
}
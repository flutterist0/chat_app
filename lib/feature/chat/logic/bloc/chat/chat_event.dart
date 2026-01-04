part of 'chat_bloc.dart';

@immutable
abstract class ChatEvent {}

class ChatStarted extends ChatEvent {
  final Chat chat;
  ChatStarted(this.chat);
}

class ChatUpdated extends ChatEvent {
  final List<Message> messages;
  ChatUpdated(this.messages);
}

class SendMessage extends ChatEvent {
  final String text;
  SendMessage(this.text);
}

class SendImage extends ChatEvent {
  final ImageSource source;
  SendImage(this.source);
}

class SetReplyMessage extends ChatEvent {
  final Message message;
  SetReplyMessage(this.message);
}


class CancelReply extends ChatEvent {
  CancelReply();
}

class ChatErrorOccurred extends ChatEvent {
  final String error;
  ChatErrorOccurred(this.error);
}
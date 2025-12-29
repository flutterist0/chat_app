class Message {
  final String text;
  final bool isSentByMe;
  final String time;
  final String? replyText;
  final String? replySender;

  Message({
    required this.text,
    required this.isSentByMe,
    required this.time,
    this.replyText,
    this.replySender,
  });
}
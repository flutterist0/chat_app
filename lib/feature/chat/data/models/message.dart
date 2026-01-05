class Message {
  final String id;
  final String text;
  final bool isSentByMe;
  final String time;
  final String? replyText;
  final String? replySender;
  final bool isRead;
  final String type;

  Message({
    required this.id,
    required this.text,
    required this.isSentByMe,
    required this.time,
    this.type = 'text',
    this.replyText,
    this.replySender,
    this.isRead = false,
  });
}
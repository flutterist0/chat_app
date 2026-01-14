class Chat {
  final String id;
  final String name;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isOnline;
  final String? photoUrl;
  final DateTime? lastMessageTime;

  Chat({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    required this.isOnline,
    this.photoUrl,
    this.lastMessageTime,
  });
}

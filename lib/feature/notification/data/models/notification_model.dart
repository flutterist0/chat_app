import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final String? type; 
  final String? senderId;
  final String? senderName;
  final String? senderPhoto;
  final String? status; 

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.isRead,
    this.type,
    this.senderId,
    this.senderName,
    this.senderPhoto,
    this.status,
  });

  factory NotificationModel.fromMap(String id, Map<String, dynamic> map) {
    return NotificationModel(
      id: id,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: map['isRead'] ?? false,
      type: map['type'],
      senderId: map['senderId'],
      senderName: map['senderName'],
      senderPhoto: map['senderPhoto'],
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'type': type,
      'senderId': senderId,
      'senderName': senderName,
      'senderPhoto': senderPhoto,
      'status': status,
    };
  }
}

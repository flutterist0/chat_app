import 'package:test_app/feature/notification/data/models/notification_model.dart';

abstract class NotificationRepository {
  Stream<List<NotificationModel>> getNotifications(String userId);
  Future<void> markAsRead(String userId, String notificationId);
  Future<void> clearAll(String userId);
}

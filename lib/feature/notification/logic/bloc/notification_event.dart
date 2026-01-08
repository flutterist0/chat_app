part of 'notification_bloc.dart';

@immutable
abstract class NotificationEvent {}

class LoadNotifications extends NotificationEvent {
  final String userId;
  LoadNotifications(this.userId);
}

class UpdateNotifications extends NotificationEvent {
  final List<NotificationModel> notifications;
  UpdateNotifications(this.notifications);
}

class MarkAsRead extends NotificationEvent {
  final String userId;
  final String notificationId;
  MarkAsRead(this.userId, this.notificationId);
}

class ClearAllNotifications extends NotificationEvent {
  final String userId;
  ClearAllNotifications(this.userId);
}

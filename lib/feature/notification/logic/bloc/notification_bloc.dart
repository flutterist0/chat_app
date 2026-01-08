import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:test_app/feature/notification/data/models/notification_model.dart';
import 'package:test_app/feature/notification/domain/repositories/notification_repository.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _repository;
  StreamSubscription? _notificationSubscription;

  NotificationBloc(this._repository) : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<UpdateNotifications>((event, emit) => emit(NotificationLoaded(event.notifications)));
    on<MarkAsRead>(_onMarkAsRead);
    on<ClearAllNotifications>(_onClearAllNotifications);
  }

  void _onLoadNotifications(LoadNotifications event, Emitter<NotificationState> emit) {
    emit(NotificationLoading());
    
    _notificationSubscription?.cancel();
    _notificationSubscription = _repository.getNotifications(event.userId).listen(
      (notifications) {
        add(UpdateNotifications(notifications));
      },
      onError: (error) {
        emit(NotificationError(error.toString()));
      },
    );
  }

  Future<void> _onMarkAsRead(MarkAsRead event, Emitter<NotificationState> emit) async {
    try {
      await _repository.markAsRead(event.userId, event.notificationId);
    } catch (e) {
      print("Mark read error: $e");
    }
  }

  Future<void> _onClearAllNotifications(ClearAllNotifications event, Emitter<NotificationState> emit) async {
    try {
      await _repository.clearAll(event.userId);
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _notificationSubscription?.cancel();
    return super.close();
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/services/firebase_service.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.data = const {},
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: data['type'] ?? 'general',
      data: Map<String, dynamic>.from(data['data'] ?? {}),
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'data': data,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  NotificationModel copyWith({
    bool? isRead,
  }) {
    return NotificationModel(
      id: id,
      userId: userId,
      title: title,
      body: body,
      type: type,
      data: data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}

class NotificationsProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      final querySnapshot = await FirebaseService.firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      _notifications = querySnapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();

      notifyListeners();
    } catch (e) {
      _setError('فشل تحميل الإشعارات');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> markAsRead(String userId, String notificationId) async {
    try {
      await FirebaseService.firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});

      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError('فشل تحديث الإشعار');
      return false;
    }
  }

  Future<bool> markAllAsRead(String userId) async {
    try {
      final batch = FirebaseService.firestore.batch();
      final unreadNotifications = _notifications.where((n) => !n.isRead);

      for (final notification in unreadNotifications) {
        batch.update(
          FirebaseService.firestore
              .collection('notifications')
              .doc(notification.id),
          {'isRead': true},
        );
      }

      await batch.commit();

      // Update local state
      for (int i = 0; i < _notifications.length; i++) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('فشل تحديث الإشعارات');
      return false;
    }
  }

  Future<bool> deleteNotification(String userId, String notificationId) async {
    try {
      await FirebaseService.firestore
          .collection('notifications')
          .doc(notificationId)
          .delete();

      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('فشل حذف الإشعار');
      return false;
    }
  }

  Future<bool> clearAllNotifications(String userId) async {
    try {
      final batch = FirebaseService.firestore.batch();

      for (final notification in _notifications) {
        batch.delete(
          FirebaseService.firestore
              .collection('notifications')
              .doc(notification.id),
        );
      }

      await batch.commit();
      _notifications.clear();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('فشل مسح الإشعارات');
      return false;
    }
  }

  Future<bool> sendNotification({
    required String userId,
    required String title,
    required String body,
    String type = 'general',
    Map<String, dynamic> data = const {},
  }) async {
    try {
      final notification = NotificationModel(
        id: '',
        userId: userId,
        title: title,
        body: body,
        type: type,
        data: data,
        createdAt: DateTime.now(),
      );

      await FirebaseService.firestore
          .collection('notifications')
          .add(notification.toFirestore());

      return true;
    } catch (e) {
      _setError('فشل إرسال الإشعار');
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
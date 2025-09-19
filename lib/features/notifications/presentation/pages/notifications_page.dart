import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/notifications_provider.dart';
import '../widgets/notification_card.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final notificationsProvider = Provider.of<NotificationsProvider>(
      context,
      listen: false,
    );

    if (authProvider.isAuthenticated) {
      await notificationsProvider.loadNotifications(authProvider.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        actions: [
          Consumer<NotificationsProvider>(
            builder: (context, notificationsProvider, child) {
              if (notificationsProvider.notifications.isEmpty) {
                return const SizedBox.shrink();
              }

              return PopupMenuButton<String>(
                onSelected: (value) async {
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );

                  switch (value) {
                    case 'mark_all_read':
                      await notificationsProvider.markAllAsRead(
                        authProvider.currentUser!.id,
                      );
                      break;
                    case 'clear_all':
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('مسح جميع الإشعارات'),
                          content: const Text(
                            'هل أنت متأكد من مسح جميع الإشعارات؟',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('إلغاء'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(
                                'مسح',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        await notificationsProvider.clearAllNotifications(
                          authProvider.currentUser!.id,
                        );
                      }
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'mark_all_read',
                    child: Text('تعليم الكل كمقروء'),
                  ),
                  const PopupMenuItem(
                    value: 'clear_all',
                    child: Text('مسح جميع الإشعارات'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationsProvider>(
        builder: (context, notificationsProvider, child) {
          if (notificationsProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: AppTheme.neonBlue,
              ),
            );
          }

          if (notificationsProvider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 100,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد إشعارات',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ستظهر هنا جميع الإشعارات الخاصة بك',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadNotifications,
            color: AppTheme.neonBlue,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notificationsProvider.notifications.length,
              itemBuilder: (context, index) {
                final notification = notificationsProvider.notifications[index];
                return NotificationCard(
                  notification: notification,
                  onTap: () async {
                    final authProvider = Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    );

                    // Mark as read
                    if (!notification.isRead) {
                      await notificationsProvider.markAsRead(
                        authProvider.currentUser!.id,
                        notification.id,
                      );
                    }

                    // Handle notification tap based on type
                    _handleNotificationTap(notification);
                  },
                  onDelete: () async {
                    final authProvider = Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    );
                    await notificationsProvider.deleteNotification(
                      authProvider.currentUser!.id,
                      notification.id,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _handleNotificationTap(notification) {
    switch (notification.type) {
      case 'order_update':
        Navigator.pushNamed(
          context,
          '/order-details',
          arguments: {'orderId': notification.data['orderId']},
        );
        break;
      case 'offer':
        Navigator.pushNamed(
          context,
          '/offer-details',
          arguments: {'offerId': notification.data['offerId']},
        );
        break;
      case 'product':
        Navigator.pushNamed(
          context,
          '/product-details',
          arguments: {'productId': notification.data['productId']},
        );
        break;
      default:
        // Do nothing for general notifications
        break;
    }
  }
}
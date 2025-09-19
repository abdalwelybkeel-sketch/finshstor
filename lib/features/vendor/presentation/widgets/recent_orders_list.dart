import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/order_model.dart';
import '../../../../core/theme/app_theme.dart';

class RecentOrdersList extends StatelessWidget {
  final List<OrderModel> orders;
  final Function(OrderModel) onOrderTap;
  final Function(String, OrderStatus) onStatusUpdate;

  const RecentOrdersList({
    super.key,
    required this.orders,
    required this.onOrderTap,
    required this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (orders.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: theme.colorScheme.onBackground.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد طلبات حتى الآن',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: orders.map((order) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.neonBlue.withOpacity(0.1),
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ListTile(
            onTap: () => onOrderTap(order),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getStatusColor(order.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.receipt_long,
                color: _getStatusColor(order.status),
                size: 20,
              ),
            ),
            title: Text(
              'طلب #${order.id.substring(0, 8)}',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('dd/MM/yyyy - hh:mm a', 'ar').format(order.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${order.total.toInt()} ر.س - ${order.items.length} منتج',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.neonBlue,
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton<OrderStatus>(
              onSelected: (status) => onStatusUpdate(order.id, status),
              itemBuilder: (context) => [
                if (order.status == OrderStatus.pending)
                  const PopupMenuItem(
                    value: OrderStatus.confirmed,
                    child: Text('تأكيد الطلب'),
                  ),
                if (order.status == OrderStatus.pending)
                  const PopupMenuItem(
                    value: OrderStatus.cancelled,
                    child: Text(
                      'رفض الطلب',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                if (order.status == OrderStatus.confirmed)
                  const PopupMenuItem(
                    value: OrderStatus.preparing,
                    child: Text('قيد التحضير'),
                  ),
                if (order.status == OrderStatus.preparing)
                  const PopupMenuItem(
                    value: OrderStatus.shipped,
                    child: Text('تم الشحن'),
                  ),
                if (order.status == OrderStatus.shipped)
                  const PopupMenuItem(
                    value: OrderStatus.delivered,
                    child: Text('تم التسليم'),
                  ),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.statusText,
                  style: TextStyle(
                    color: _getStatusColor(order.status),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.preparing:
        return AppTheme.darkNeonPurple;
      case OrderStatus.shipped:
        return Colors.indigo;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
}
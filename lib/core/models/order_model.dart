import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_model.dart';

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  shipped,
  delivered,
  cancelled,
}

enum PaymentMethod {
  stripe,
  cashOnDelivery,
}

class OrderModel {
  final String id;
  final String userId;
  final String userEmail;
  final String userName;
  final String? vendorId;
  final List<CartItemModel> items;
  final double subtotal;
  final double tax;
  final double shipping;
  final double total;
  final OrderStatus status;
  final PaymentMethod paymentMethod;
  final String? paymentId;
  final Map<String, dynamic> shippingAddress;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deliveryDate;

  OrderModel({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.userName,
    this.vendorId,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    required this.total,
    this.status = OrderStatus.pending,
    required this.paymentMethod,
    this.paymentId,
    required this.shippingAddress,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.deliveryDate,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userEmail: data['userEmail'] ?? '',
      userName: data['userName'] ?? '',
      vendorId: data['vendorId'],
      items: (data['items'] as List<dynamic>?)
          ?.map((item) => CartItemModel(
                id: item['id'] ?? '',
                productId: item['productId'] ?? '',
                productName: item['productName'] ?? '',
                productImage: item['productImage'] ?? '',
                price: (item['price'] ?? 0).toDouble(),
                quantity: item['quantity'] ?? 1,
                selectedSize: item['selectedSize'],
                selectedColor: item['selectedColor'],
                giftWrap: item['giftWrap'],
                greetingCard: item['greetingCard'],
                addedAt: DateTime.now(),
              ))
          .toList() ?? [],
      subtotal: (data['subtotal'] ?? 0).toDouble(),
      tax: (data['tax'] ?? 0).toDouble(),
      shipping: (data['shipping'] ?? 0).toDouble(),
      total: (data['total'] ?? 0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => OrderStatus.pending,
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == data['paymentMethod'],
        orElse: () => PaymentMethod.cashOnDelivery,
      ),
      paymentId: data['paymentId'],
      shippingAddress: Map<String, dynamic>.from(data['shippingAddress'] ?? {}),
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      deliveryDate: data['deliveryDate'] != null
          ? (data['deliveryDate'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'userName': userName,
      'vendorId': vendorId,
      'items': items.map((item) => {
        'id': item.id,
        'productId': item.productId,
        'productName': item.productName,
        'productImage': item.productImage,
        'price': item.price,
        'quantity': item.quantity,
        'selectedSize': item.selectedSize,
        'selectedColor': item.selectedColor,
        'giftWrap': item.giftWrap,
        'greetingCard': item.greetingCard,
      }).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'shipping': shipping,
      'total': total,
      'status': status.name,
      'paymentMethod': paymentMethod.name,
      'paymentId': paymentId,
      'shippingAddress': shippingAddress,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'deliveryDate': deliveryDate != null 
          ? Timestamp.fromDate(deliveryDate!) 
          : null,
    };
  }

  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'في الانتظار';
      case OrderStatus.confirmed:
        return 'مؤكد';
      case OrderStatus.preparing:
        return 'قيد التحضير';
      case OrderStatus.shipped:
        return 'تم الشحن';
      case OrderStatus.delivered:
        return 'تم التسليم';
      case OrderStatus.cancelled:
        return 'ملغي';
    }
  }

  OrderModel copyWith({
    OrderStatus? status,
    DateTime? updatedAt,
    DateTime? deliveryDate,
    String? notes,
    String? vendorId,
  }) {
    return OrderModel(
      id: id,
      userId: userId,
      userEmail: userEmail,
      userName: userName,
      vendorId: vendorId ?? this.vendorId,
      items: items,
      subtotal: subtotal,
      tax: tax,
      shipping: shipping,
      total: total,
      status: status ?? this.status,
      paymentMethod: paymentMethod,
      paymentId: paymentId,
      shippingAddress: shippingAddress,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deliveryDate: deliveryDate ?? this.deliveryDate,
    );
  }
}
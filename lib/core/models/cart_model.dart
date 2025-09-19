import 'package:cloud_firestore/cloud_firestore.dart';

class CartItemModel {
  final String id;
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final String? selectedSize;
  final String? selectedColor;
  final String? giftWrap;
  final String? greetingCard;
  final String? vendorId; // Added vendorId
  final DateTime addedAt;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    this.selectedSize,
    this.selectedColor,
    this.giftWrap,
    this.greetingCard,
    this.vendorId, // Added vendorId
    required this.addedAt,
  });

  factory CartItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CartItemModel(
      id: doc.id,
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      productImage: data['productImage'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      quantity: data['quantity'] ?? 1,
      selectedSize: data['selectedSize'],
      selectedColor: data['selectedColor'],
      giftWrap: data['giftWrap'],
      greetingCard: data['greetingCard'],
      vendorId: data['vendorId'], // Added vendorId
      addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
      'selectedSize': selectedSize,
      'selectedColor': selectedColor,
      'giftWrap': giftWrap,
      'greetingCard': greetingCard,
      'vendorId': vendorId, // Added vendorId
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }

  double get totalPrice => price * quantity;

  CartItemModel copyWith({
    String? id,
    String? productId,
    String? productName,
    String? productImage,
    double? price,
    int? quantity,
    String? selectedSize,
    String? selectedColor,
    String? giftWrap,
    String? greetingCard,
    String? vendorId, // Added vendorId
    DateTime? addedAt,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedColor: selectedColor ?? this.selectedColor,
      giftWrap: giftWrap ?? this.giftWrap,
      greetingCard: greetingCard ?? this.greetingCard,
      vendorId: vendorId ?? this.vendorId, // Added vendorId
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
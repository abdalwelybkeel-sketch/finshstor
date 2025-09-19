import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<String> images;
  final String category;
  final String vendorId;
  final String vendorName;
  final int stock;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final Map<String, dynamic> attributes;
  final double rating;
  final int reviewCount;
  final List<String> sizes;
  final List<String> colors;
  final bool isFeatured;
  final double? discount;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.images,
    required this.category,
    required this.vendorId,
    required this.vendorName,
    required this.stock,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
    this.attributes = const {},
    this.rating = 0.0,
    this.reviewCount = 0,
    this.sizes = const [],
    this.colors = const [],
    this.isFeatured = false,
    this.discount,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      images: List<String>.from(data['images'] ?? []),
      category: data['category'] ?? '',
      vendorId: data['vendorId'] ?? '',
      vendorName: data['vendorName'] ?? '',
      stock: data['stock'] ?? 0,
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      tags: List<String>.from(data['tags'] ?? []),
      attributes: Map<String, dynamic>.from(data['attributes'] ?? {}),
      rating: (data['rating'] ?? 0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      sizes: List<String>.from(data['sizes'] ?? []),
      colors: List<String>.from(data['colors'] ?? []),
      isFeatured: data['isFeatured'] ?? false,
      discount: data['discount']?.toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'images': images,
      'category': category,
      'vendorId': vendorId,
      'vendorName': vendorName,
      'stock': stock,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'tags': tags,
      'attributes': attributes,
      'rating': rating,
      'reviewCount': reviewCount,
      'sizes': sizes,
      'colors': colors,
      'isFeatured': isFeatured,
      'discount': discount,
    };
  }

  double get finalPrice {
    if (discount != null && discount! > 0) {
      return price - (price * discount! / 100);
    }
    return price;
  }

  bool get hasDiscount => discount != null && discount! > 0;

  bool get isInStock => stock > 0;

  ProductModel copyWith({
    String? name,
    String? description,
    double? price,
    List<String>? images,
    String? category,
    int? stock,
    bool? isActive,
    DateTime? updatedAt,
    List<String>? tags,
    Map<String, dynamic>? attributes,
    double? rating,
    int? reviewCount,
    List<String>? sizes,
    List<String>? colors,
    bool? isFeatured,
    double? discount,
  }) {
    return ProductModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      images: images ?? this.images,
      category: category ?? this.category,
      vendorId: vendorId,
      vendorName: vendorName,
      stock: stock ?? this.stock,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      attributes: attributes ?? this.attributes,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      sizes: sizes ?? this.sizes,
      colors: colors ?? this.colors,
      isFeatured: isFeatured ?? this.isFeatured,
      discount: discount ?? this.discount,
    );
  }
}
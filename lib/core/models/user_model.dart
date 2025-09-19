import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final String? profileImage;
  final bool isVendor;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> addresses;
  final Map<String, dynamic> preferences;
  final String? fcmToken;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    this.profileImage,
    this.isVendor = false,
    required this.createdAt,
    required this.updatedAt,
    this.addresses = const [],
    this.preferences = const {},
    this.fcmToken,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      phoneNumber: data['phoneNumber'],
      profileImage: data['profileImage'],
      isVendor: data['isVendor'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      addresses: List<String>.from(data['addresses'] ?? []),
      preferences: Map<String, dynamic>.from(data['preferences'] ?? {}),
      fcmToken: data['fcmToken'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
      'isVendor': isVendor,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'addresses': addresses,
      'preferences': preferences,
      'fcmToken': fcmToken,
    };
  }

  UserModel copyWith({
    String? email,
    String? fullName,
    String? phoneNumber,
    String? profileImage,
    bool? isVendor,
    DateTime? updatedAt,
    List<String>? addresses,
    Map<String, dynamic>? preferences,
    String? fcmToken,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImage: profileImage ?? this.profileImage,
      isVendor: isVendor ?? this.isVendor,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      addresses: addresses ?? this.addresses,
      preferences: preferences ?? this.preferences,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/services/firebase_service.dart';

class AddressModel {
  final String id;
  final String userId;
  final String name;
  final String address;
  final String city;
  final String phone;
  final double? latitude;
  final double? longitude;
  final bool isDefault;
  final DateTime createdAt;

  AddressModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.address,
    required this.city,
    required this.phone,
    this.latitude,
    this.longitude,
    this.isDefault = false,
    required this.createdAt,
  });

  factory AddressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AddressModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      phone: data['phone'] ?? '',
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      isDefault: data['isDefault'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'address': address,
      'city': city,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
      'isDefault': isDefault,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  AddressModel copyWith({
    String? name,
    String? address,
    String? city,
    String? phone,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id,
      userId: userId,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      phone: phone ?? this.phone,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt,
    );
  }
}

class AddressesProvider extends ChangeNotifier {
  List<AddressModel> _addresses = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AddressModel> get addresses => _addresses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadAddresses(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      final querySnapshot = await FirebaseService.firestore
          .collection('addresses')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      _addresses = querySnapshot.docs
          .map((doc) => AddressModel.fromFirestore(doc))
          .toList();

      notifyListeners();
    } catch (e) {
      _setError('فشل تحميل العناوين');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addAddress({
    required String userId,
    required String name,
    required String address,
    required String city,
    required String phone,
    double? latitude,
    double? longitude,
    bool isDefault = false,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // If this is the default address, remove default from others
      if (isDefault) {
        await _removeDefaultFromOthers(userId);
      }

      final addressModel = AddressModel(
        id: '',
        userId: userId,
        name: name,
        address: address,
        city: city,
        phone: phone,
        latitude: latitude,
        longitude: longitude,
        isDefault: isDefault,
        createdAt: DateTime.now(),
      );

      final docRef = await FirebaseService.firestore
          .collection('addresses')
          .add(addressModel.toFirestore());

      _addresses.insert(0, AddressModel(
        id: docRef.id,
        userId: userId,
        name: name,
        address: address,
        city: city,
        phone: phone,
        latitude: latitude,
        longitude: longitude,
        isDefault: isDefault,
        createdAt: DateTime.now(),
      ));

      notifyListeners();
      return true;
    } catch (e) {
      _setError('فشل إضافة العنوان');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateAddress(AddressModel address) async {
    try {
      _setLoading(true);
      _clearError();

      // If this is the default address, remove default from others
      if (address.isDefault) {
        await _removeDefaultFromOthers(address.userId);
      }

      await FirebaseService.firestore
          .collection('addresses')
          .doc(address.id)
          .update(address.toFirestore());

      final index = _addresses.indexWhere((a) => a.id == address.id);
      if (index != -1) {
        _addresses[index] = address;
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError('فشل تحديث العنوان');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteAddress(String userId, String addressId) async {
    try {
      await FirebaseService.firestore
          .collection('addresses')
          .doc(addressId)
          .delete();

      _addresses.removeWhere((address) => address.id == addressId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('فشل حذف العنوان');
      return false;
    }
  }

  Future<bool> setDefaultAddress(String userId, String addressId) async {
    try {
      // Remove default from all addresses
      await _removeDefaultFromOthers(userId);

      // Set this address as default
      await FirebaseService.firestore
          .collection('addresses')
          .doc(addressId)
          .update({'isDefault': true});

      // Update local state
      for (int i = 0; i < _addresses.length; i++) {
        _addresses[i] = _addresses[i].copyWith(
          isDefault: _addresses[i].id == addressId,
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('فشل تعيين العنوان الافتراضي');
      return false;
    }
  }

  Future<void> _removeDefaultFromOthers(String userId) async {
    final batch = FirebaseService.firestore.batch();
    final querySnapshot = await FirebaseService.firestore
        .collection('addresses')
        .where('userId', isEqualTo: userId)
        .where('isDefault', isEqualTo: true)
        .get();

    for (final doc in querySnapshot.docs) {
      batch.update(doc.reference, {'isDefault': false});
    }

    await batch.commit();
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
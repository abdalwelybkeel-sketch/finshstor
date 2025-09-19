import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/services/firebase_service.dart';

class PaymentMethodModel {
  final String id;
  final String userId;
  final String cardType;
  final String last4;
  final String expiryMonth;
  final String expiryYear;
  final String holderName;
  final bool isDefault;
  final DateTime createdAt;

  PaymentMethodModel({
    required this.id,
    required this.userId,
    required this.cardType,
    required this.last4,
    required this.expiryMonth,
    required this.expiryYear,
    required this.holderName,
    this.isDefault = false,
    required this.createdAt,
  });

  factory PaymentMethodModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentMethodModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      cardType: data['cardType'] ?? '',
      last4: data['last4'] ?? '',
      expiryMonth: data['expiryMonth'] ?? '',
      expiryYear: data['expiryYear'] ?? '',
      holderName: data['holderName'] ?? '',
      isDefault: data['isDefault'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'cardType': cardType,
      'last4': last4,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'holderName': holderName,
      'isDefault': isDefault,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  PaymentMethodModel copyWith({
    bool? isDefault,
  }) {
    return PaymentMethodModel(
      id: id,
      userId: userId,
      cardType: cardType,
      last4: last4,
      expiryMonth: expiryMonth,
      expiryYear: expiryYear,
      holderName: holderName,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt,
    );
  }
}

class PaymentProvider extends ChangeNotifier {
  List<PaymentMethodModel> _paymentMethods = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PaymentMethodModel> get paymentMethods => _paymentMethods;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadPaymentMethods(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      final querySnapshot = await FirebaseService.firestore
          .collection('payment_methods')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      _paymentMethods = querySnapshot.docs
          .map((doc) => PaymentMethodModel.fromFirestore(doc))
          .toList();

      notifyListeners();
    } catch (e) {
      _setError('فشل تحميل طرق الدفع');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addPaymentMethod({
    required String userId,
    required String cardType,
    required String last4,
    required String expiryMonth,
    required String expiryYear,
    required String holderName,
    bool isDefault = false,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // If this is the default payment method, remove default from others
      if (isDefault) {
        await _removeDefaultFromOthers(userId);
      }

      final paymentMethod = PaymentMethodModel(
        id: '',
        userId: userId,
        cardType: cardType,
        last4: last4,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        holderName: holderName,
        isDefault: isDefault,
        createdAt: DateTime.now(),
      );

      final docRef = await FirebaseService.firestore
          .collection('payment_methods')
          .add(paymentMethod.toFirestore());

      _paymentMethods.insert(0, PaymentMethodModel(
        id: docRef.id,
        userId: userId,
        cardType: cardType,
        last4: last4,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        holderName: holderName,
        isDefault: isDefault,
        createdAt: DateTime.now(),
      ));

      notifyListeners();
      return true;
    } catch (e) {
      _setError('فشل إضافة طريقة الدفع');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deletePaymentMethod(String userId, String paymentMethodId) async {
    try {
      await FirebaseService.firestore
          .collection('payment_methods')
          .doc(paymentMethodId)
          .delete();

      _paymentMethods.removeWhere((method) => method.id == paymentMethodId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('فشل حذف طريقة الدفع');
      return false;
    }
  }

  Future<bool> setDefaultPaymentMethod(String userId, String paymentMethodId) async {
    try {
      // Remove default from all payment methods
      await _removeDefaultFromOthers(userId);

      // Set this payment method as default
      await FirebaseService.firestore
          .collection('payment_methods')
          .doc(paymentMethodId)
          .update({'isDefault': true});

      // Update local state
      for (int i = 0; i < _paymentMethods.length; i++) {
        _paymentMethods[i] = _paymentMethods[i].copyWith(
          isDefault: _paymentMethods[i].id == paymentMethodId,
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('فشل تعيين طريقة الدفع الافتراضية');
      return false;
    }
  }

  Future<void> _removeDefaultFromOthers(String userId) async {
    final batch = FirebaseService.firestore.batch();
    final querySnapshot = await FirebaseService.firestore
        .collection('payment_methods')
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
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/services/firebase_service.dart';

class OfferModel {
  final String id;
  final String title;
  final String description;
  final String image;
  final double discount;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final List<String> applicableProducts;

  OfferModel({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.discount,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.applicableProducts = const [],
  });

  factory OfferModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OfferModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      image: data['image'] ?? '',
      discount: (data['discount'] ?? 0).toDouble(),
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
      applicableProducts: List<String>.from(data['applicableProducts'] ?? []),
    );
  }

  bool get isValid {
    final now = DateTime.now();
    return isActive && now.isAfter(startDate) && now.isBefore(endDate);
  }
}

class CouponModel {
  final String id;
  final String code;
  final String title;
  final String description;
  final double discount;
  final double? minOrderAmount;
  final int? maxUses;
  final int currentUses;
  final DateTime expiryDate;
  final bool isActive;

  CouponModel({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.discount,
    this.minOrderAmount,
    this.maxUses,
    this.currentUses = 0,
    required this.expiryDate,
    this.isActive = true,
  });

  factory CouponModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CouponModel(
      id: doc.id,
      code: data['code'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      discount: (data['discount'] ?? 0).toDouble(),
      minOrderAmount: data['minOrderAmount']?.toDouble(),
      maxUses: data['maxUses'],
      currentUses: data['currentUses'] ?? 0,
      expiryDate: (data['expiryDate'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
    );
  }

  bool get isValid {
    final now = DateTime.now();
    return isActive && 
           now.isBefore(expiryDate) && 
           (maxUses == null || currentUses < maxUses!);
  }
}

class OffersProvider extends ChangeNotifier {
  List<OfferModel> _offers = [];
  List<CouponModel> _coupons = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<OfferModel> get offers => _offers.where((offer) => offer.isValid).toList();
  List<CouponModel> get coupons => _coupons.where((coupon) => coupon.isValid).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadOffers() async {
    try {
      _setLoading(true);
      _clearError();

      final querySnapshot = await FirebaseService.firestore
          .collection('offers')
          .where('isActive', isEqualTo: true)
          .orderBy('startDate', descending: true)
          .get();

      _offers = querySnapshot.docs
          .map((doc) => OfferModel.fromFirestore(doc))
          .toList();

      notifyListeners();
    } catch (e) {
      _setError('فشل تحميل العروض');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadCoupons() async {
    try {
      _setLoading(true);
      _clearError();

      final querySnapshot = await FirebaseService.firestore
          .collection('coupons')
          .where('isActive', isEqualTo: true)
          .orderBy('expiryDate', descending: false)
          .get();

      _coupons = querySnapshot.docs
          .map((doc) => CouponModel.fromFirestore(doc))
          .toList();

      notifyListeners();
    } catch (e) {
      _setError('فشل تحميل الكوبونات');
    } finally {
      _setLoading(false);
    }
  }

  Future<OfferModel?> getOffer(String offerId) async {
    try {
      final doc = await FirebaseService.firestore
          .collection('offers')
          .doc(offerId)
          .get();

      if (doc.exists) {
        return OfferModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      _setError('فشل تحميل العرض');
      return null;
    }
  }

  Future<CouponModel?> validateCoupon(String code, double orderAmount) async {
    try {
      final querySnapshot = await FirebaseService.firestore
          .collection('coupons')
          .where('code', isEqualTo: code.toUpperCase())
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        _setError('كود الخصم غير صحيح');
        return null;
      }

      final coupon = CouponModel.fromFirestore(querySnapshot.docs.first);

      if (!coupon.isValid) {
        _setError('كود الخصم منتهي الصلاحية');
        return null;
      }

      if (coupon.minOrderAmount != null && orderAmount < coupon.minOrderAmount!) {
        _setError('الحد الأدنى للطلب ${coupon.minOrderAmount!.toInt()} ر.س');
        return null;
      }

      return coupon;
    } catch (e) {
      _setError('فشل التحقق من كود الخصم');
      return null;
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
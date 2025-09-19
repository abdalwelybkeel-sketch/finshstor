import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/models/product_model.dart';
import '../../../../core/services/firebase_service.dart';

class FavoritesProvider extends ChangeNotifier {
  List<ProductModel> _favorites = [];
  List<String> _favoriteIds = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ProductModel> get favorites => _favorites;
  List<String> get favoriteIds => _favoriteIds;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool isFavorite(String productId) {
    return _favoriteIds.contains(productId);
  }

  Future<void> loadFavorites(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      // Load favorite product IDs
      final favoritesDoc = await FirebaseService.firestore
          .collection('user_favorites')
          .doc(userId)
          .get();

      if (favoritesDoc.exists) {
        _favoriteIds = List<String>.from(favoritesDoc.data()?['productIds'] ?? []);
      } else {
        _favoriteIds = [];
      }

      // Load favorite products
      if (_favoriteIds.isNotEmpty) {
        final productsSnapshot = await FirebaseService.productsCollection
            .where(FieldPath.documentId, whereIn: _favoriteIds)
            .get();

        _favorites = productsSnapshot.docs
            .map((doc) => ProductModel.fromFirestore(doc))
            .toList();
      } else {
        _favorites = [];
      }

      notifyListeners();
    } catch (e) {
      _setError('فشل تحميل المفضلة');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> toggleFavorite(String userId, ProductModel product) async {
    try {
      final isFav = isFavorite(product.id);
      
      if (isFav) {
        // Remove from favorites
        _favoriteIds.remove(product.id);
        _favorites.removeWhere((p) => p.id == product.id);
      } else {
        // Add to favorites
        _favoriteIds.add(product.id);
        _favorites.add(product);
      }

      // Update Firestore
      await FirebaseService.firestore
          .collection('user_favorites')
          .doc(userId)
          .set({
        'productIds': _favoriteIds,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      notifyListeners();
      return true;
    } catch (e) {
      _setError('فشل تحديث المفضلة');
      return false;
    }
  }

  Future<bool> addToFavorites(String userId, ProductModel product) async {
    if (isFavorite(product.id)) return true;

    try {
      _favoriteIds.add(product.id);
      _favorites.add(product);

      await FirebaseService.firestore
          .collection('user_favorites')
          .doc(userId)
          .set({
        'productIds': _favoriteIds,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      notifyListeners();
      return true;
    } catch (e) {
      _setError('فشل إضافة المنتج للمفضلة');
      return false;
    }
  }

  Future<bool> removeFromFavorites(String userId, String productId) async {
    if (!isFavorite(productId)) return true;

    try {
      _favoriteIds.remove(productId);
      _favorites.removeWhere((p) => p.id == productId);

      await FirebaseService.firestore
          .collection('user_favorites')
          .doc(userId)
          .set({
        'productIds': _favoriteIds,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      notifyListeners();
      return true;
    } catch (e) {
      _setError('فشل حذف المنتج من المفضلة');
      return false;
    }
  }

  Future<bool> clearFavorites(String userId) async {
    try {
      _favoriteIds.clear();
      _favorites.clear();

      await FirebaseService.firestore
          .collection('user_favorites')
          .doc(userId)
          .delete();

      notifyListeners();
      return true;
    } catch (e) {
      _setError('فشل مسح المفضلة');
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
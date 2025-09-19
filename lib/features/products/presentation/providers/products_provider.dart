import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/models/product_model.dart';
import '../../../../core/services/firebase_service.dart';

class ProductsProvider extends ChangeNotifier {
  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String? _selectedCategory;
  double? _minPrice;
  double? _maxPrice;
  String _sortBy = 'name'; // name, price, rating, newest

  List<ProductModel> get products => _filteredProducts.isEmpty && _searchQuery.isEmpty 
      ? _products 
      : _filteredProducts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;
  String get sortBy => _sortBy;

  Future<void> loadProducts() async {
    try {
      _setLoading(true);
      _clearError();

      final querySnapshot = await FirebaseService.productsCollection
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      _products = querySnapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();

      _applyFilters();
      notifyListeners();
    } catch (e) {
      _setError('فشل تحميل المنتجات');
    } finally {
      _setLoading(false);
    }
  }

  Future<ProductModel?> getProduct(String productId) async {
    try {
      final doc = await FirebaseService.productsCollection.doc(productId).get();
      if (doc.exists) {
        return ProductModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      _setError('فشل تحميل المنتج');
      return null;
    }
  }

  void searchProducts(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  void filterByCategory(String? category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void filterByPrice(double? minPrice, double? maxPrice) {
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    _applyFilters();
    notifyListeners();
  }

  void sortProducts(String sortBy) {
    _sortBy = sortBy;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _minPrice = null;
    _maxPrice = null;
    _sortBy = 'name';
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredProducts = List.from(_products);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      _filteredProducts = _filteredProducts.where((product) {
        return product.name.toLowerCase().contains(_searchQuery) ||
               product.description.toLowerCase().contains(_searchQuery) ||
               product.category.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    // Apply category filter
    if (_selectedCategory != null) {
      _filteredProducts = _filteredProducts.where((product) {
        return product.category == _selectedCategory;
      }).toList();
    }

    // Apply price filter
    if (_minPrice != null) {
      _filteredProducts = _filteredProducts.where((product) {
        return product.finalPrice >= _minPrice!;
      }).toList();
    }

    if (_maxPrice != null) {
      _filteredProducts = _filteredProducts.where((product) {
        return product.finalPrice <= _maxPrice!;
      }).toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'name':
        _filteredProducts.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'price_low':
        _filteredProducts.sort((a, b) => a.finalPrice.compareTo(b.finalPrice));
        break;
      case 'price_high':
        _filteredProducts.sort((a, b) => b.finalPrice.compareTo(a.finalPrice));
        break;
      case 'rating':
        _filteredProducts.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'newest':
        _filteredProducts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
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
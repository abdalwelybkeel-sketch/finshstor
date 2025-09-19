import 'package:flutter/material.dart';

import '../../../../core/models/product_model.dart';
import '../../../../core/services/firebase_service.dart';

class SearchProvider extends ChangeNotifier {
  List<ProductModel> _searchResults = [];
  List<String> _recentSearches = [];
  List<String> _popularSearches = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  List<ProductModel> get searchResults => _searchResults;
  List<String> get recentSearches => _recentSearches;
  List<String> get popularSearches => _popularSearches;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> searchProducts(String query) async {
    if (query.trim().isEmpty) {
      _searchResults.clear();
      _searchQuery = '';
      notifyListeners();
      return;
    }

    try {
      _setLoading(true);
      _clearError();
      _searchQuery = query.trim();

      final querySnapshot = await FirebaseService.productsCollection
          .where('isActive', isEqualTo: true)
          .get();

      _searchResults = querySnapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .where((product) {
            final searchTerm = query.toLowerCase();
            return product.name.toLowerCase().contains(searchTerm) ||
                   product.description.toLowerCase().contains(searchTerm) ||
                   product.category.toLowerCase().contains(searchTerm) ||
                   product.tags.any((tag) => tag.toLowerCase().contains(searchTerm));
          })
          .toList();

      notifyListeners();
    } catch (e) {
      _setError('فشل البحث');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadRecentSearches() async {
    // In a real app, this would load from local storage or user preferences
    _recentSearches = [
      'باقات الورد الأحمر',
      'باقات الزفاف',
      'ورود بيضاء',
      'باقات التخرج',
    ];
    notifyListeners();
  }

  Future<void> loadPopularSearches() async {
    // In a real app, this would load from analytics or database
    _popularSearches = [
      'باقات الحب',
      'ورود حمراء',
      'باقات الزفاف',
      'ورود بيضاء',
      'باقات التخرج',
      'ورود صفراء',
      'باقات المناسبات',
      'ورود وردية',
    ];
    notifyListeners();
  }

  void addToRecentSearches(String query) {
    if (query.trim().isEmpty) return;
    
    _recentSearches.remove(query);
    _recentSearches.insert(0, query);
    
    // Keep only the last 10 searches
    if (_recentSearches.length > 10) {
      _recentSearches = _recentSearches.take(10).toList();
    }
    
    notifyListeners();
    // In a real app, save to local storage here
  }

  void clearRecentSearches() {
    _recentSearches.clear();
    notifyListeners();
    // In a real app, clear from local storage here
  }

  void clearSearch() {
    _searchResults.clear();
    _searchQuery = '';
    notifyListeners();
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
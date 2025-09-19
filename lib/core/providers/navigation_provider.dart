import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;
  int _cartItemCount = 0;

  int get currentIndex => _currentIndex;
  int get cartItemCount => _cartItemCount;

  void setIndex(int index) {
    // Ensure index is within valid range (0-3 for 4 tabs)
    if (index >= 0 && index <= 3) {
    _currentIndex = index;
    notifyListeners();
    }
  }

  void updateCartItemCount(int count) {
    _cartItemCount = count;
    notifyListeners();
  }
}
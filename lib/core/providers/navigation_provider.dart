import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;
  int _cartItemCount = 0;

  int get currentIndex => _currentIndex;
  int get cartItemCount => _cartItemCount;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void updateCartItemCount(int count) {
    _cartItemCount = count;
    notifyListeners();
  }
}
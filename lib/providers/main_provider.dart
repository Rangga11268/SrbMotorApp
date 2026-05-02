import 'package:flutter/material.dart';

class MainProvider with ChangeNotifier {
  int _selectedIndex = 2;

  int get selectedIndex => _selectedIndex;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}

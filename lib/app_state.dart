import 'package:flutter/foundation.dart';

/// Drives tab switching plus the shop screen's filter/search, so the home
/// screen can deep-link into a category without prop-drilling callbacks.
class AppState extends ChangeNotifier {
  int tab = 0;
  String filter = 'all';
  String query = '';

  void goTab(int index) {
    tab = index;
    notifyListeners();
  }

  void showCategory(String key) {
    filter = key;
    query = '';
    tab = 1;
    notifyListeners();
  }

  void showBrand(String brand) {
    filter = 'all';
    query = brand;
    tab = 1;
    notifyListeners();
  }

  void search(String q) {
    query = q;
    filter = 'all';
    tab = 1;
    notifyListeners();
  }

  void setFilter(String key) {
    filter = key;
    query = '';
    notifyListeners();
  }
}

final appState = AppState();

import 'package:flutter/material.dart';
import '../models/category.dart';

class CategoryProvider with ChangeNotifier {
  List<Category> _categories = [];

  List<Category> get categories => _categories;

  List<Category> get incomeCategories =>
      _categories.where((cat) => cat.type == 'income').toList();

  List<Category> get expenseCategories =>
      _categories.where((cat) => cat.type == 'expense').toList();

  CategoryProvider() {
    _initializeDefaultCategories();
  }

  void _initializeDefaultCategories() {
    _categories.addAll([
      // Default Income Categories
      Category(
        id: '1',
        name: 'Sales',
        type: 'income',
        icon: Icons.shopping_bag.codePoint.toString(),
        color: Colors.green.value,
      ),
      Category(
        id: '2',
        name: 'Services',
        type: 'income',
        icon: Icons.design_services.codePoint.toString(),
        color: Colors.blue.value,
      ),
      Category(
        id: '3',
        name: 'Investments',
        type: 'income',
        icon: Icons.trending_up.codePoint.toString(),
        color: Colors.teal.value,
      ),

      // Default Expense Categories
      Category(
        id: '4',
        name: 'Food & Dining',
        type: 'expense',
        icon: Icons.fastfood.codePoint.toString(),
        color: Colors.red.value,
      ),
      Category(
        id: '5',
        name: 'Shopping',
        type: 'expense',
        icon: Icons.shopping_cart.codePoint.toString(),
        color: Colors.pink.value,
      ),
      Category(
        id: '6',
        name: 'Transport',
        type: 'expense',
        icon: Icons.directions_car.codePoint.toString(),
        color: Colors.orange.value,
      ),
      Category(
        id: '7',
        name: 'Utilities',
        type: 'expense',
        icon: Icons.electric_bolt.codePoint.toString(),
        color: Colors.purple.value,
      ),
      Category(
        id: '8',
        name: 'Healthcare',
        type: 'expense',
        icon: Icons.medical_services.codePoint.toString(),
        color: Colors.blue.value,
      ),
    ]);
    notifyListeners();
  }

  void addCategory(Category category) {
    _categories.add(category);
    notifyListeners();
  }

  void updateCategory(String id, Category updatedCategory) {
    final index = _categories.indexWhere((cat) => cat.id == id);
    if (index != -1) {
      _categories[index] = updatedCategory;
      notifyListeners();
    }
  }

  void deleteCategory(String id) {
    _categories.removeWhere((cat) => cat.id == id);
    notifyListeners();
  }

  Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Category> getCategoriesByType(String type) {
    return _categories.where((cat) => cat.type == type).toList();
  }
}

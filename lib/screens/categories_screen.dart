import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../models/category.dart';
import '../widgets/category_dialog.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Categories'),
        backgroundColor: Colors.blue[700],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Income Categories'),
            Tab(text: 'Expense Categories'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoriesList('income'),
          _buildCategoriesList('expense'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(
            context, _tabController.index == 0 ? 'income' : 'expense'),
        child: Icon(Icons.add),
        backgroundColor: Colors.blue[700],
      ),
    );
  }

  Widget _buildCategoriesList(String type) {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        final categories = type == 'income'
            ? categoryProvider.incomeCategories
            : categoryProvider.expenseCategories;

        return categories.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.category, size: 64, color: Colors.grey[400]),
                    SizedBox(height: 16),
                    Text(
                      'No categories found',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    Text(
                      'Tap + to add a new category',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return _buildCategoryCard(category, context);
                },
              );
      },
    );
  }

  Widget _buildCategoryCard(Category category, BuildContext context) {
    final color = category.color != null ? Color(category.color!) : Colors.grey;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: category.icon != null
              ? Icon(
                  IconData(int.parse(category.icon!),
                      fontFamily: 'MaterialIcons'),
                  color: color,
                )
              : Icon(Icons.category, color: color),
        ),
        title: Text(
          category.name,
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          category.type == 'income' ? 'Income' : 'Expense',
          style: TextStyle(
            color: category.type == 'income' ? Colors.green : Colors.red,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showEditCategoryDialog(context, category),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteDialog(context, category),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, String type) {
    showDialog(
      context: context,
      builder: (context) => CategoryDialog(type: type),
    );
  }

  void _showEditCategoryDialog(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (context) =>
          CategoryDialog(category: category), // Fixed - type is now optional
    );
  }

  void _showDeleteDialog(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<CategoryProvider>(context, listen: false)
                  .deleteCategory(category.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Category deleted successfully')),
              );
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

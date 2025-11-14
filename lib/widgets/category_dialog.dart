import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../models/category.dart';

class CategoryDialog extends StatefulWidget {
  final String? type; // Make type optional
  final Category? category;

  const CategoryDialog({
    Key? key,
    this.type, // Now optional
    this.category,
  }) : super(key: key);

  @override
  _CategoryDialogState createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<CategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedType = 'expense';
  String? _selectedIcon;
  int? _selectedColor;

  // Available options
  final List<IconData> categoryIcons = [
    Icons.fastfood,
    Icons.shopping_cart,
    Icons.local_gas_station,
    Icons.home,
    Icons.medical_services,
    Icons.school,
    Icons.celebration,
    Icons.car_repair,
    Icons.phone,
    Icons.wifi,
    Icons.electric_bolt,
    Icons.water_drop,
    Icons.movie,
    Icons.fitness_center,
    Icons.attach_money,
    Icons.business_center,
    Icons.savings,
    Icons.account_balance,
  ];

  final List<Color> categoryColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.cyan,
    Colors.amber,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      // Editing existing category
      _nameController.text = widget.category!.name;
      _selectedType = widget.category!.type;
      _selectedIcon = widget.category!.icon;
      _selectedColor = widget.category!.color;
    } else {
      // Adding new category - type is required
      _selectedType =
          widget.type ?? 'expense'; // Use provided type or default to expense
      _selectedColor = categoryColors.first.value;
      _selectedIcon = categoryIcons.first.codePoint.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.category == null ? 'Add Category' : 'Edit Category'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Category Type - Only show when adding new category
              if (widget.category == null) ...[
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'income',
                      child: Row(
                        children: [
                          Icon(Icons.arrow_upward, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Income'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'expense',
                      child: Row(
                        children: [
                          Icon(Icons.arrow_downward, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Expense'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                    });
                  },
                ),
                SizedBox(height: 16),
              ],

              // Color Selection
              Text('Color', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categoryColors.map((color) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color.value;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: _selectedColor == color.value
                            ? Border.all(color: Colors.black, width: 3)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),

              // Icon Selection
              Text('Icon', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categoryIcons.take(12).map((icon) {
                  final iconCode = icon.codePoint.toString();
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIcon = iconCode;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _selectedIcon == iconCode
                            ? Color(_selectedColor!).withOpacity(0.3)
                            : Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: _selectedIcon == iconCode
                            ? Color(_selectedColor!)
                            : Colors.grey[600],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveCategory,
          child: Text(widget.category == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }

  void _saveCategory() {
    if (_formKey.currentState!.validate()) {
      final categoryProvider =
          Provider.of<CategoryProvider>(context, listen: false);

      if (widget.category == null) {
        // Add new category
        final newCategory = Category(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text,
          type: _selectedType,
          icon: _selectedIcon,
          color: _selectedColor,
        );
        categoryProvider.addCategory(newCategory);
      } else {
        // Update existing category
        final updatedCategory = Category(
          id: widget.category!.id,
          name: _nameController.text,
          type: _selectedType, // Keep the original type when editing
          icon: _selectedIcon,
          color: _selectedColor,
        );
        categoryProvider.updateCategory(widget.category!.id, updatedCategory);
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.category == null
                ? 'Category added successfully'
                : 'Category updated successfully',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

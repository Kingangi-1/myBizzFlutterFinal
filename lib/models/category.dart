class Category {
  final String id;
  final String name;
  final String type;
  final int? color;
  final String? icon;

  Category({
    required this.id,
    required this.name,
    required this.type,
    this.color,
    this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'color': color,
      'icon': icon,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      color: map['color'],
      icon: map['icon'],
    );
  }
}

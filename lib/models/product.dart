class Product {
  int? id;
  String imageUrl;
  String name;
  String description;
  double price;
  int stock;
  String createdAt;

  Product({
    this.id,
    required this.imageUrl,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['product_id'] as int?,
      imageUrl: json['image_url'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      stock: json['stock'] as int,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': id,
      'image_url': imageUrl,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'created_at': createdAt,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? oldPrice;
  final String category;
  final String imageUrl;
  final int stock;
  final double rating;
  final int reviewCount;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.oldPrice,
    required this.category,
    required this.imageUrl,
    required this.stock,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      oldPrice: json['old_price'] != null ? (json['old_price']).toDouble() : null,
      category: json['category'] ?? '',
      imageUrl: json['image_url'] ?? '',
      stock: json['stock'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  double get discountPercent {
    if (oldPrice == null || oldPrice! <= price) return 0;
    return ((oldPrice! - price) / oldPrice!) * 100;
  }

  bool get hasDiscount => oldPrice != null && oldPrice! > price;
}
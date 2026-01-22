class CartItem {
  final String id;
  final String userId;
  final String productId;
  final String productName;
  final double price;
  final String imageUrl;
  int quantity;
  final DateTime createdAt;

  CartItem({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.imageUrl,
    required this.quantity,
    required this.createdAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      productId: json['product_id'] ?? '',
      productName: json['product_name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['image_url'] ?? '',
      quantity: json['quantity'] ?? 1,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'image_url': imageUrl,
      'quantity': quantity,
    };
  }

  double get totalPrice => price * quantity;
}
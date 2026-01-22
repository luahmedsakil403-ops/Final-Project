import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shop_hub/models/product.dart';
import 'package:shop_hub/models/cart_item.dart';
import 'package:shop_hub/models/order.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Product Operations
  Future<List<Product>> getAllProducts() async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((item) => Product.fromJson(item))
          .toList();
    } catch (e) {
      print('Error fetching products: $e');
      throw e;
    }
  }

  Future<Product?> getProductById(String productId) async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('id', productId)
          .single();
      
      return Product.fromJson(response);
    } catch (e) {
      print('Error getting product: $e');
      return null;
    }
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('category', category)
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((item) => Product.fromJson(item))
          .toList();
    } catch (e) {
      print('Error fetching products by category: $e');
      throw e;
    }
  }

  // Cart Operations
  Future<void> addToCart({
    required String userId,
    required String productId,
    required String productName,
    required double price,
    required String imageUrl,
    int quantity = 1,
  }) async {
    try {
      await _supabase
          .from('cart')
          .upsert({
            'user_id': userId,
            'product_id': productId,
            'product_name': productName,
            'price': price,
            'image_url': imageUrl,
            'quantity': quantity,
          }, onConflict: 'user_id, product_id');
    } catch (e) {
      print('Error adding to cart: $e');
      throw e;
    }
  }

  Future<List<CartItem>> getCartItems(String userId) async {
    try {
      final response = await _supabase
          .from('cart')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((item) => CartItem.fromJson(item))
          .toList();
    } catch (e) {
      print('Error fetching cart items: $e');
      throw e;
    }
  }

  Future<void> updateCartItemQuantity(String cartItemId, int quantity) async {
    try {
      await _supabase
          .from('cart')
          .update({'quantity': quantity})
          .eq('id', cartItemId);
    } catch (e) {
      print('Error updating cart item: $e');
      throw e;
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    try {
      await _supabase
          .from('cart')
          .delete()
          .eq('id', cartItemId);
    } catch (e) {
      print('Error removing from cart: $e');
      throw e;
    }
  }

  Future<void> clearCart(String userId) async {
    try {
      await _supabase
          .from('cart')
          .delete()
          .eq('user_id', userId);
    } catch (e) {
      print('Error clearing cart: $e');
      throw e;
    }
  }

  // Order Operations
  Future<String> createOrder({
    required String userId,
    required double totalAmount,
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final orderNumber = 'ORD-${DateTime.now().millisecondsSinceEpoch}';
      
      final orderResponse = await _supabase
          .from('orders')
          .insert({
            'user_id': userId,
            'order_number': orderNumber,
            'total_amount': totalAmount,
            'payment_method': paymentMethod,
            'payment_status': 'completed',
            'order_status': 'processing',
          })
          .select()
          .single();
      
      final orderId = orderResponse['id'] as String;
      
      for (final item in items) {
        await _supabase
            .from('order_items')
            .insert({
              'order_id': orderId,
              'product_id': item['product_id'],
              'product_name': item['product_name'],
              'quantity': item['quantity'],
              'price': item['price'],
            });
      }
      
      await _supabase
          .from('payments')
          .insert({
            'order_id': orderId,
            'amount': totalAmount,
            'method': paymentMethod,
            'transaction_id': 'TXN-${DateTime.now().millisecondsSinceEpoch}',
            'status': 'completed',
          });
      
      return orderNumber;
    } catch (e) {
      print('Error creating order: $e');
      throw e;
    }
  }

  Future<List<Order>> getUserOrders(String userId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((item) => Order.fromJson(item))
          .toList();
    } catch (e) {
      print('Error fetching orders: $e');
      throw e;
    }
  }
}
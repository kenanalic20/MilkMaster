import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:milkmaster_mobile/models/cart_model.dart';
import 'package:milkmaster_mobile/models/products_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartProvider with ChangeNotifier {
  Cart _cart = Cart();
  int? _userId;
  String get _cartKey => _userId != null ? 'shopping_cart_user_$_userId' : 'shopping_cart_guest';

  Cart get cart => _cart;
  int get itemCount => _cart.itemCount;
  double get totalAmount => _cart.totalAmount;
  List<CartItem> get items => _cart.items;

  CartProvider() {
    _loadCart();
  }

  // Call this when user logs in
  Future<void> setUser(int userId) async {
    if (_userId != userId) {
      _userId = userId;
      await _loadCart();
    }
  }

  // Call this when user logs out
  Future<void> clearUser() async {
    await clearCart();
    _userId = null;
    _cart = Cart();
    notifyListeners();
  }

  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_cartKey);

      if (cartJson != null) {
        final cartData = json.decode(cartJson);
        _cart = Cart.fromJson(cartData);
        notifyListeners();
      }
    } catch (e) {
      print('Error loading cart: $e');
    }
  }

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = json.encode(_cart.toJson());
      await prefs.setString(_cartKey, cartJson);
    } catch (e) {
      print('Error saving cart: $e');
    }
  }

  Future<bool> addToCart(Product product, {int quantity = 1, double size = 1.0}) async {
    // Validate quantity > 0
    if (quantity <= 0) {
      print('Invalid quantity: $quantity');
      return false;
    }

    // Validate stock availability
    // Backend only checks: item.Quantity > product.Quantity
    // Backend reduces stock by: product.Quantity -= item.Quantity
    final availableQuantity = product.quantity;

    if (quantity > availableQuantity) {
      print('Not enough stock: Available=$availableQuantity, Requested=$quantity');
      return false;
    }

    // Check existing cart items to prevent exceeding stock
    final existingItem = getCartItem(product.id, size);
    if (existingItem != null) {
      final newTotalQuantity = existingItem.quantity + quantity;
      
      if (newTotalQuantity > availableQuantity) {
        print('Adding would exceed stock: Available=$availableQuantity, InCart=${existingItem.quantity}, Trying to add=$quantity');
        return false;
      }
    }

    // All validations passed
    _cart.addItem(product, quantity, size);
    await _saveCart();
    notifyListeners();
    return true;
  }

  Future<void> removeFromCart(int productId, double size) async {
    _cart.removeItem(productId, size);
    await _saveCart();
    notifyListeners();
  }

  Future<bool> updateQuantity(int productId, double size, int quantity) async {
    final item = getCartItem(productId, size);
    if (item == null) return false;

    // Validate quantity > 0
    if (quantity <= 0) {
      print('Invalid quantity: $quantity');
      return false;
    }

    // Validate new quantity against available stock
    // Backend only checks: item.Quantity > product.Quantity
    final availableQuantity = item.product.quantity;

    if (quantity > availableQuantity) {
      print('Cannot update: Available=$availableQuantity, Requested=$quantity');
      return false;
    }

    _cart.updateQuantity(productId, size, quantity);
    await _saveCart();
    notifyListeners();
    return true;
  }

  Future<void> clearCart() async {
    _cart.clear();
    await _saveCart();
    notifyListeners();
  }

  bool isProductInCart(int productId) {
    return _cart.isProductInCart(productId);
  }

  CartItem? getCartItem(int productId, double size) {
    return _cart.getCartItem(productId, size);
  }

  // For creating order when checking out
  Map<String, dynamic> getOrderData() {
    final orderData = {
      'items': _cart.items
          .map((item) {
            final orderItem = {
              'productId': item.product.id,
              'quantity': item.quantity,        // This is what backend uses to reduce stock
              'unitSize': item.size,            // This is only used for price calculation
            };
            
            // Debug logging
            print('Order Item: Product ${item.product.id}');
            print('  Quantity: ${item.quantity} (backend will reduce stock by this amount)');
            print('  Unit Size: ${item.size} (used for price: quantity * pricePerUnit * unitSize)');
            print('  Available in Backend: ${item.product.quantity}');
            
            return orderItem;
          })
          .toList(),
    };
    
    print('Full Order Data: ${json.encode(orderData)}');
    return orderData;
  }
}

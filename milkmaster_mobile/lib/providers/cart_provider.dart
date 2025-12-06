import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:milkmaster_mobile/models/cart_model.dart';
import 'package:milkmaster_mobile/models/products_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartProvider with ChangeNotifier {
  Cart _cart = Cart();
  int? _userId;
  String get _cartKey =>
      _userId != null ? 'shopping_cart_user_$_userId' : 'shopping_cart_guest';

  Cart get cart => _cart;
  int get itemCount => _cart.itemCount;
  double get totalAmount => _cart.totalAmount;
  List<CartItem> get items => _cart.items;

  CartProvider() {
    _loadCart();
  }

  Future<void> setUser(int userId) async {
    if (_userId != userId) {
      _userId = userId;
      await _loadCart();
    }
  }

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

  Future<bool> addToCart(
    Product product, {
    int quantity = 1,
    double size = 1.0,
  }) async {
    if (quantity <= 0) {
      return false;
    }

    final availableQuantity = product.quantity;

    if (quantity > availableQuantity) {
      return false;
    }

    final existingItem = getCartItem(product.id, size);
    if (existingItem != null) {
      final newTotalQuantity = existingItem.quantity + quantity;

      if (newTotalQuantity > availableQuantity) {
        return false;
      }
    }

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

    if (quantity <= 0) {
      return false;
    }

    final availableQuantity = item.product.quantity;

    if (quantity > availableQuantity) {
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

  
}

import 'package:json_annotation/json_annotation.dart';
import 'package:milkmaster_mobile/models/products_model.dart';

part 'cart_model.g.dart';

@JsonSerializable(explicitToJson: true)
class Cart {
  final List<CartItem> items;

  Cart({List<CartItem>? items}) : items = items ?? [];

  int get itemCount => items.length;

  double get totalAmount {
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  void addItem(Product product, int quantity, double size) {
    final existingIndex = items.indexWhere(
      (item) => item.product.id == product.id && item.size == size,
    );

    if (existingIndex >= 0) {
      items[existingIndex].quantity += quantity;
    } else {
      items.add(CartItem(
        product: product,
        quantity: quantity,
        size: size,
      ));
    }
  }

  void removeItem(int productId, double size) {
    items.removeWhere(
      (item) => item.product.id == productId && item.size == size,
    );
  }

  void updateQuantity(int productId, double size, int quantity) {
    final index = items.indexWhere(
      (item) => item.product.id == productId && item.size == size,
    );
    if (index >= 0) {
      if (quantity <= 0) {
        items.removeAt(index);
      } else {
        items[index].quantity = quantity;
      }
    }
  }

  void clear() {
    items.clear();
  }

  bool isProductInCart(int productId) {
    return items.any((item) => item.product.id == productId);
  }

  CartItem? getCartItem(int productId, double size) {
    try {
      return items.firstWhere(
        (item) => item.product.id == productId && item.size == size,
      );
    } catch (e) {
      return null;
    }
  }

  factory Cart.fromJson(Map<String, dynamic> json) => _$CartFromJson(json);
  Map<String, dynamic> toJson() => _$CartToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CartItem {
  final Product product;
  int quantity;
  final double size; // Size in liters (0.5, 1.0, 2.0, etc.)

  CartItem({
    required this.product,
    required this.quantity,
    required this.size,
  });

  double get totalPrice => (product.pricePerUnit * size) * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      _$CartItemFromJson(json);
  Map<String, dynamic> toJson() => _$CartItemToJson(this);
}

import 'package:flutter/material.dart';
import 'package:milkmaster_mobile/providers/cart_provider.dart';
import 'package:milkmaster_mobile/providers/orders_provider.dart';
import 'package:milkmaster_mobile/utils/widget_helpers.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  final Function(int)? onNavigateToProductDetails;

  const CartScreen({super.key, this.onNavigateToProductDetails});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isProcessingCheckout = false;

  Future<void> _handleCheckout() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);

    if (cartProvider.items.isEmpty) {
      showCustomDialog(
        context: context,
        title: 'Cart Empty',
        message: 'Your cart is empty. Add some products before checking out.',
        onConfirm: () {},
        showCancel: false,
      );
      return;
    }

    setState(() {
      _isProcessingCheckout = true;
    });

    try {
      // Prepare order items in the format backend expects
      final orderItems = cartProvider.items
          .map((item) => {
                'productId': item.product.id,
                'quantity': item.quantity,
                'unitSize': item.size,
              })
          .toList();

      // Create order
      final result = await ordersProvider.checkout(orderItems);

      if (mounted) {
        if (result.success) {
          // Clear cart after successful order
          await cartProvider.clearCart();

          showCustomDialog(
            context: context,
            title: 'Order Placed Successfully',
            message: 'Your order has been placed successfully!',
            onConfirm: () {
              Navigator.pop(context); // Close cart screen
            },
            showCancel: false,
          );
        } else {
          showCustomDialog(
            context: context,
            title: 'Order Failed',
            message: result.errorMessage ?? 'Failed to place order. Please try again.',
            onConfirm: () {},
            showCancel: false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showCustomDialog(
          context: context,
          title: 'Error',
          message: 'An error occurred: ${e.toString()}',
          onConfirm: () {},
          showCancel: false,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingCheckout = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          final cartItems = cartProvider.items;

          if (cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add some products to get started',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final cartItem = cartItems[index];
                    final product = cartItem.product;
                    final unitSymbol = product.unit?.symbol ?? 'L';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: InkWell(
                        onTap: () {
                          if (widget.onNavigateToProductDetails != null) {
                            Navigator.pop(context);
                            widget.onNavigateToProductDetails!(product.id);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              // Product Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  fixLocalhostUrl(product.imageUrl),
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.image_not_supported),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Product Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Size: ${cartItem.size == cartItem.size.toInt() ? '${cartItem.size.toInt()}$unitSymbol' : '${cartItem.size}$unitSymbol'}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${(product.pricePerUnit * cartItem.size).toStringAsFixed(2)} BAM/${cartItem.size == cartItem.size.toInt() ? '${cartItem.size.toInt()}$unitSymbol' : '${cartItem.size}$unitSymbol'}',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.secondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        // Quantity Controls
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey[300]!),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.remove, size: 18),
                                                onPressed: cartItem.quantity > 1
                                                    ? () {
                                                        cartProvider.updateQuantity(
                                                          product.id,
                                                          cartItem.size,
                                                          cartItem.quantity - 1,
                                                        );
                                                      }
                                                    : null,
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(
                                                  minWidth: 32,
                                                  minHeight: 32,
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                                child: Text(
                                                  '${cartItem.quantity}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.add, size: 18),
                                                onPressed: () async {
                                                  final success = await cartProvider.updateQuantity(
                                                    product.id,
                                                    cartItem.size,
                                                    cartItem.quantity + 1,
                                                  );
                                                  
                                                  if (!success && context.mounted) {
                                                    final availableQty = product.quantity.toDouble();
                                                    final currentQty = cartItem.quantity * cartItem.size;
                                                    
                                                    showCustomDialog(
                                                      context: context,
                                                      title: 'Stock Limit Reached',
                                                      message: 'Cannot add more of this product.\n\n'
                                                          'In cart: ${currentQty.toStringAsFixed(1)}$unitSymbol\n'
                                                          'Available stock: ${availableQty.toStringAsFixed(1)}$unitSymbol',
                                                      onConfirm: () {},
                                                      showCancel: false,
                                                    );
                                                  }
                                                },
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(
                                                  minWidth: 32,
                                                  minHeight: 32,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                     Text(
                                          '${cartItem.totalPrice.toStringAsFixed(2)} BAM',
                                          style: Theme.of(context).textTheme.headlineLarge,)
                                  ],
                                ),
                              ),
                              // Delete Button
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Remove Item'),
                                      content: const Text(
                                        'Are you sure you want to remove this item from your cart?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            cartProvider.removeFromCart(
                                              product.id,
                                              cartItem.size,
                                            );
                                          },
                                          child: const Text(
                                            'Remove',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Bottom Summary
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: SafeArea(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${cartProvider.totalAmount.toStringAsFixed(2)} BAM',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isProcessingCheckout ? null : _handleCheckout,
                         
                          child: _isProcessingCheckout
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Proceed to Checkout',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

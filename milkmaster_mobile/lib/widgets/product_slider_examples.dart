/// Example usage of ProductSlider widget in different scenarios
/// This file demonstrates how to use the reusable ProductSlider component

import 'package:flutter/material.dart';
import 'package:milkmaster_mobile/models/products_model.dart';
import 'package:milkmaster_mobile/providers/products_provider.dart';
import 'package:milkmaster_mobile/widgets/product_slider.dart';
import 'package:provider/provider.dart';

/// Example 1: Show recommended products (as used in HomeScreen)
class RecommendedProductsExample extends StatefulWidget {
  const RecommendedProductsExample({super.key});

  @override
  State<RecommendedProductsExample> createState() =>
      _RecommendedProductsExampleState();
}

class _RecommendedProductsExampleState
    extends State<RecommendedProductsExample> {
  List<Product> _products = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRecommendedProducts();
  }

  Future<void> _loadRecommendedProducts() async {
    setState(() => _isLoading = true);
    try {
      final productProvider = context.read<ProductProvider>();
      final products = await productProvider.getRecommendedProducts();
      if (mounted) {
        setState(() {
          _products = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      debugPrint('Error loading recommended products: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProductSlider(
      products: _products,
      isLoading: _isLoading,
      title: 'Recommended Products',
      onSeeAll: () {
        // Navigate to products screen
        debugPrint('Navigate to all recommended products');
      },
      onProductTap: (product) {
        // Navigate to product details
        debugPrint('Tapped product: ${product.title}');
      },
      onAddToCart: (product) {
        // Add to cart logic
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added "${product.title}" to cart'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        );
      },
    );
  }
}

/// Example 2: Show products filtered by cattle category
class ProductsByCattleCategoryExample extends StatefulWidget {
  final int cattleCategoryId;
  final String cattleCategoryName;

  const ProductsByCattleCategoryExample({
    super.key,
    required this.cattleCategoryId,
    required this.cattleCategoryName,
  });

  @override
  State<ProductsByCattleCategoryExample> createState() =>
      _ProductsByCattleCategoryExampleState();
}

class _ProductsByCattleCategoryExampleState
    extends State<ProductsByCattleCategoryExample> {
  List<Product> _products = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProductsByCattleCategory();
  }

  Future<void> _loadProductsByCattleCategory() async {
    setState(() => _isLoading = true);
    try {
      final productProvider = context.read<ProductProvider>();
      // Fetch products and filter by cattle category
      final allProducts = await productProvider.fetchAll();
      final filteredProducts = allProducts.items.where((product) {
        return product.cattleCategory?.id == widget.cattleCategoryId;
      }).toList();

      if (mounted) {
        setState(() {
          _products = filteredProducts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      debugPrint('Error loading products by cattle category: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProductSlider(
      products: _products,
      isLoading: _isLoading,
      title: 'Products for ${widget.cattleCategoryName}',
      onSeeAll: () {
        // Navigate to filtered products screen
        debugPrint(
          'Navigate to all products for cattle category ${widget.cattleCategoryId}',
        );
      },
      onProductTap: (product) {
        // Navigate to product details
        debugPrint('Tapped product: ${product.title}');
      },
      onAddToCart: (product) {
        // Add to cart logic
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added "${product.title}" to cart'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        );
      },
    );
  }
}

/// Example 3: Show products by product category
class ProductsByProductCategoryExample extends StatefulWidget {
  final int productCategoryId;
  final String productCategoryName;

  const ProductsByProductCategoryExample({
    super.key,
    required this.productCategoryId,
    required this.productCategoryName,
  });

  @override
  State<ProductsByProductCategoryExample> createState() =>
      _ProductsByProductCategoryExampleState();
}

class _ProductsByProductCategoryExampleState
    extends State<ProductsByProductCategoryExample> {
  List<Product> _products = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProductsByProductCategory();
  }

  Future<void> _loadProductsByProductCategory() async {
    setState(() => _isLoading = true);
    try {
      final productProvider = context.read<ProductProvider>();
      // Fetch products and filter by product category
      final allProducts = await productProvider.fetchAll();
      final filteredProducts = allProducts.items.where((product) {
        return product.productCategories?.any(
              (category) => category.id == widget.productCategoryId,
            ) ??
            false;
      }).toList();

      if (mounted) {
        setState(() {
          _products = filteredProducts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      debugPrint('Error loading products by product category: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProductSlider(
      products: _products,
      isLoading: _isLoading,
      title: '${widget.productCategoryName} Products',
      onSeeAll: () {
        // Navigate to filtered products screen
        debugPrint(
          'Navigate to all products for product category ${widget.productCategoryId}',
        );
      },
      onProductTap: (product) {
        // Navigate to product details
        debugPrint('Tapped product: ${product.title}');
      },
      onAddToCart: (product) {
        // Add to cart logic
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added "${product.title}" to cart'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        );
      },
    );
  }
}

/// Example 4: Simple usage without title and callbacks
class SimpleProductSliderExample extends StatelessWidget {
  final List<Product> products;

  const SimpleProductSliderExample({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return ProductSlider(
      products: products,
      // Uses default behaviors for tap and add to cart
    );
  }
}

/// Example 5: Custom height and card width
class CustomSizedProductSliderExample extends StatelessWidget {
  final List<Product> products;

  const CustomSizedProductSliderExample({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return ProductSlider(
      products: products,
      title: 'Featured Products',
      height: 320, // Custom height
      cardWidth: 200, // Wider cards
      onProductTap: (product) {
        debugPrint('Product tapped: ${product.title}');
      },
    );
  }
}

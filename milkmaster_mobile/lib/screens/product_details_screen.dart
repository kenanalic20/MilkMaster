import 'package:flutter/material.dart';
import 'package:milkmaster_mobile/models/products_model.dart';
import 'package:milkmaster_mobile/providers/products_provider.dart';
import 'package:milkmaster_mobile/utils/widget_helpers.dart';
import 'package:milkmaster_mobile/widgets/product_slider.dart';
import 'package:provider/provider.dart';

class ProductDetailsScreen extends StatefulWidget {
  final int productId;
  final void Function(int productId)? onNavigateToProductDetails;

  const ProductDetailsScreen({
    Key? key,
    required this.productId,
    this.onNavigateToProductDetails,
  }) : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;
  double _selectedSize = 1.0;
  Product? _product;
  bool _isLoading = true;
  String? _errorMessage;
  late ProductProvider _productProvider;
  List<Product> _recommendedProducts = [];
  bool _isLoadingRecommended = false;

  @override
  void initState() {
    super.initState();
    _productProvider = context.read<ProductProvider>();
    _fetchProductDetails();
  }

  @override
  void didUpdateWidget(ProductDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.productId != widget.productId) {
      _fetchProductDetails();
    }
  }

  Future<void> _fetchProductDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final product = await _productProvider.getById(widget.productId);

      if (mounted) {
        setState(() {
          _product = product;
          _isLoading = false;
        });
        _fetchRecommendedProducts();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load product details: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchRecommendedProducts() async {
    try {
      setState(() {
        _isLoadingRecommended = true;
      });

      final recommended = await _productProvider.getRecommendedProducts();

      if (mounted) {
        setState(() {
          _recommendedProducts =
              recommended
                  .where((p) => p.id != widget.productId)
                  .take(10)
                  .toList();
          _isLoadingRecommended = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRecommended = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null || _product == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Product not found',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchProductDetails,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductImage(),
          _buildProductInfo(),
          _buildCategoryTags(),
          _buildPriceSection(),
          _buildSizeSelector(),
          _buildQuantitySelector(),
          _buildAddToCartButton(),
          _buildTabs(),
          _buildRecommendedProducts(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Center(
        child: Container(
          width: 382,
          height: 215,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 1,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              fixLocalhostUrl(_product!.imageUrl),
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, size: 80),
                  ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_product!.title, style: Theme.of(context).textTheme.titleLarge),
          Text(
            'Fresh from local farm',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildCategoryTags() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ...(_product!.productCategories?.map((category) {
                return _buildCategoryChip(category.name.toLowerCase());
              }).toList() ??
              []),
          if (_product!.cattleCategory != null)
            _buildCategoryChip(_product!.cattleCategory!.name.toLowerCase()),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildPriceSection() {
    final unitSymbol = _product!.unit?.symbol ?? 'L';
    final totalPrice = _product!.pricePerUnit * _selectedSize;
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Text(
        '${formatDouble(totalPrice)} BAM/$unitSymbol',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }

  Widget _buildSizeSelector() {
    final unitSymbol = _product!.unit?.symbol ?? 'L';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Size',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          Row(
            children: [
              _buildSizeOption(0.5, unitSymbol),
              const SizedBox(width: 8),
              _buildSizeOption(1.0, unitSymbol),
              const SizedBox(width: 8),
              _buildSizeOption(2.0, unitSymbol),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSizeOption(double size, String unitSymbol) {
    final isSelected = _selectedSize == size;
    final sizeText = size == size.toInt() ? '${size.toInt()}$unitSymbol' : '$size$unitSymbol';
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSize = size;
        });
      },
      child: Container(
        width: 50,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white,
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.secondary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            sizeText,
            style: Theme.of(context).textTheme.bodyMedium
          ),
        ),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quantity',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildQuantityButton(
                  icon: Icons.remove,
                  onTap: () {
                    if (_quantity > 1) {
                      setState(() {
                        _quantity--;
                      });
                    }
                  },
                ),
                Container(
                  width: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: Colors.grey[300]!),
                      right: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Text(
                    _quantity.toString(),
                  ),
                ),
                _buildQuantityButton(
                  icon: Icons.add,
                  onTap: () {
                    setState(() {
                      _quantity++;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: Colors.grey[700]),
      ),
    );
  }

  Widget _buildAddToCartButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
      child: SizedBox(
        width: double.infinity,
        height: 44,
        child: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Added ${_quantity}x "${_product!.title}" to cart',
                ),
              ),
            );
          },
         
          child: Text(
            'Add to cart',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color:Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.normal
            )
            
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: Theme.of(context).colorScheme.secondary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).colorScheme.secondary,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            tabs: const [Tab(text: 'Description'), Tab(text: 'Nutrition')],
          ),
          SizedBox(
            height: 200,
            child: TabBarView(
              children: [_buildDescriptionTab(), _buildNutritionTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        _product!.description ?? 'No description available.',
        style: const TextStyle(fontSize: 14, height: 1.5),
      ),
    );
  }

  Widget _buildNutritionTab() {
    final nutrition = _product!.nutrition;

    if (nutrition == null) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text('No nutritional information available.')),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nutritional Information',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (nutrition.energy != null)
            _buildNutritionRow('Energy', '${nutrition.energy!} kcal'),
          if (nutrition.fat != null)
            _buildNutritionRow('Fat', '${nutrition.fat!} g'),
          if (nutrition.carbohydrates != null)
            _buildNutritionRow(
              'Carbohydrates',
              '${nutrition.carbohydrates!} g',
            ),
          if (nutrition.protein != null)
            _buildNutritionRow('Protein', '${nutrition.protein!} g'),
          if (nutrition.salt != null)
            _buildNutritionRow('Salt', '${nutrition.salt!} g'),
          if (nutrition.calcium != null)
            _buildNutritionRow('Calcium', '${nutrition.calcium!} mg'),
        ],
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedProducts() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ProductSlider(
        products: _recommendedProducts,
        isLoading: _isLoadingRecommended,
        title: 'You May Also Like',
        onProductTap: (product) {
          if (widget.onNavigateToProductDetails != null) {
            widget.onNavigateToProductDetails!(product.id);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ProductDetailsScreen(productId: product.id),
              ),
            );
          }
        },
      ),
    );
  }
}

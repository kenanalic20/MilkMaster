import 'package:flutter/material.dart';
import 'package:milkmaster_mobile/main.dart';
import 'package:milkmaster_mobile/models/products_model.dart';
import 'package:milkmaster_mobile/utils/widget_helpers.dart';

/// A reusable horizontal product slider widget that displays a list of products
/// Can be used to show recommended products, products by category, or related products
class ProductSlider extends StatelessWidget {
  final List<Product> products;
  final bool isLoading;
  final String? title;
  final VoidCallback? onSeeAll;
  final Function(Product)? onProductTap;
  final Function(Product)? onAddToCart;
  final double height;
  final double cardWidth;

  const ProductSlider({
    super.key,
    required this.products,
    this.isLoading = false,
    this.title,
    this.onSeeAll,
    this.onProductTap,
    this.onAddToCart,
    this.height = 280,
    this.cardWidth = 175,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title!,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (onSeeAll != null)
                InkWell(
                  onTap: onSeeAll,
                  child: Text(
                    'See All',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                  ),
                ),
            ],
          ),
          SizedBox(height: Theme.of(context).extension<AppSpacing>()?.small),
        ],
        _buildProductList(context),
      ],
    );
  }

  Widget _buildProductList(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: height,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (products.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No products available',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final product = products[index];
          return _buildProductCard(context, product);
        },
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: products.length,
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return SizedBox(
      width: cardWidth,
      child: Card(
        elevation: 4,
        shadowColor: Colors.black.withOpacity(1),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: () {
            if (onProductTap != null) {
              onProductTap!(product);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(product.title)),
              );
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Image.network(
                fixLocalhostUrl(product.imageUrl),
                width: double.infinity,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 90,
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.image_not_supported,
                      size: 40,
                      color: Colors.grey[500],
                    ),
                  );
                },
              ),

              // Product Title
              Padding(
                padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
                child: Text(
                  product.title,
                  style: Theme.of(context).textTheme.headlineLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Product Description
              SizedBox(
                height: 40,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    product.description ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),

              // Categories Tags
              Container(
                height: 40,
                width: cardWidth,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: Wrap(
                      spacing: 2,
                      runSpacing: 2,
                      children: [
                        // Product Categories
                        ...(product.productCategories?.map((category) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.transparent,
                                  ),
                                ),
                                child: Text(
                                  category.name.toLowerCase(),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              );
                            }).toList() ??
                            []),
                        // Cattle Category
                        if (product.cattleCategory != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.transparent,
                              ),
                            ),
                            child: Text(
                              product.cattleCategory!.name.toLowerCase(),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // Price
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Text(
                  '${formatDouble(product.pricePerUnit)} BAM',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                ),
              ),

              SizedBox(
                height: Theme.of(context).extension<AppSpacing>()?.small,
              ),

              // Add to Cart Button
              Padding(
                padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: () {
                      if (onAddToCart != null) {
                        onAddToCart!(product);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Added "${product.title}" to cart',
                            ),
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                          ),
                        );
                      }
                    },
                    child: const Text('Add to cart'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:milkmaster_mobile/main.dart';
import 'package:milkmaster_mobile/models/products_model.dart';
import 'package:milkmaster_mobile/models/cattle_category_model.dart';
import 'package:milkmaster_mobile/models/product_category_model.dart';
import 'package:milkmaster_mobile/utils/widget_helpers.dart';
import 'package:milkmaster_mobile/widgets/product_slider.dart';
import 'package:milkmaster_mobile/widgets/product_slider_examples.dart';
import 'package:provider/provider.dart';
import 'package:milkmaster_mobile/providers/products_provider.dart';
import 'package:milkmaster_mobile/providers/cattle_category_provider.dart';
import 'package:milkmaster_mobile/providers/product_category_provider.dart';

class HomeScreen extends StatefulWidget {
  final void Function({int? productCategoryId, int? cattleCategoryId})? onNavigateToProducts;
  final void Function({int? cattleCategoryId})? onNavigateToCattle;
  
  const HomeScreen({super.key, this.onNavigateToProducts, this.onNavigateToCattle});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ProductProvider _productProvider;
  late CattleCategoryProvider _cattleCategoryProvider;
  late ProductCategoryProvider _productCategoryProvider;

  List<Product> _products = [];
  List<CattleCategory> _cattleCategories = [];
  List<ProductCategory> _productCategories = [];

  @override
  void initState() {
    super.initState();
    _productProvider = context.read<ProductProvider>();
    _cattleCategoryProvider = context.read<CattleCategoryProvider>();
    _productCategoryProvider = context.read<ProductCategoryProvider>();

    _fetchRecommendedProducts();
    _fetchCattleCategories();
    _fetchProductCategories();
  }

  Future<void> _fetchCattleCategories() async {
    try {
      final items = await _cattleCategoryProvider.fetchAll();
      if (mounted) {
        setState(() {
          _cattleCategories = items.items;
        });
      }
    } catch (e) {
      debugPrint('Error fetching cattle categories: $e');
    }
  }

  Future<void> _fetchProductCategories() async {
    try {
      var items = await _productCategoryProvider.fetchAll();
      if (mounted) {
        setState(() {
          _productCategories = items.items;
        });
      }
    } catch (e) {
      print("Error fetching product categories: $e");
    }
  }

  Future<void> _fetchRecommendedProducts() async {
    try {
      final items = await _productProvider.getRecommendedProducts();
      if (mounted) {
        setState(() {
          _products = items;
        });
      }
    } catch (e) {
      debugPrint('Error fetching recommended products: $e');
    }
  }

  Widget ColumnWidget(category) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        category.title,
        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
          color: Color.fromRGBO(245, 127, 23, 1),
        ),
      ),
      Text(category.description, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
  Widget _buildCattleCategories() {
    if (_cattleCategoryProvider.isLoading) {
      return SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_cattleCategories.isEmpty) {
      return SizedBox(child: NoDataWidget());
    }

    return Column(
      children:
          _cattleCategories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;

            final rowChildren =
                index % 2 == 0
                    ? [
                      InkWell(
                        onTap: () async {
                          widget.onNavigateToCattle?.call(cattleCategoryId: category.id);
                        },
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(
                                  10,
                                  15,
                                  10,
                                  40,
                                ),
                                child: ColumnWidget(category),
                              ),
                            ),
                            Image.network(
                              fixLocalhostUrl(category.imageUrl),
                              width: 90,
                              height: 90,
                            ),
                          ],
                        ),
                      ),
                    ]
                    : [
                      InkWell(
                        onTap: () async {
                          widget.onNavigateToCattle?.call(cattleCategoryId: category.id);
                        },
                        child: Row(
                          children: [
                            Image.network(
                              fixLocalhostUrl(category.imageUrl),
                              width: 90,
                              height: 90,
                            ),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(
                                  10,
                                  15,
                                  10,
                                  40,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: ColumnWidget(category),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ];

            return Container(
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 4),
                  ),
                ],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Wrap(
                    children: [
                      ...rowChildren
                          .map(
                            (child) => Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: child,
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: Theme.of(context).extension<AppSpacing>()?.small,
              ),
              Text('Home', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(
                height: Theme.of(context).extension<AppSpacing>()?.small,
              ),
              Container(
                width: double.infinity,
                height: 180,
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
                  child: Stack(
                    children: [
                      Transform.rotate(
                        angle: 3.14159, // 180 degrees in radians
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/banner.jpg'),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.4),
                                BlendMode.darken,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fresh Dairy Products',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 220,
                              child: Text(
                                'Discover our premium selection of dairy products',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.copyWith(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: Theme.of(context).extension<AppSpacing>()?.medium,
              ),
              ProductSlider(
                products: _products,
                isLoading: _productProvider.isLoading,
                title: 'Recommended Products',
                onSeeAll: () {
                  debugPrint('See all tapped');
                  widget.onNavigateToProducts?.call();
                },
                onProductTap: (product) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(product.title)),
                  );
                },
                onAddToCart: (product) {
                  // TODO: wire to cart provider
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added "${product.title}" to cart'),
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                  );
                },
              ),

              SizedBox(
                height: Theme.of(context).extension<AppSpacing>()?.small,
              ),
              Text('Our Cattle', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(
                height: Theme.of(context).extension<AppSpacing>()?.small,
              ),
              _buildCattleCategories(),
              Text('Our Categories', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(
                height: Theme.of(context).extension<AppSpacing>()?.small,
              ),
              _buildProductCategories(),
              SizedBox(
                height: Theme.of(context).extension<AppSpacing>()?.small,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCategories() {
    if (_productCategoryProvider.isLoading) {
      return SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_productCategories.isEmpty) {
      return NoDataWidget();
    }
    
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 45) / 2;
    return Center(
      child: Wrap(
      spacing: 15,
      runSpacing: 15,
      children: _productCategories.map((category) {
        return Container(
          width: cardWidth,
          height: cardWidth,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            onTap: () {
              widget.onNavigateToProducts?.call(productCategoryId: category.id);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  fixLocalhostUrl(category.imageUrl),
                  width: 70,
                  height: 70,
                ),
                const SizedBox(height: 8),
                Text(
                  category.name.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
        ),
    );
  }
}

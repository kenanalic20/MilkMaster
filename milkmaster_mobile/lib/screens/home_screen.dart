import 'package:flutter/material.dart';
import 'package:milkmaster_mobile/main.dart';
import 'package:milkmaster_mobile/models/products_model.dart';
import 'package:milkmaster_mobile/models/cattle_category_model.dart';
import 'package:milkmaster_mobile/utils/widget_helpers.dart';
import 'package:provider/provider.dart';
import 'package:milkmaster_mobile/providers/products_provider.dart';
import 'package:milkmaster_mobile/providers/cattle_category_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ProductProvider _productProvider;
  late CattleCategoryProvider _cattleCategoryProvider;
  List<Product> _products = [];
  List<CattleCategory> _cattleCategories = [];

  @override
  void initState() {
    super.initState();
    _productProvider = context.read<ProductProvider>();
    _cattleCategoryProvider = context.read<CattleCategoryProvider>();
    _fetchRecommendedProducts();
    _fetchCattleCategories();
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
        style: TextStyle(
          fontSize: Theme.of(context).textTheme.headlineMedium?.fontSize,
          color: Color.fromRGBO(245, 127, 23, 1),
          fontWeight: Theme.of(context).textTheme.headlineMedium?.fontWeight,
        ),
      ),
      Text(category.description),
    ],
  );
  Widget _buildCattleCategories() {
    if (_cattleCategoryProvider.isLoading) {
      return Center(child: CircularProgressIndicator());
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
                      Container(
                        padding: const EdgeInsets.fromLTRB(10, 15, 10, 40),
                        child: ColumnWidget(category),
                      ),

                      Image.network(
                        fixLocalhostUrl(category.imageUrl),
                        width: 50,
                        height: 50,
                      ),
                    ]
                    : [
                      Image.network(
                        fixLocalhostUrl(category.imageUrl),
                        width: 50,
                        height: 50,
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(10, 15, 10, 40),
                        child: Container(
                          padding: const EdgeInsets.only(left: 60),
                          child: ColumnWidget(category),
                        ),
                      ),
                    ];

            return Container(
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
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
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
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  image: DecorationImage(
                    image: AssetImage('assets/images/banner.jpg'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.4),
                      BlendMode.darken,
                    ),
                  ),
                ),
                child: Padding(
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
              ),
              SizedBox(
                height: Theme.of(context).extension<AppSpacing>()?.medium,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recommended Products',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  InkWell(
                    onTap: () {
                      // TODO: Navigate to all products
                      debugPrint('See all tapped');
                    },
                    child: Text(
                      'See All',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                ],
              ),

              buildRecommendedList(),
              SizedBox(
                height: Theme.of(context).extension<AppSpacing>()?.small,
              ),
              Text('Our Cattle', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(
                height: Theme.of(context).extension<AppSpacing>()?.small,
              ),
              _buildCattleCategories(),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRecommendedList() {
    if (_productProvider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (_products.isEmpty) {
      return NoDataWidget();
    }

    return SizedBox(
      height: 280,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final product = _products[index];
          return SizedBox(
            width: 175,
            child: Card(
              elevation: 4,
              shadowColor: Colors.black.withOpacity(1),
              clipBehavior: Clip.hardEdge,
              child: InkWell(
                onTap: () async {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(product.title)));
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(
                      fixLocalhostUrl(product.imageUrl),
                      width: double.infinity,
                      height: 90,
                      fit: BoxFit.cover,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
                      child: Text(
                        product.title,
                        style: Theme.of(context).textTheme.headlineLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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
                    Container(
                      height: 40,
                      width: 180,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5, right: 5),
                          child: Wrap(
                            spacing: 2,
                            runSpacing: 2,
                            children: [
                              ...(product.productCategories?.map((category) {
                                    return Container(
                                      padding: EdgeInsets.only(
                                        left: 10,
                                        right: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.transparent,
                                        ),
                                      ),
                                      child: Text(
                                        category.name.toLowerCase(),
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                      ),
                                    );
                                  }).toList() ??
                                  []),
                              if (product.cattleCategory != null)
                                Container(
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.transparent,
                                    ),
                                  ),
                                  child: Text(
                                    product.cattleCategory!.name.toLowerCase(),
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
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
                        formatDouble(product.pricePerUnit) + ' BAM',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: Theme.of(context).extension<AppSpacing>()?.small,
                    ),
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
                            // TODO: wire to cart provider
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Added "${product.title}" to cart',
                                ),
                                backgroundColor:
                                    Theme.of(context).colorScheme.secondary,
                              ),
                            );
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
        },
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: _products.length,
      ),
    );
  }
}

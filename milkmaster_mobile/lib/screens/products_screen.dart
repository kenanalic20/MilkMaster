import 'dart:math';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:milkmaster_mobile/main.dart';
import 'package:milkmaster_mobile/models/cattle_category_model.dart';
import 'package:milkmaster_mobile/models/product_category_model.dart';
import 'package:milkmaster_mobile/models/products_model.dart';
import 'package:milkmaster_mobile/providers/cattle_category_provider.dart';
import 'package:milkmaster_mobile/providers/product_category_provider.dart';
import 'package:milkmaster_mobile/providers/products_provider.dart';
import 'package:milkmaster_mobile/providers/cart_provider.dart';
import 'package:milkmaster_mobile/screens/product_details_screen.dart';
import 'package:milkmaster_mobile/utils/widget_helpers.dart';
import 'package:provider/provider.dart';

class ProductsScreen extends StatefulWidget {
  final int? selectedProductCategory;
  final int? selectedCattleCategory;
  final void Function(int productId)? onNavigateToProductDetails;
  
  const ProductsScreen({
    Key? key,
    this.selectedProductCategory,
    this.selectedCattleCategory,
    this.onNavigateToProductDetails,
  }) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late ProductProvider _productProvider;
  late CattleCategoryProvider _cattleCategoryProvider;
  late ProductCategoryProvider _productCategoryProvider;
  final TextEditingController _searchController = TextEditingController();
  int _pageSize = 8;
  int _totalCount = 0;
  int _currentPage = 1;
  int? _selectedProductCategory;
  int? _selectedCattleCategory;
  bool _sortDescending = true; 
  List<Product> _products = [];
  List<CattleCategory> _cattleCategories = [];
  List<ProductCategory> _productCategories = [];

  @override
  void initState() {
    super.initState();
    _productProvider = context.read<ProductProvider>();
    _cattleCategoryProvider = context.read<CattleCategoryProvider>();
    _productCategoryProvider = context.read<ProductCategoryProvider>();
    _selectedProductCategory = widget.selectedProductCategory;
    _selectedCattleCategory = widget.selectedCattleCategory;
    _fetchProduct(extraQuery: {
      "pageSize": _pageSize,
      'productCategoryId': _selectedProductCategory ?? '',
      'cattleCategoryId': _selectedCattleCategory ?? '',
      'sortDescending': _sortDescending,
    });
    _fetchCattleCategories();
    _fetchProductCategories();
  }

  @override
  void didUpdateWidget(ProductsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedProductCategory != oldWidget.selectedProductCategory ||
        widget.selectedCattleCategory != oldWidget.selectedCattleCategory) {
      setState(() {
        _selectedProductCategory = widget.selectedProductCategory;
        _selectedCattleCategory = widget.selectedCattleCategory;
        _currentPage = 1;
      });
      _fetchProduct(extraQuery: {
        "pageSize": _pageSize,
        'productCategoryId': _selectedProductCategory ?? '',
        'cattleCategoryId': _selectedCattleCategory ?? '',
        'sortDescending': _sortDescending,
      });
    }
  }

  Future<void> _fetchCattleCategories() async {
    final result = await _cattleCategoryProvider.fetchAll();
    if (mounted) {
      setState(() {
        _cattleCategories = result.items;
      });
    }
  }

  Future<void> _fetchProductCategories() async {
    try {
      var fetchedItems = await _productCategoryProvider.fetchAll();
      if (mounted) {
        setState(() {
          _productCategories = fetchedItems.items;
        });
      }
    } catch (e) {
      print("Error fetching product categories: $e");
    }
  }

  Future<void> _fetchProduct({
    int? page,
    Map<String, dynamic>? extraQuery,
  }) async {
    try {
      final queryParams = {
        "pageSize": _pageSize,
        "pageNumber": page ?? _currentPage,
        if (extraQuery != null) ...extraQuery,
      };

      final result = await _productProvider.fetchAll(queryParams: queryParams);

      if (mounted) {
        setState(() {
          _products = result.items;
          _totalCount = result.totalCount;
        });
      }
    } catch (e) {
      print("Error fetching cattle: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: Theme.of(context).extension<AppSpacing>()?.medium),
          _buildSearch(),
          Expanded(child: _buildProductGrid()),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 35,
            child: TextField(
              style: Theme.of(context).textTheme.bodyMedium,
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search orders...",
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.tertiary,
                  size: 20,
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: const Color.fromRGBO(229, 229, 229, 1),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              ),
              onChanged: (value) async {
                setState(() {
                  _currentPage = 1;
                });
                await _fetchProduct(
                  extraQuery: {
                    'title': value,
                    'cattleCategoryId': _selectedCattleCategory ?? '',
                    'productCategoryId': _selectedProductCategory ?? '',
                    'pageSize': _pageSize,
                    'pageNumber': _currentPage,
                    'sortDescending': _sortDescending,
                  },
                );
              },
            ),
          ),
          SizedBox(height: Theme.of(context).extension<AppSpacing>()?.medium),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<int>(
                    value: _selectedProductCategory,
                    items:
                        _productCategories.map((category) {
                          return DropdownMenuItem<int>(
                            value: category.id,
                            child: Text(category.name),
                          );
                        }).toList(),
                    onChanged: (value) async {
                      setState(() {
                        _selectedProductCategory = value;
                        _currentPage = 1;
                      });
                      await _fetchProduct(
                        extraQuery: {
                          'title': _searchController.text,
                          'cattleCategoryId': _selectedCattleCategory ?? '',
                          'productCategoryId': _selectedProductCategory ?? '',
                          'pageSize': _pageSize,
                          'pageNumber': _currentPage,
                          'sortDescending': _sortDescending,
                        },
                      );
                    },
                    hint: Text(
                      'Product Type',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                    buttonStyleData: ButtonStyleData(
                      height: 45,
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.black26, width: 0.5),
                        color: Colors.white,
                        boxShadow: List.empty(),
                      ),
                      elevation: 2,
                    ),
                    iconStyleData: IconStyleData(
                      icon: Transform.rotate(
                        angle: pi / 2,
                        child: Icon(Icons.chevron_right),
                      ),
                      iconSize: 16,
                      iconEnabledColor: Colors.grey,
                      iconDisabledColor: Colors.grey,
                    ),
                  ),
                ),
              ),
              
              SizedBox(width: Theme.of(context).extension<AppSpacing>()!.medium),
              
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<int>(
                    value: _selectedCattleCategory,
                    items:
                        _cattleCategories.map((category) {
                          return DropdownMenuItem<int>(
                            value: category.id,
                            child: Text(category.name),
                          );
                        }).toList(),
                    onChanged: (value) async {
                      setState(() {
                        _selectedCattleCategory = value;
                        _currentPage = 1;
                      });
              
                      await _fetchProduct(
                        extraQuery: {
                          'title': _searchController.text,
                          'cattleCategoryId': _selectedCattleCategory ?? '',
                          'productCategoryId': _selectedProductCategory ?? '',
                          'pageSize': _pageSize,
                          'pageNumber': _currentPage,
                          'sortDescending': _sortDescending,
                        },
                      );
                    },
                    hint: Text(
                      'Animal Type',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                    buttonStyleData: ButtonStyleData(
                      height: 45,
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.black26, width: 0.5),
                        color: Colors.white,
                        boxShadow: List.empty(),
                      ),
                      elevation: 2,
                    ),
                    iconStyleData: IconStyleData(
                      icon: Transform.rotate(
                        angle: pi / 2,
                        child: Icon(Icons.chevron_right),
                      ),
                      iconSize: 16,
                      iconEnabledColor: Colors.grey,
                      iconDisabledColor: Colors.grey,
                    ),
                    dropdownStyleData: DropdownStyleData(
                      scrollbarTheme: ScrollbarThemeData(
                        radius: const Radius.circular(40),
                        thickness: MaterialStateProperty.all(6),
                        thumbVisibility: MaterialStateProperty.all(true),
                      ),
                    ),
                    menuItemStyleData: const MenuItemStyleData(height: 40),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Theme.of(context).extension<AppSpacing>()?.medium),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    if (_productProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_products.isEmpty) {
      return const NoDataWidget();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$_totalCount ${_totalCount == 1 ? 'product found' : 'products found'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Sort:',
                      ),
                      DropdownButtonHideUnderline(
                        child: DropdownButton2<bool>(
                          value: _sortDescending,
                          items: const [
                            DropdownMenuItem<bool>(
                              value: true,
                              child: Text('Fresh'),
                            ),
                            DropdownMenuItem<bool>(
                              value: false,
                              child: Text('Oldest'),
                            ),
                          ],
                          onChanged: (value) async {
                            if (value != null) {
                              setState(() {
                                _sortDescending = value;
                                _currentPage = 1;
                              });
                              await _fetchProduct(
                                extraQuery: {
                                  'title': _searchController.text,
                                  'cattleCategoryId': _selectedCattleCategory ?? '',
                                  'productCategoryId': _selectedProductCategory ?? '',
                                  'pageSize': _pageSize,
                                  'pageNumber': _currentPage,
                                  'sortDescending': _sortDescending,
                                },
                              );
                            }
                          },
                          buttonStyleData: ButtonStyleData(
                            height: 30,
                            padding: const EdgeInsets.only(left: 0, right: 5),
                            decoration: const BoxDecoration(
                              color: Colors.transparent,
                            ),
                          ),
                          iconStyleData: const IconStyleData(
                            icon: Icon(Icons.keyboard_arrow_down),
                            iconSize: 18,
                            iconEnabledColor: Colors.black,
                          ),
                          dropdownStyleData: const DropdownStyleData(
                            maxHeight: 200,
                            offset: Offset(0, -5),
                          ),
                          menuItemStyleData: const MenuItemStyleData(height: 35),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 7,
                mainAxisSpacing: 7,
                childAspectRatio: 0.5,
              ),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return _buildProductCard(product);
              },
            ),
          ),
          PaginationWidget(
            currentPage: _currentPage,
            totalItems: _totalCount,
            pageSize: _pageSize,
            onPageChanged: (page) {
              setState(() {
                _currentPage = page;
              });
              _fetchProduct(
                page: page,
                extraQuery: {
                  'title': _searchController.text,
                  'cattleCategoryId': _selectedCattleCategory ?? '',
                  'productCategoryId': _selectedProductCategory ?? '',
                  'pageSize': _pageSize,
                  'sortDescending': _sortDescending,
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(1),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {
          if (widget.onNavigateToProductDetails != null) {
            widget.onNavigateToProductDetails!(product.id);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailsScreen(productId: product.id),
              ),
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              fixLocalhostUrl(product.imageUrl),
              width: double.infinity,
              height: 110,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(
                    height: 110,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 50),
                  ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
              child: Text(
                product.title,
                style: Theme.of(context).textTheme.headlineLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              height: 45,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  product.description ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
            Container(
              height: 50,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    ...(product.productCategories?.map((category) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              category.name.toLowerCase(),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          );
                        }).toList() ??
                        []),
                    if (product.cattleCategory != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
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
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 5,bottom: 5),
              child: Text(
                '${formatDouble(product.pricePerUnit)} BAM',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 5),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onPressed: () async {
                    final cartProvider = Provider.of<CartProvider>(context, listen: false);
                    final success = await cartProvider.addToCart(
                      product,
                      quantity: 1,
                      size: 1.0,
                    );
                    
                    if (context.mounted) {
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Added "${product.title}" to cart',
                              style: const TextStyle(color: Colors.black),
                            ),
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      } else {
                        showCustomDialog(
                          context: context,
                          title: 'Cannot Add to Cart',
                          message: 'Not enough stock available or product is out of stock.',
                          onConfirm: () {},
                          showCancel: false,
                        );
                      }
                    }
                  },
                  child: const Text('Add to cart'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


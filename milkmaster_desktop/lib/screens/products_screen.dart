import 'dart:io';
import 'dart:math';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:milkmaster_desktop/main.dart';
import 'package:milkmaster_desktop/models/products_model.dart';
import 'package:milkmaster_desktop/providers/file_provider.dart';
import 'package:milkmaster_desktop/providers/products_provider.dart';
import 'package:milkmaster_desktop/utils/widget_helpers.dart';
import 'package:milkmaster_desktop/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class ProductScreen extends StatefulWidget {
  final void Function(Widget form) openForm;
  final void Function() closeForm;

  const ProductScreen({
    super.key,
    required this.openForm,
    required this.closeForm,
  });

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late ProductProvider _productProvider;
  late FileProvider _fileProvider;
  List<Product> _products = [];
  File? _uploadedImageFile;
  int _pageSize = 8;
  int _totalCount = 0;
  int _currentPage = 1;
  int? _selectedCategory;
  String? _selectedSort;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _productProvider = context.read<ProductProvider>();
    _fileProvider = context.read<FileProvider>();
    _fetchProduct(extraQuery: {"pageSize": _pageSize});
  }

  void openForm() {
    _uploadedImageFile = null;
    _fileProvider = context.read<FileProvider>();
    widget.openForm(
      SingleChildScrollView(
        child: MasterWidget(
          title: 'Add Cattle',
          body: Center(child: Text('Form opened')),
        ),
      ),
    );
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

  Future<void> _deleteProducts(product) async {
    await _productProvider.delete(product.id);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // _buildSearch(),
        // _buildCattleStats(),
        _productProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildProducts(),
        _buildPagination(),
      ],
    );
  }

  Widget _buildProducts() {
    return Wrap(
      spacing: 30,
      runSpacing: 30,
      children:
          _products.map((product) {
            return SizedBox(
              width: MediaQuery.of(context).size.width * 0.172,
              child: Card(
                clipBehavior: Clip.hardEdge,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      print("Card tapped for ${product.title}");
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Image
                        Image.network(
                          product.imageUrl,
                          width: double.infinity,
                          height: 142,
                          fit: BoxFit.cover,
                        ),
                        // Title & Price
                        Padding(
                          padding: const EdgeInsets.only(top:10,left: 10,right: 10),
                          child: Text(
                            product.title,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                        
                        
                       
                        // Description
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            product.description ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          child: Wrap(
                            spacing: 5,
                            runSpacing: 5,
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
                                      child: Text(category.name.toLowerCase()),
                                    );
                                  }).toList() ??
                                  []),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 11),
                          child: Text(
                            "${formatDouble(product.pricePerUnit)} BAM",
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Theme.of(context).colorScheme.secondary
                            )
                          ),
                        ),

                        // Cattle Category Section
                        // Row(
                        //   children: [
                        //     CircleAvatar(
                        //       backgroundImage: NetworkImage(
                        //         // product.cattleCategory.imageUrl,
                        //       ),
                        //       radius: 20,
                        //     ),
                        //     const SizedBox(width: 10),
                        //     Expanded(
                        //       child: Column(
                        //         crossAxisAlignment: CrossAxisAlignment.start,
                        //         children: [
                        //           Text(
                        //             product.cattleCategory.title,
                        //             style: const TextStyle(
                        //               fontWeight: FontWeight.bold,
                        //             ),
                        //           ),
                        //           Text(
                        //             product.cattleCategory.description,
                        //             maxLines: 1,
                        //             overflow: TextOverflow.ellipsis,
                        //             style: const TextStyle(color: Colors.grey),
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // const SizedBox(height: 16),

                        // Action Buttons
                        Padding(
                          padding: const EdgeInsets.only(bottom:10,left: 10,right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            spacing: 10,
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: AppButtonStyles.danger,
                                  onPressed: () {
                                    print("Delete for ${product.title}");
                                  },
                                  child: const Text("Delete"),
                                ),
                              ),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    print("Edit ${product.title}");
                                  },
                                  style: AppButtonStyles.secondary,
                                  child: const Text("Edit"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildPagination() {
    return PaginationWidget(
      currentPage: _currentPage,
      totalItems: _totalCount,
      pageSize: _pageSize,
      onPageChanged: (page) async {
        setState(() {
          _currentPage = page;
        });
        await _fetchProduct(extraQuery: {"page": page, "pageSize": _pageSize});
      },
    );
  }
}

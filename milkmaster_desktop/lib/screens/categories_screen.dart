import 'package:flutter/material.dart';
import 'package:milkmaster_desktop/models/cattle_category_model.dart';
import 'package:milkmaster_desktop/models/product_category_model.dart';
import 'package:milkmaster_desktop/providers/cattle_category_provider.dart';
import 'package:milkmaster_desktop/providers/product_category_provider.dart';
import 'package:milkmaster_desktop/utils/widget_helpers.dart';
import 'package:milkmaster_desktop/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late ProductCategoryProvider _productCategoryProvider;
  List<ProductCategoryAdmin> _productCategories = [];
  int? _hoveredCategoryId;

  @override
  void initState() {
    super.initState();
    _productCategoryProvider = context.read<ProductCategoryProvider>();
    _fetchProductCategories();
  }

  Future<void> _fetchProductCategories() async {
    try {
      var fetchedItems = await _productCategoryProvider.fetchAll();
      if (mounted) {
        setState(() {
          _productCategories = fetchedItems;
        });
      }
    } catch (e) {
      print("Error fetching product categories: $e");
    }
  }

  Widget _buildProductCategories() {
    return Wrap(
      spacing: 34,
      runSpacing: 28,
      children:
          _productCategories.map((category) {
            final isHovered = _hoveredCategoryId == category.id;

            return MouseRegion(
              onEnter: (_) {
                setState(() => _hoveredCategoryId = category.id);
              },
              onExit: (_) {
                setState(() => _hoveredCategoryId = null);
              },

              child: Container(
                width: MediaQuery.of(context).size.width * 0.237,
                height: 161,
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
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Image.network(
                            category.imageUrl,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Text(
                          category.name.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize:
                                Theme.of(
                                  context,
                                ).textTheme.headlineMedium?.fontSize,
                            height: 1,
                          ),
                        ),
                        Text(
                          '${category.count} products',
                          style: TextStyle(
                            color: const Color.fromRGBO(133, 77, 14, 1),
                            fontSize:
                                Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.fontSize,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                    if (isHovered)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                child: leadingIcon(
                                  'assets/icons/pentool_icon.png',
                                ),
                                onTap:
                                    () => print(
                                      'Edit category: ${category.name}',
                                    ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                child: leadingIcon(
                                  'assets/icons/trash_icon.png',
                                ),
                                onTap: () async {
                                  print('Delete category: ${category.name}');
                                  await showCustomDialog(
                                    context: context,
                                    title: "Delete Category",
                                    message:
                                        "Are you sure you want to delete '${category.name}'?",
                                    onConfirm: () async {
                                      await _productCategoryProvider.delete(
                                        category.id,
                                      );
                                      await _fetchProductCategories();
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }



  @override
  Widget build(BuildContext context) {
    if (_productCategoryProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_productCategories.isEmpty) {
      return const Center(child: Text('No categories found'));
    }
    return _buildProductCategories();
    
  }
}

import 'package:flutter/material.dart';
import 'package:milkmaster_desktop/models/product_category_model.dart';
import 'package:milkmaster_desktop/providers/product_category_provider.dart';
import 'package:provider/provider.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late ProductCategoryProvider _productCategoryProvider;

  @override
  void initState() {
    super.initState();
    _productCategoryProvider = Provider.of<ProductCategoryProvider>(context, listen: false);
    loadData();
  }

  Future<void> loadData() async {
    try {
      await _productCategoryProvider.fetchAll();
    } catch (e) {
      print("Error loading categories: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductCategoryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.items.isEmpty) {
          return const Center(child: Text('No product categories available.'));
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
          child: SizedBox(
            height: 140, // Set fixed height for horizontal scroll
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: provider.items.length,
              itemBuilder: (context, index) {
                final category = provider.items[index];
                return GestureDetector(
                  onTap: () {
                    print('Selected category: ${category.name}');
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: const Color(0xFFFAFAFA),
                          backgroundImage: NetworkImage(category.imageUrl),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          category.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${category.count} items',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

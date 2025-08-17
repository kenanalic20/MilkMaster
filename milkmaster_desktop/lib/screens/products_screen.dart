import 'package:flutter/material.dart';
import 'package:milkmaster_desktop/providers/products_provider.dart';
import 'package:provider/provider.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late ProductProvider _productProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // loadData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _productProvider = Provider.of<ProductProvider>(context);
  }

  Future<void> loadData() async {
    try {
      await _productProvider.fetchAll();
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.items.isEmpty) {
            return const Center(child: Text('No products available.'));
          }
          return ListView.builder(
            itemCount: provider.items.length,
            itemBuilder: (context, index) {
              final product = provider.items[index];
              return ListTile(
                title: Text(product.title),
                subtitle: Text('${product.pricePerUnit} BAM'),
              );
            },
          );
        },
      );
  }
}


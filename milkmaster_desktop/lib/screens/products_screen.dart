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
    _productProvider = Provider.of<ProductProvider>(context, listen: false);
    loadData();
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
        return Scaffold(
          appBar: AppBar(title: const Text('Products')),
          body: ListView.builder(
            itemCount: provider.items.length,
            itemBuilder: (context, index) {
              final product = provider.items[index];
              return ListTile(
                title: Text(product.title),
                subtitle: Text('${product.pricePerUnit} BAM'),
              );
            },
          ),
        );
      },
    );
  }
}

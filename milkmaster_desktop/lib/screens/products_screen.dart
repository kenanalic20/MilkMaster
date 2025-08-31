import 'dart:io';
import 'dart:math';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:milkmaster_desktop/main.dart';
import 'package:milkmaster_desktop/models/products_model.dart';
import 'package:milkmaster_desktop/providers/file_provider.dart';
import 'package:milkmaster_desktop/providers/products_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // _buildSearch(),
        // _buildCattleStats(),
        _productProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildProducts(context),
        // _buildPagination(),
      ],
    );
  }

  Widget _buildProducts(BuildContext context) {
    return Container(child:Text("Test"));
  }
}

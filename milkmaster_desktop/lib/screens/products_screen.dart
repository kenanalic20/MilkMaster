import 'dart:io';
import 'dart:math';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:milkmaster_desktop/main.dart';
import 'package:milkmaster_desktop/models/cattle_category_model.dart';
import 'package:milkmaster_desktop/models/file_model.dart';
import 'package:milkmaster_desktop/models/product_category_model.dart';
import 'package:milkmaster_desktop/models/products_model.dart';
import 'package:milkmaster_desktop/providers/cattle_category_provider.dart';
import 'package:milkmaster_desktop/providers/file_provider.dart';
import 'package:milkmaster_desktop/providers/product_category_provider.dart';
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
  late CattleCategoryProvider _cattleCategoryProvider;
  late ProductCategoryProvider _productCategoryProvider;
  List<Product> _products = [];
  List<CattleCategory> _cattleCategories = [];
  List<ProductCategory> _productCategories = [];
  File? _uploadedImageFile;
  int _pageSize = 8;
  int _totalCount = 0;
  int _currentPage = 1;
  int? _selectedProductCategory;
  int? _selectedCattleCategory;
  final TextEditingController _searchController = TextEditingController();
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
    _productProvider = context.read<ProductProvider>();
    _fileProvider = context.read<FileProvider>();
    _cattleCategoryProvider = context.read<CattleCategoryProvider>();
    _productCategoryProvider = context.read<ProductCategoryProvider>();
    _fetchProduct(extraQuery: {"pageSize": _pageSize});
    _fetchCattleCategories();
    _fetchProductCategories();
  }

  void openForm() {
    _uploadedImageFile = null;
    _fileProvider = context.read<FileProvider>();
    widget.openForm(
      SingleChildScrollView(
        child: MasterWidget(title: 'Add Cattle', body: _buildProductForm()),
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
    await _fileProvider.deleteFile(
      FileDeleteModel(fileUrl: product.imageUrl, subfolder: 'Images/Products'),
    );
    await _fetchProduct();
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearch(),
        _productProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : _products.isEmpty
            ? NoDataWidget()
            : _buildProducts(),
        _buildPagination(),
      ],
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: Theme.of(context).extension<AppSpacing>()!.large,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 400,
            height: 45,
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
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Color.fromRGBO(229, 229, 229, 1),
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
                  },
                );
              },
            ),
          ),

          SizedBox(width: Theme.of(context).extension<AppSpacing>()!.medium),

          SizedBox(
            width: 180,
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
                  width: 120,
                  padding: const EdgeInsets.only(left: 15, right: 14),
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

          SizedBox(
            width: 180,

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
                  width: 200,
                  padding: const EdgeInsets.only(left: 14, right: 14),
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
          SizedBox(width: Theme.of(context).extension<AppSpacing>()!.medium),

          SizedBox(
            height: 45,
            width: 180,
            child: ElevatedButton(
              onPressed: () async => {openForm()},
              child: Text('Add Product'),
            ),
          ),
        ],
      ),
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
                          padding: const EdgeInsets.only(
                            top: 10,
                            left: 10,
                            right: 10,
                          ),
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

                        Container(
                          height: 60,
                          padding: const EdgeInsets.only(
                            left: 10,
                            right: 10,
                            top: 10,
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
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
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.transparent,
                                          ),
                                        ),
                                        child: Text(
                                          category.name.toLowerCase(),
                                        ),
                                      );
                                    }).toList() ??
                                    []),
                                if (product.cattleCategory != null)
                                  Container(
                                    padding: EdgeInsets.only(
                                      left: 10,
                                      right: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.transparent,
                                      ),
                                    ),
                                    child: Text(
                                      product.cattleCategory!.name
                                          .toLowerCase(),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 11),
                          child: Text(
                            "${formatDouble(product.pricePerUnit)} BAM",
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),

                        Builder(
                          builder: (context) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: 10,
                                left: 10,
                                right: 10,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                spacing: 10,
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      style: AppButtonStyles.danger,
                                      onPressed: () async {
                                        await showCustomDialog(
                                          context: context,
                                          title: "Delete Product",
                                          message:
                                              "Are you sure you want to delete '${product.title}'?",
                                          onConfirm: () async {
                                            await _deleteProducts(product);
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "Product Deleted successfully",
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                backgroundColor:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.secondary,
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: const Text("Delete"),
                                    ),
                                  ),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        widget.openForm(
                                          SingleChildScrollView(
                                            child: MasterWidget(
                                              title: 'Edit Product',
                                              subtitle: product.title,
                                              body: _buildProductForm(
                                                product: product,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      style: AppButtonStyles.secondary,
                                      child: const Text("Edit"),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
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

  FormBuilder _buildProductForm({product}) {
    final isEdit = product != null;

    return FormBuilder(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE UPLOAD
            FormBuilderField<File?>(
              name: 'image',
              initialValue: null,
              validator: (val) {
                if (!isEdit &&
                    val == null &&
                    (product?.imageUrl?.isEmpty ?? true)) {
                  return 'Image is required';
                }
                return null;
              },
              builder: (field) {
                return Column(
                  children: [
                    FilePickerWithPreview(
                      imageUrl: product?.imageUrl,
                      onFileSelected: (file) {
                        _uploadedImageFile = file;
                        field.didChange(file);
                        field.validate();
                      },
                    ),
                    if (field.errorText != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          field.errorText!,
                          style: TextStyle(
                            color: Theme.of(field.context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // TITLE
            FormBuilderTextField(
              name: 'title',
              initialValue: product?.title ?? '',
              decoration: const InputDecoration(labelText: 'Product Title'),
              validator: FormBuilderValidators.required(),
            ),
            const SizedBox(height: 16),

            // PRICE PER UNIT
            FormBuilderTextField(
              name: 'pricePerUnit',
              initialValue: product?.pricePerUnit?.toString() ?? '',
              decoration: const InputDecoration(labelText: 'Price per Unit'),
              keyboardType: TextInputType.number,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.numeric(),
              ]),
            ),
            const SizedBox(height: 16),

            // UNIT (Dropdown)
            // FormBuilderDropdown<int>(
            //   name: 'unitId',
            //   initialValue: product?.unit?.id,
            //   decoration: const InputDecoration(labelText: 'Unit'),
            //   validator: FormBuilderValidators.required(),
            //   items: _units
            //       .map((u) => DropdownMenuItem(
            //             value: u.id,
            //             child: Text(u.name),
            //           ))
            //       .toList(),
            // ),
            // const SizedBox(height: 16),

            // QUANTITY
            FormBuilderTextField(
              name: 'quantity',
              initialValue: product?.quantity?.toString() ?? '',
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.integer(),
              ]),
            ),
            const SizedBox(height: 16),

            // DESCRIPTION
            FormBuilderTextField(
              name: 'description',
              initialValue: product?.description ?? '',
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // // PRODUCT CATEGORIES (Multiselect)
            // FormBuilderFilterChip<int>(
            //   name: 'productCategories',
            //   initialValue: product?.productCategories?.map((c) => c.id).toList() ?? [],
            //   decoration: const InputDecoration(labelText: 'Categories'),
            //   options: _categories
            //       .map((c) => FormBuilderChipOption(
            //             value: c.id,
            //             child: Text(c.name),
            //           ))
            //       .toList(),
            // ),
            const SizedBox(height: 16),

            // CATTLE CATEGORY (Dropdown)
            FormBuilderDropdown<int>(
              name: 'cattleCategoryId',
              initialValue: product?.cattleCategory?.id,
              decoration: const InputDecoration(labelText: 'Cattle Category'),
              items:
                  _cattleCategories
                      .map(
                        (c) =>
                            DropdownMenuItem(value: c.id, child: Text(c.name)),
                      )
                      .toList(),
            ),
            const SizedBox(height: 16),

            // NUTRITION (za sad samo dummy text field – možeš kasnije napraviti detaljnije)
            FormBuilderTextField(
              name: 'nutrition',
              initialValue: product?.nutrition?.toString() ?? '',
              decoration: const InputDecoration(labelText: 'Nutrition'),
            ),

            const SizedBox(height: 24),

            // BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => widget.closeForm(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.saveAndValidate() ?? false) {
                      final values = Map<String, dynamic>.from(
                        _formKey.currentState!.value,
                      );

                      // IMAGE
                      if (_uploadedImageFile != null) {
                        final uploadedUrl = await _fileProvider.uploadFile(
                          FileModel(
                            file: _uploadedImageFile!,
                            subfolder: 'Images/Products',
                          ),
                        );
                        values['imageUrl'] = uploadedUrl;
                      } else {
                        values['imageUrl'] = product?.imageUrl;
                      }

                      if (isEdit) {
                        await _productProvider.update(product.id, values);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Product updated successfully"),
                          ),
                        );
                      } else {
                        await _productProvider.create(values);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Product added successfully"),
                          ),
                        );
                      }

                      await _fetchProduct();
                      widget.closeForm();
                    }
                  },
                  child: Text(isEdit ? 'Update Product' : 'Add Product'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

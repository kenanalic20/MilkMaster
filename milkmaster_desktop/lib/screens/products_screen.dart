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
import 'package:milkmaster_desktop/models/unit_model.dart';
import 'package:milkmaster_desktop/providers/cattle_category_provider.dart';
import 'package:milkmaster_desktop/providers/file_provider.dart';
import 'package:milkmaster_desktop/providers/product_category_provider.dart';
import 'package:milkmaster_desktop/providers/products_provider.dart';
import 'package:milkmaster_desktop/providers/units_provider.dart';
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
  late UnitsProvider _unitsProvider;
  List<Product> _products = [];
  List<CattleCategory> _cattleCategories = [];
  List<ProductCategory> _productCategories = [];
  List<Unit> _units = [];
  Product? _singleProduct;
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
    _unitsProvider = context.read<UnitsProvider>();
    _fetchProduct(extraQuery: {"pageSize": _pageSize});
    _fetchCattleCategories();
    _fetchProductCategories();
    _fetchUnits();
  }

  void openForm() async {
    _uploadedImageFile = null;
    _fileProvider = context.read<FileProvider>();
    widget.openForm(
      SingleChildScrollView(
        child: MasterWidget(title: 'Add Product', body: _buildProductForm()),
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

  Future<void> _fetchById(int id) async {
    final result = await _productProvider.getById(id);
    if (mounted) {
      setState(() {
        _singleProduct = result;
      });
    }
  }

  Future<void> _fetchUnits() async {
    final result = await _unitsProvider.fetchAll();
    if (mounted) {
      setState(() {
        _units = result.items;
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
                    onTap: () async {
                      await _fetchById(product.id);
                      widget.openForm(
                        SingleChildScrollView(
                          child: MasterWidget(
                            title: product.title,
                            headerActions: Center(
                              child: ElevatedButton(
                                onPressed: () => widget.closeForm(),

                                child: const Text('X'),
                              ),
                            ),
                            body: _buildProductView(product: _singleProduct!),
                          ),
                        ),
                      );
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // Description
                        SizedBox(
                          height: 40,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              product.description ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 8,
                          ),
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
                                      onPressed: () async {
                                        await _fetchById(product.id);
                                        widget.openForm(
                                          SingleChildScrollView(
                                            child: MasterWidget(
                                              title: 'Edit Product',
                                              subtitle: product.title,
                                              body: _buildProductForm(
                                                product: _singleProduct,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      style: AppButtonStyles.secondary,
                                      child: const Text("Edit"),
                                    ),
                                  ),
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
              initialValue:
                  product != null && product.imageUrl.isNotEmpty ? null : null,
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
                        padding: const EdgeInsets.only(top: 6),
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
            SizedBox(height: Theme.of(context).extension<AppSpacing>()!.medium),

            // TITLE
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: FormBuilderTextField(
                  name: 'title',
                  initialValue: product?.title ?? '',
                  decoration: const InputDecoration(labelText: 'Product Title'),
                  validator: FormBuilderValidators.required(),
                ),
              ),
            ),
            SizedBox(height: Theme.of(context).extension<AppSpacing>()!.medium),

            // PRICE PER UNIT
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: FormBuilderTextField(
                  name: 'pricePerUnit',
                  initialValue: product?.pricePerUnit?.toString() ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Price per Unit',
                    prefixIcon: Icon(Icons.attach_money_outlined),

                  ),
                  keyboardType: TextInputType.number,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.numeric(),
                  ]),
                ),
              ),
            ),
            SizedBox(height: Theme.of(context).extension<AppSpacing>()!.medium),

            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: FormBuilderDropdown<int>(
                  name: 'unitId',
                  initialValue: product?.unit?.id,
                  decoration: const InputDecoration(labelText: 'Unit'),
                  validator: FormBuilderValidators.required(),
                  items:
                      _units
                          .map(
                            (u) => DropdownMenuItem(
                              value: u.id,
                              child: Text(u.symbol),
                            ),
                          )
                          .toList(),
                ),
              ),
            ),
            SizedBox(height: Theme.of(context).extension<AppSpacing>()!.medium),

            // QUANTITY
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: FormBuilderTextField(
                  name: 'quantity',
                  initialValue: product?.quantity?.toString() ?? '',
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.integer(),
                  ]),
                ),
              ),
            ),
            SizedBox(height: Theme.of(context).extension<AppSpacing>()!.medium),

            // DESCRIPTION
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: FormBuilderTextField(
                  name: 'description',
                  initialValue: product?.description ?? '',
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
              ),
            ),
            SizedBox(height: Theme.of(context).extension<AppSpacing>()!.medium),

            // PRODUCT CATEGORIES (Multiselect)
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: FormBuilderFilterChips<dynamic>(
                  spacing: 5,
                  runSpacing: 5,
                  name: 'productCategories',
                  initialValue:
                      product?.productCategories?.map((c) => c.id).toList() ??
                      [],
                  decoration: const InputDecoration(labelText: 'Categories'),
                  options:
                      _productCategories
                          .map(
                            (c) => FormBuilderChipOption(
                              value: c.id,
                              child: Text(c.name),
                            ),
                          )
                          .toList(),
                ),
              ),
            ),
            SizedBox(height: Theme.of(context).extension<AppSpacing>()!.medium),

            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: FormBuilderDropdown<int>(
                  name: 'cattleCategoryId',
                  initialValue: product?.cattleCategory?.id,
                  decoration: const InputDecoration(
                    labelText: 'Cattle Category',
                  ),
                  items:
                      _cattleCategories
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
                            ),
                          )
                          .toList(),
                ),
              ),
            ),
            SizedBox(height: Theme.of(context).extension<AppSpacing>()!.medium),

            // --- NUTRITION SECTION ---
            const Divider(height: 32),
            Center(
              child: Text(
                "Nutrition (optional)",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            SizedBox(height: Theme.of(context).extension<AppSpacing>()!.medium),

            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: FormBuilderTextField(
                  name: 'energy',
                  initialValue: product?.nutrition?.energy?.toString() ?? '',
                  decoration: const InputDecoration(labelText: 'Energy (kcal)'),
                  keyboardType: TextInputType.number,
                  validator: FormBuilderValidators.numeric(),
                ),
              ),
            ),
            SizedBox(height: Theme.of(context).extension<AppSpacing>()!.medium),

            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: FormBuilderTextField(
                  name: 'fat',
                  initialValue: product?.nutrition?.fat?.toString() ?? '',
                  decoration: const InputDecoration(labelText: 'Fat (g)'),
                  keyboardType: TextInputType.number,
                  validator: FormBuilderValidators.numeric(),
                ),
              ),
            ),
            SizedBox(height: Theme.of(context).extension<AppSpacing>()!.medium),

            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: FormBuilderTextField(
                  name: 'carbohydrates',
                  initialValue:
                      product?.nutrition?.carbohydrates?.toString() ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Carbohydrates (g)',
                  ),
                  keyboardType: TextInputType.number,
                  validator: FormBuilderValidators.numeric(),
                ),
              ),
            ),
            SizedBox(height: Theme.of(context).extension<AppSpacing>()!.medium),

            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: FormBuilderTextField(
                  name: 'protein',
                  initialValue: product?.nutrition?.protein?.toString() ?? '',
                  decoration: const InputDecoration(labelText: 'Protein (g)'),
                  keyboardType: TextInputType.number,
                  validator: FormBuilderValidators.numeric(),
                ),
              ),
            ),
            SizedBox(height: Theme.of(context).extension<AppSpacing>()!.medium),

            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: FormBuilderTextField(
                  name: 'salt',
                  initialValue: product?.nutrition?.salt?.toString() ?? '',
                  decoration: const InputDecoration(labelText: 'Salt (g)'),
                  keyboardType: TextInputType.number,
                  validator: FormBuilderValidators.numeric(),
                ),
              ),
            ),
            SizedBox(height: Theme.of(context).extension<AppSpacing>()!.medium),

            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: FormBuilderTextField(
                  name: 'calcium',
                  initialValue: product?.nutrition?.calcium?.toString() ?? '',
                  decoration: const InputDecoration(labelText: 'Calcium (mg)'),
                  keyboardType: TextInputType.number,
                  validator: FormBuilderValidators.numeric(),
                ),
              ),
            ),

            SizedBox(height: Theme.of(context).extension<AppSpacing>()!.medium),

            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => widget.closeForm(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    Builder(
                      builder: (context) {
                        return ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState?.saveAndValidate() ??
                                false) {
                              final body = Map<String, dynamic>.from(
                                _formKey.currentState!.value,
                              );
                              body.remove('image');
                              if (_uploadedImageFile != null) {
                                final uploadedUrl = await _fileProvider
                                    .uploadFile(
                                      FileModel(
                                        file: _uploadedImageFile!,
                                        subfolder: 'Images/Products',
                                      ),
                                    );
                                body['imageUrl'] = uploadedUrl;
                              } else {
                                body['imageUrl'] = product?.imageUrl;
                              }
                              // Build nutrition object safely
                              final energyVal = body.remove('energy');
                              final fatVal = body.remove('fat');
                              final carbVal = body.remove('carbohydrates');
                              final proteinVal = body.remove('protein');
                              final saltVal = body.remove('salt');
                              final calciumVal = body.remove('calcium');

                              final nutrition = {
                                'energy':
                                    (energyVal == null ||
                                            energyVal.toString().isEmpty)
                                        ? null
                                        : double.parse(energyVal),
                                'fat':
                                    (fatVal == null ||
                                            fatVal.toString().isEmpty)
                                        ? null
                                        : double.parse(fatVal),
                                'carbohydrates':
                                    (carbVal == null ||
                                            carbVal.toString().isEmpty)
                                        ? null
                                        : double.parse(carbVal),
                                'protein':
                                    (proteinVal == null ||
                                            proteinVal.toString().isEmpty)
                                        ? null
                                        : double.parse(proteinVal),
                                'salt':
                                    (saltVal == null ||
                                            saltVal.toString().isEmpty)
                                        ? null
                                        : double.parse(saltVal),
                                'calcium':
                                    (calciumVal == null ||
                                            calciumVal.toString().isEmpty)
                                        ? null
                                        : double.parse(calciumVal),
                              };

                              if (nutrition.values.any((v) => v != null)) {
                                body['nutrition'] = nutrition;
                              } else {
                                body['nutrition'] = null;
                              }

                              if (isEdit) {
                                await showCustomDialog(
                                context: context,
                                title: "Update Product",
                                message:
                                    "Are you sure you want to update '${product.title}'?",
                                onConfirm: () async {
                                  await _productProvider.update(product.id, body);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Product Updated successfully",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      backgroundColor:
                                          Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  widget.closeForm();
                                },
                              );
                              } else {
                                 await showCustomDialog(
                                context: context,
                                title: "Add Product",
                                message:
                                    "Are you sure you want to add '${body['title']}'?",
                                onConfirm: () async {
                                  await _productProvider.create(body);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Product Added successfully",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      backgroundColor:
                                          Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  widget.closeForm();
                                },
                              );
                              }

                              await _fetchProduct();
                              widget.closeForm();
                            }
                          },
                          child: Text(
                            isEdit ? 'Update Product' : 'Add Product',
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductView({required Product product}) {
    final nutrition = product.nutrition;
    final cattleCategory = product.cattleCategory;
    final categories = product.productCategories ?? [];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product.imageUrl.isNotEmpty)
            FilePickerWithPreview(imageUrl: product.imageUrl, hasButton: false),
          const SizedBox(height: 16),

          // BASIC INFO
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Basic Info',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  buildInfoRow('Title', product.title),
                  buildInfoRow('Price per Unit', "${product.pricePerUnit}"),
                  buildInfoRow('Unit', product.unit?.symbol),
                  buildInfoRow('Quantity', product.quantity.toString()),
                  buildInfoRow('Description', product.description),
                ],
              ),
            ),
          ),

          // PRODUCT CATEGORIES
          if (categories.isNotEmpty)
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Product Categories',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          categories.map((c) {
                            return Chip(
                              avatar:
                                  (c.imageUrl.isNotEmpty)
                                      ? CircleAvatar(
                                        backgroundImage: NetworkImage(
                                          c.imageUrl,
                                        ),
                                      )
                                      : null,
                              label: Text(c.name),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
            ),

          // CATTLE CATEGORY
          if (cattleCategory != null)
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cattle Category',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    if (cattleCategory.imageUrl.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Image.network(
                          cattleCategory.imageUrl,
                          height: 80,
                          fit: BoxFit.contain,
                        ),
                      ),
                    buildInfoRow('Name', cattleCategory.name),
                    buildInfoRow('Title', cattleCategory.title),
                    buildInfoRow('Description', cattleCategory.description),
                  ],
                ),
              ),
            ),

          // NUTRITION
          if (nutrition != null)
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nutrition',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    buildInfoRow('Energy', nutrition.energy?.toString()),
                    buildInfoRow('Fat', nutrition.fat?.toString()),
                    buildInfoRow(
                      'Carbohydrates',
                      nutrition.carbohydrates?.toString(),
                    ),
                    buildInfoRow('Protein', nutrition.protein?.toString()),
                    buildInfoRow('Salt', nutrition.salt?.toString()),
                    buildInfoRow('Calcium', nutrition.calcium?.toString()),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:milkmaster_desktop/main.dart';
import 'package:milkmaster_desktop/models/file_model.dart';
import 'package:milkmaster_desktop/models/product_category_model.dart';
import 'package:milkmaster_desktop/providers/file_provider.dart';
import 'package:milkmaster_desktop/providers/product_category_provider.dart';
import 'package:milkmaster_desktop/screens/animal_categories.dart';
import 'package:milkmaster_desktop/utils/widget_helpers.dart';
import 'package:milkmaster_desktop/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class CategoriesScreen extends StatefulWidget {
  final void Function(Widget form) openForm;
  final void Function() closeForm;

  const CategoriesScreen({
    super.key,
    required this.openForm,
    required this.closeForm,
  });

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late ProductCategoryProvider _productCategoryProvider;
  late FileProvider _fileProvider;
  List<ProductCategoryAdmin> _productCategories = [];
  int? _hoveredCategoryId;
  final _formKey = GlobalKey<FormBuilderState>();
  File? _uploadedImageFile;
  final GlobalKey _animalCategoriesKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _productCategoryProvider = context.read<ProductCategoryProvider>();
    _fileProvider = context.read<FileProvider>();
    _fetchProductCategories();
  }

  void openAnimalForm() {
    (_animalCategoriesKey.currentState as dynamic)?.openForm();
  }

  void openForm() async {
    _uploadedImageFile = null;
    _formKey.currentState?.reset();
    widget.openForm(
      MasterWidget(
        title: 'Add Category',
        subtitle: '',
        body: _buildProductCategoryForm(category: null),
      ),
    );
  }

  Future<void> _deleteCategory(category) async {
    await _productCategoryProvider.delete(category.id);
    await _fetchProductCategories();
    await _fileProvider.deleteFile(
      FileDeleteModel(
        fileUrl: category.imageUrl,
        subfolder: 'Images/Categories',
      ),
    );
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


  Widget _buildProductCategories() {
    return Wrap(
      spacing: 34,
      runSpacing: 28,
      children:
          _productCategories.map((category) {
            final isHovered = _hoveredCategoryId == category.id;

            return MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) {
                setState(() => _hoveredCategoryId = category.id);
              },
              onExit: (_) {
                setState(() => _hoveredCategoryId = null);
              },

              child: GestureDetector(
                onTap: () async {
                  widget.openForm(
                      SingleChildScrollView(
                        child: MasterWidget(
                          title: category.name,
                          headerActions: Center(
                            child: ElevatedButton(
                              onPressed: () => widget.closeForm(),

                              child: const Text('X'),
                            ),
                          ),
                          body:_buildProductCategoryView(category: category) 
                        ),
                      )
                  );
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
                                  onTap: () async {
                                    widget.openForm(
                                      MasterWidget(
                                        title: 'Edit Category',
                                        subtitle: category.name,
                                        body: _buildProductCategoryForm(
                                          category: category,
                                        ),
                                      ),
                                    );
                                  },
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
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Product Category Deleted successfully",
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
                                        _deleteCategory(category);
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
              ),
            );
          }).toList(),
    );
  }
Widget _buildProductCategoryView({required ProductCategoryAdmin category}) {
  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (category.imageUrl.isNotEmpty)
          Center(
            child: FilePickerWithPreview(imageUrl: category.imageUrl,hasButton: false)
            
          ),
        const SizedBox(height: 16),

        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Product Category Info',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                buildInfoRow('Name', category.name),
                buildInfoRow('Number of Products', category.count.toString()),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

  FormBuilder _buildProductCategoryForm({category = null}) {
    final isEdit = category != null;
    return FormBuilder(
      key: _formKey,
      child: Column(
        children: [
          FormBuilderField<File?>(
            name: 'image',
            initialValue:
                category != null && category.imageUrl.isNotEmpty ? null : null,
            validator: (val) {
              if (!isEdit && (val == null)) {
                return 'Image is required for new categories';
              }
              return null;
            },
            builder: (field) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FilePickerWithPreview(
                    imageUrl: category?.imageUrl,
                    onFileSelected: (file) {
                      _uploadedImageFile = file;
                      field.didChange(file);
                      field.validate();
                    },
                  ),
                  if (field.errorText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Center(
                        child: Text(
                          field.errorText!,
                          style: TextStyle(
                            color: Theme.of(field.context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          SizedBox(height: Theme.of(context).extension<AppSpacing>()!.medium),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              child: FormBuilderTextField(
                name: 'name',
                initialValue: category?.name ?? '',
                decoration: const InputDecoration(labelText: 'Category Name'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'Category name is required',
                  ),
                ]),
              ),
            ),
          ),
          SizedBox(height: Theme.of(context).extension<AppSpacing>()!.medium),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              child: Row(
                children: [
                  Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      widget.closeForm();
                    },
                    child: const Text('Cancel'),
                  ),
                  SizedBox(
                    width: Theme.of(context).extension<AppSpacing>()!.medium,
                  ),
                  Builder(
                    builder: (dialogContext) {
                      return ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState?.saveAndValidate() ??
                              false) {
                            final body = Map<String, dynamic>.from(
                              _formKey.currentState!.value,
                            );
                            body.remove('image');

                            if (isEdit) {
                              if (_uploadedImageFile != null) {
                                final uploadedUrl = await _fileProvider
                                    .updateFile(
                                      FileUpdateModel(
                                        oldFileUrl: category!.imageUrl,
                                        file: _uploadedImageFile!,
                                        subfolder: 'Images/Categories',
                                      ),
                                    );
                                body['imageUrl'] = uploadedUrl;
                              } else {
                                body['imageUrl'] = category!.imageUrl;
                              }
                              await showCustomDialog(
                                context: dialogContext,
                                title: "Update Category",
                                message:
                                    "Are you sure you want to update '${category!.name}'?",
                                onConfirm: () async {
                                  await _productCategoryProvider.update(
                                    category.id,
                                    body,
                                  );
                                  ScaffoldMessenger.of(
                                    dialogContext,
                                  ).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Product Category Updated successfully",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      backgroundColor:
                                          Theme.of(
                                            dialogContext,
                                          ).colorScheme.secondary,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  await _fetchProductCategories();
                                  widget.closeForm();
                                },
                              );
                            } else {
                              if (_uploadedImageFile != null) {
                                final uploadedUrl = await _fileProvider
                                    .uploadFile(
                                      FileModel(
                                        file: _uploadedImageFile!,
                                        subfolder: 'Images/Categories',
                                      ),
                                    );
                                body['imageUrl'] = uploadedUrl;
                              } else {
                                body['imageUrl'] = null;
                              }

                              await showCustomDialog(
                                context: dialogContext,
                                title: "Create Category",
                                message:
                                    "Are you sure you want to create '${body['name']}'?",
                                onConfirm: () async {
                                  if (body['imageUrl'] != null) {
                                    await _productCategoryProvider.create(body);
                                    ScaffoldMessenger.of(
                                      dialogContext,
                                    ).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Product Category Added successfully",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        backgroundColor:
                                            Theme.of(
                                              dialogContext,
                                            ).colorScheme.secondary,
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                    await _fetchProductCategories();
                                    widget.closeForm();
                                  }
                                },
                              );
                            }
                          }
                        },
                        child: Text(
                          isEdit ? 'Update Category' : 'Create Category',
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _productCategoryProvider.isLoading? const Center(child: CircularProgressIndicator()) 
        : _productCategories.isEmpty? NoDataWidget() : _buildProductCategories(),
        SizedBox(height: Theme.of(context).extension<AppSpacing>()!.large),
        AnimalCategoriesScreen(
          key: _animalCategoriesKey,
          openForm: widget.openForm,
          closeForm: widget.closeForm,
        ),
      ],
    );
  }
}

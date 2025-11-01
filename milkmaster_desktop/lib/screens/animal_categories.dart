import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:milkmaster_desktop/main.dart';
import 'package:milkmaster_desktop/models/cattle_category_model.dart';
import 'package:milkmaster_desktop/models/file_model.dart';
import 'package:milkmaster_desktop/providers/cattle_category_provider.dart';
import 'package:milkmaster_desktop/providers/file_provider.dart';
import 'package:milkmaster_desktop/utils/widget_helpers.dart';
import 'package:milkmaster_desktop/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class AnimalCategoriesScreen extends StatefulWidget {
  final void Function(Widget form) openForm;
  final void Function() closeForm;

  const AnimalCategoriesScreen({
    super.key,
    required this.openForm,
    required this.closeForm,
  });

  @override
  State<AnimalCategoriesScreen> createState() => _AnimalCategoriesScreenState();
}

class _AnimalCategoriesScreenState extends State<AnimalCategoriesScreen> {
  late CattleCategoryProvider _cattleCategoryProvider;
  late FileProvider _fileProvider;
  List<CattleCategory> _cattleCategories = [];
  int? _hoveredCategoryId;
  final _formKey = GlobalKey<FormBuilderState>();
  File? _uploadedImageFile;

  @override
  void initState() {
    super.initState();
    _cattleCategoryProvider = context.read<CattleCategoryProvider>();
    _fetchCattleCategories();
  }

  void openForm() async {
    _uploadedImageFile = null;
    _fileProvider = context.read<FileProvider>();
    widget.openForm(
      SingleChildScrollView(
        child: MasterWidget(
          title: 'Add Animal Category',
          subtitle: '',
          body: _buildCattleCategoryForm(),
        ),
      ),
    );
  }

  Future<void> _fetchCattleCategories() async {
    try {
      var fetchedItems = await _cattleCategoryProvider.fetchAll();
      if (mounted) {
        setState(() {
          _cattleCategories = fetchedItems.items;
        });
      }
    } catch (e) {
      print("Error fetching cattle categories: $e");
    }
  }

  Widget ColumnWidget(category) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        category.title,
        style: TextStyle(
          fontSize: Theme.of(context).textTheme.headlineMedium?.fontSize,
          color: Color.fromRGBO(245, 127, 23, 1),
          fontWeight: Theme.of(context).textTheme.headlineMedium?.fontWeight,
        ),
      ),
      Text(category.description),
    ],
  );

  FormBuilder _buildCattleCategoryForm({category = null}) {
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
                name: 'title',
                initialValue: category?.title ?? '',
                decoration: const InputDecoration(labelText: 'Category Title'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'Category title is required',
                  ),
                ]),
              ),
            ),
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
              child: FormBuilderTextField(
                name: 'description',
                maxLines: 5,
                initialValue: category?.description ?? '',
                decoration: const InputDecoration(
                  labelText: 'Category description',
                ),
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
                      widget.closeForm(); // close form
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
                              // update flow (existing behavior)
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
                                title: "Update Cattle Category",
                                message:
                                    "Are you sure you want to update '${category!.name}'?",
                                onConfirm: () async {
                                  await _cattleCategoryProvider.update(
                                    category.id,
                                    body,
                                  );
                                  ScaffoldMessenger.of(
                                    dialogContext,
                                  ).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Cattle Category Update successfully",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      backgroundColor:
                                          Theme.of(
                                            dialogContext,
                                          ).colorScheme.secondary,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  await _fetchCattleCategories();
                                  widget.closeForm();
                                },
                              );
                            } else {
                              // add flow
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
                                title: "Create Cattle Category",
                                message:
                                    "Are you sure you want to create '${body['name']}'?",
                                onConfirm: () async {
                                  if (body['imageUrl'] != null) {
                                    await _cattleCategoryProvider.create(body);
                                    ScaffoldMessenger.of(
                                      dialogContext,
                                    ).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Cattle Category Added successfully",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        backgroundColor:
                                            Theme.of(
                                              dialogContext,
                                            ).colorScheme.secondary,
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                    await _fetchCattleCategories();
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

  Widget _buildCattleCategoryView({required CattleCategory category}) {
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
                    'Cattle Category Info',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  buildInfoRow('Name', category.name),
                  buildInfoRow('Title', category.title),
                  buildInfoRow('Description', category.description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCattleCategories() {
    return MasterWidget(
      title: 'Animal Categories',
      subtitle: 'Manage your cattle categories',
      headerActions: CattleCategoriesHeaderAction(
        onPressed: () {
          openForm();
        },
      ),
      hasData: _cattleCategories.isNotEmpty,
      padding: 0,
      body: Wrap(
        spacing: 30,
        runSpacing: 20,
        children:
            _cattleCategories.asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value;
              final isHovered = _hoveredCategoryId == category.id;

              final rowChildren =
                  index % 2 == 0
                      ? [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.254,
                          padding: const EdgeInsets.fromLTRB(10, 15, 10, 40),
                          child: ColumnWidget(category),
                        ),

                        Image.network(
                          category.imageUrl,
                          width: 127,
                          height: 127,
                        ),
                      ]
                      : [
                        Image.network(
                          category.imageUrl,
                          width: 127,
                          height: 127,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.254,
                          padding: const EdgeInsets.fromLTRB(10, 15, 10, 40),
                          child: Container(
                            padding: const EdgeInsets.only(left: 60),
                            child: ColumnWidget(category),
                          ),
                        ),
                      ];

              return MouseRegion(
                cursor: SystemMouseCursors.click,

                onEnter:
                    (_) => setState(() => _hoveredCategoryId = category.id),
                onExit: (_) => setState(() => _hoveredCategoryId = null),
                child: GestureDetector(
                  onTap: () async {
                    widget.openForm(
                      SingleChildScrollView(
                        child: MasterWidget(
                          headerActions: Center(
                            child: ElevatedButton(
                              onPressed: () => widget.closeForm(),

                              child: const Text('X'),
                            ),
                          ),
                          title: category.name,
                          body: _buildCattleCategoryView(category: category),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 4),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: Stack(
                      children: [
                        if (isHovered)
                          index % 2 != 0
                              ? actionIcons(category, direction: 'right')
                              : actionIcons(category, direction: 'left'),
                        Wrap(
                          children: [
                            ...rowChildren
                                .map(
                                  (child) => Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        child: child,
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Positioned actionIcons(CattleCategory category, {String direction = 'left'}) {
    return Positioned(
      bottom: 10,
      left: direction == 'left' ? 16 : null, // use left if direction is left
      right: direction == 'right' ? 16 : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: leadingIcon('assets/icons/pentool_icon.png'),
              ),
              onTap: () async {
                widget.openForm(
                  SingleChildScrollView(
                    child: MasterWidget(
                      title: 'Edit Category',
                      subtitle: category.name,
                      body: _buildCattleCategoryForm(category: category),
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
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: leadingIcon('assets/icons/trash_icon.png'),
              ),
              onTap: () async {
                await showCustomDialog(
                  context: context,
                  title: "Delete Category",
                  message:
                      "Are you sure you want to delete '${category.name}'?",
                  onConfirm: () async {
                    await _cattleCategoryProvider.delete(category.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Cattle Category Deleted successfully",
                          style: TextStyle(color: Colors.black),
                        ),
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    await _fetchCattleCategories();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildCattleCategories();
  }
}

class CattleCategoriesHeaderAction extends StatelessWidget {
  final VoidCallback? onPressed;
  const CattleCategoriesHeaderAction({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      margin: EdgeInsets.only(
        top: Theme.of(context).extension<AppSpacing>()!.medium,
      ),
      child: ElevatedButton(
        onPressed: onPressed ?? () async => {},
        child: Text('Add Product Category'),
      ),
    );
  }
}

import 'dart:io';
import 'dart:math';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:milkmaster_desktop/main.dart';
import 'package:milkmaster_desktop/models/cattle_category_model.dart';
import 'package:milkmaster_desktop/models/cattle_model.dart';
import 'package:milkmaster_desktop/models/file_model.dart';
import 'package:milkmaster_desktop/providers/cattle_category_provider.dart';
import 'package:milkmaster_desktop/providers/cattle_provider.dart';
import 'package:milkmaster_desktop/providers/file_provider.dart';
import 'package:milkmaster_desktop/utils/widget_helpers.dart';
import 'package:milkmaster_desktop/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class CattleScreen extends StatefulWidget {
  final void Function(Widget form) openForm;
  final void Function() closeForm;

  const CattleScreen({
    super.key,
    required this.openForm,
    required this.closeForm,
  });

  @override
  State<CattleScreen> createState() => _CattleScreenState();
}

class _CattleScreenState extends State<CattleScreen> {
  late CattleProvider _cattleProvider;
  late CattleCategoryProvider _cattleCategoryProvider;
  late FileProvider _fileProvider;
  List<Cattle> _cattle = [];
  Cattle? _singleCattle;
  List<CattleCategory> _categories = [];
  final _formKey = GlobalKey<FormBuilderState>();

  int _pageSize = 8;
  int _totalCount = 0;
  int _currentPage = 1;
  double _totalLiters = 0;
  double _totalRevenue = 0;
  int? _selectedCategory;
  String? _selectedSort;
  File? _uploadedImageFile;
  File? _uploadedPdfFile;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cattleProvider = context.read<CattleProvider>();
    _cattleCategoryProvider = context.read<CattleCategoryProvider>();
    _fileProvider = context.read<FileProvider>();
    _fetchCategories();
    _fetchCattle(extraQuery: {"pageSize": _pageSize});
  }

  void openForm() async {
    _uploadedImageFile = null;
    _fileProvider = context.read<FileProvider>();
    widget.openForm(
      SingleChildScrollView(
        child: MasterWidget(title: 'Add Cattle', body: _buildCattleForm()),
      ),
    );
  }

  Future<void> _fetchCategories() async {
    final result = await _cattleCategoryProvider.fetchAll();
    if (mounted) {
      setState(() {
        _categories = result.items;
        _totalCount = result.totalCount;
      });
    }
  }

  Future<void> _fetchById(int id) async {
    final result = await _cattleProvider.getById(id);
    if (mounted) {
      setState(() {
        _singleCattle = result;
      });
    }
  }

  Future<void> _fetchCattle({
    int? page,
    Map<String, dynamic>? extraQuery,
  }) async {
    try {
      final queryParams = {
        "pageSize": _pageSize,
        "pageNumber": page ?? _currentPage,
        if (extraQuery != null) ...extraQuery,
      };

      final result = await _cattleProvider.fetchAll(queryParams: queryParams);

      if (mounted) {
        setState(() {
          _cattle = result.items;
          _totalCount = result.totalCount;
          _totalLiters = result.totalLiters;
          _totalRevenue = result.totalRevenue;
        });
      }
    } catch (e) {
      print("Error fetching cattle: $e");
    }
  }

  Future<void> _deleteCattle(cattle) async {
    await _cattleProvider.delete(cattle.id);
    await _fetchCattle();
    await _fileProvider.deleteFile(
      FileDeleteModel(fileUrl: cattle.imageUrl, subfolder: 'Images/Cattle'),
    );
    await _fileProvider.deleteFile(
      FileDeleteModel(
        fileUrl: cattle.milkCartonUrl,
        subfolder: 'Documents/MilkCartons',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearch(),
        _buildCattleStats(),
        _buildCattle(context),
        _buildPagination(),
      ],
    );
  }

  Widget _buildCattleStats() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: Theme.of(context).extension<AppSpacing>()!.large,
      ),
      child: Row(
        children: [
          Wrap(
            spacing: Theme.of(context).extension<AppSpacing>()!.large,
            children: [
              Container(
                width: 230,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.tertiary,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Total Cattle",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing:
                            Theme.of(context).extension<AppSpacing>()!.small,
                        children: [
                          leadingIcon('assets/icons/cow_icon_yellow.png'),
                          Text(
                            _totalCount.toString(),
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: 230,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.tertiary,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Milk Production",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing:
                            Theme.of(context).extension<AppSpacing>()!.small,

                        children: [
                          leadingIcon('assets/icons/milk_icon_yellow.png'),
                          Text(
                            "${formatDouble(_totalLiters)} L",
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: 230,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.tertiary,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      Text(
                        "Total Revenue",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing:
                            Theme.of(context).extension<AppSpacing>()!.small,
                        children: [
                          Text(
                            formatDouble(_totalRevenue),
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          Text(
                            "BAM",
                            style: Theme.of(
                              context,
                            ).textTheme.headlineMedium?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
        await _fetchCattle(extraQuery: {"page": page, "pageSize": _pageSize});
      },
    );
  }

  Widget _buildSearch() {
    final sortOptions = [
      {'label': 'Age Asc', 'value': 'age_asc'},
      {'label': 'Age Desc', 'value': 'age_desc'},
      {'label': 'Milk Asc', 'value': 'milk_asc'},
      {'label': 'Milk Desc', 'value': 'milk_desc'},
      {'label': 'Revenue Asc', 'value': 'revenue_asc'},
      {'label': 'Revenue Desc', 'value': 'revenue_desc'},
    ];

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
                await _fetchCattle(
                  extraQuery: {
                    'search': value,
                    'cattleCategoryId': _selectedCategory,
                    'orderBy': _selectedSort,
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
                value: _selectedCategory,
                items:
                    _categories.map((category) {
                      return DropdownMenuItem<int>(
                        value: category.id,
                        child: Text(category.name),
                      );
                    }).toList(),
                onChanged: (value) async {
                  setState(() {
                    _selectedCategory = value;
                    _currentPage = 1;
                  });
                  await _fetchCattle(
                    extraQuery: {
                      'search': _searchController.text,
                      'cattleCategoryId': _selectedCategory,
                      'orderBy': _selectedSort,
                      'pageSize': _pageSize,
                      'pageNumber': _currentPage,
                    },
                  );
                },
                hint: Text(
                  'Animal type',
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
            width: 115,
            child: DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                value: _selectedSort,
                items:
                    sortOptions.map((option) {
                      return DropdownMenuItem(
                        value: option['value'],
                        child: SizedBox(
                          width: 70,
                          child: Text(option['label']!),
                        ),
                      );
                    }).toList(),
                onChanged: (value) async {
                  print(_selectedSort);

                  setState(() {
                    _selectedSort = value;
                    _currentPage = 1;
                  });

                  await _fetchCattle(
                    extraQuery: {
                      'search': _searchController.text,
                      'cattleCategoryId': _selectedCategory,
                      'orderBy': _selectedSort,
                      'pageSize': _pageSize,
                      'pageNumber': _currentPage,
                    },
                  );
                },
                hint: Text(
                  'Sort',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                style: Theme.of(context).textTheme.bodyMedium,
                buttonStyleData: ButtonStyleData(
                  height: 45,
                  width: 100,
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
            width: 137,
            child: ElevatedButton(
              onPressed: () async => {openForm()},
              child: Text('Add Cattle'),
            ),
          ),
        ],
      ),
    );
  }

  FormBuilder _buildCattleForm({cattle = null}) {
    final isEdit = cattle != null;
    return FormBuilder(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            FormBuilderField<File?>(
              name: 'image',
              initialValue:
                  cattle != null && cattle.imageUrl.isNotEmpty ? null : null,
              validator: (val) {
                if (!isEdit && (val == null)) {
                  return 'Image is required for new categories';
                }
                return null;
              },
              builder: (field) {
                return Column(
                  children: [
                    FilePickerWithPreview(
                      imageUrl: cattle?.imageUrl,
                      onFileSelected: (file) {
                        _uploadedImageFile = file;
                        field.didChange(file);
                        field.validate();
                      },
                    ),
                    if (field.errorText != null)
                      Center(
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

            FormBuilderField<File?>(
              name: 'milkCarton',
              validator:
                  (val) =>
                      !isEdit && val == null
                          ? 'Milk carton PDF is required'
                          : null,
              builder:
                  (field) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              FilePickerResult? result = await FilePicker
                                  .platform
                                  .pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: ['pdf'],
                                  );
                              if (result != null) {
                                final file = File(result.files.single.path!);
                                _uploadedPdfFile = file;
                                field.didChange(file);
                              }
                            },
                            child: Text(
                              _uploadedPdfFile != null
                                  ? "PDF Selected: ${_uploadedPdfFile!.path.split('/').last}"
                                  : (cattle?.milkCartonUrl != null &&
                                          cattle!.milkCartonUrl!.isNotEmpty
                                      ? "Current PDF: ${cattle.milkCartonUrl!.split('/').last}"
                                      : "Select Milk Carton PDF"),
                            ),
                          ),
                        ),
                      ),
                      if (field.errorText != null)
                        Center(
                          child: Text(
                            field.errorText!,
                            style: TextStyle(
                              color: Theme.of(field.context).colorScheme.error,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
            ),
            SizedBox(height: Theme.of(context).extension<AppSpacing>()!.medium),

            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: FormBuilderTextField(
                  name: 'name',
                  initialValue: cattle?.name ?? '',
                  decoration: const InputDecoration(labelText: 'Cattle Name'),
                  validator: FormBuilderValidators.required(),
                ),
              ),
            ),
            SizedBox(height: Theme.of(context).extension<AppSpacing>()!.medium),

            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: FormBuilderTextField(
                  name: 'tagNumber',
                  initialValue: cattle?.tagNumber ?? '',
                  decoration: const InputDecoration(labelText: 'Tag Number'),
                  validator: FormBuilderValidators.required(),
                ),
              ),
            ),
            SizedBox(height: Theme.of(context).extension<AppSpacing>()!.medium),

            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: FormBuilderDropdown<int>(
                  name: 'cattleCategoryId',
                  decoration: const InputDecoration(
                    labelText: 'Cattle Category',
                  ),
                  items:
                      _categories
                          .map(
                            (cat) => DropdownMenuItem(
                              value: cat.id,
                              child: Text(cat.name),
                            ),
                          )
                          .toList(),
                  initialValue: cattle?.cattleCategory?.id ?? '',
                ),
              ),
            ),
            SizedBox(height: Theme.of(context).extension<AppSpacing>()!.medium),

            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: FormBuilderTextField(
                  name: 'breedOfCattle',
                  initialValue: cattle?.breedOfCattle ?? null,
                  decoration: const InputDecoration(labelText: 'Breed'),
                ),
              ),
            ),
            SizedBox(height: Theme.of(context).extension<AppSpacing>()!.medium),

            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,

                child: FormBuilderTextField(
                  name: 'litersPerDay',
                  initialValue: cattle?.litersPerDay?.toString() ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Liters per Day',
                    prefixIcon: Icon(Icons.local_drink_outlined),
                  ),
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
                child: FormBuilderTextField(
                  name: 'monthlyValue',
                  initialValue: cattle?.monthlyValue?.toString() ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Monthly Value',
                    prefixIcon: Icon(Icons.attach_money_outlined),
                  ),
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
                child: FormBuilderDateTimePicker(
                  name: 'birthDate',
                  initialValue: cattle?.birthDate,
                  decoration: const InputDecoration(
                    labelText: 'Birth Date',
                    prefixIcon: Icon(Icons.calendar_month_outlined),
                  ),
                  inputType: InputType.date,
                  validator: FormBuilderValidators.required(),
                ),
              ),
            ),
            SizedBox(height: Theme.of(context).extension<AppSpacing>()!.medium),

            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: FormBuilderDateTimePicker(
                  name: 'healthCheck',
                  initialValue: cattle?.healthCheck,
                  decoration: const InputDecoration(
                    labelText: 'Last Health Check',
                    prefixIcon: Icon(Icons.calendar_month_outlined),
                  ),
                  inputType: InputType.date,
                  validator: FormBuilderValidators.required(),
                ),
              ),
            ),

            const Divider(height: 32),
            Text(
              "Overview (optional)",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: Theme.of(context).extension<AppSpacing>()!.medium),

            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: FormBuilderTextField(
                  name: 'overview.description',
                  maxLines: 3,
                  initialValue: _singleCattle?.overview?.description ?? '',
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
              ),
            ),
            SizedBox(height: Theme.of(context).extension<AppSpacing>()!.medium),

            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,

                child: FormBuilderTextField(
                  name: 'overview.weight',
                  initialValue: cattle?.overview?.weight?.toString() ?? '',
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.balance_outlined),
                    labelText: 'Weight (kg)',
                  ),
                  validator: FormBuilderValidators.numeric(),
                ),
              ),
            ),
            SizedBox(height: Theme.of(context).extension<AppSpacing>()!.medium),

            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,

                child: FormBuilderTextField(
                  name: 'overview.height',
                  initialValue: cattle?.overview?.height?.toString() ?? '',
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.straighten_outlined),
                    labelText: 'Height (cm)',
                  ),
                  validator: FormBuilderValidators.numeric(),
                ),
              ),
            ),
            SizedBox(height: Theme.of(context).extension<AppSpacing>()!.medium),

            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,

                child: FormBuilderTextField(
                  name: 'overview.diet',
                  maxLines: 3,
                  initialValue: cattle?.overview?.diet ?? '',
                  decoration: const InputDecoration(labelText: 'Diet'),
                ),
              ),
            ),

            const Divider(height: 32),
            Text(
              "Breeding Status (optional)",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: Theme.of(context).extension<AppSpacing>()!.medium),

            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,

                child: FormBuilderSwitch(
                  name: 'breedingStatus.pragnancyStatus',
                  title: const Text("Pregnancy Status"),
                  initialValue:
                      cattle?.breedingStatus?.pragnancyStatus ?? false,
                ),
              ),
            ),
            SizedBox(height: Theme.of(context).extension<AppSpacing>()!.medium),

            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,

                child: FormBuilderDateTimePicker(
                  name: 'breedingStatus.lastCalving',
                  initialValue:
                      (cattle?.breedingStatus?.lastCalving != null &&
                              cattle!.breedingStatus!.lastCalving ==
                                  DateTime(1, 1, 1))
                          ? null
                          : cattle?.breedingStatus?.lastCalving,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.calendar_month_outlined),
                    labelText: 'Last Calving Date',
                  ),
                  inputType: InputType.date,
                ),
              ),
            ),
            SizedBox(height: Theme.of(context).extension<AppSpacing>()!.medium),

            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,

                child: FormBuilderTextField(
                  name: 'breedingStatus.numberOfCalves',
                  initialValue:
                      cattle?.breedingStatus?.numberOfCalves?.toString() ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Number of Calves',
                  ),
                  validator: FormBuilderValidators.numeric(),
                ),
              ),
            ),

            SizedBox(height: Theme.of(context).extension<AppSpacing>()!.medium),

            SizedBox(
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
                            final rawValues = Map<String, dynamic>.from(
                              _formKey.currentState!.value,
                            );
                            rawValues.remove('image');
                            rawValues.remove('milkCarton');

                            final body = <String, dynamic>{};

                            for (var entry in rawValues.entries) {
                              if (!entry.key.contains('.')) {
                                body[entry.key] = entry.value;
                              }
                            }

                            final overview = {
                              "description": rawValues["overview.description"],
                              "weight":
                                  (rawValues["overview.weight"] != null &&
                                          rawValues["overview.weight"]
                                              .toString()
                                              .isNotEmpty)
                                      ? double.tryParse(
                                        rawValues["overview.weight"].toString(),
                                      )
                                      : null,
                              "height":
                                  (rawValues["overview.height"] != null &&
                                          rawValues["overview.height"]
                                              .toString()
                                              .isNotEmpty)
                                      ? double.tryParse(
                                        rawValues["overview.height"].toString(),
                                      )
                                      : null,
                              "diet": rawValues["overview.diet"],
                            }..removeWhere((_, v) => v == null || v == "");

                            if (overview.isNotEmpty) {
                              body["overview"] = overview;
                            }

                            final breedingStatus = {
                              "pragnancyStatus":
                                  rawValues["breedingStatus.pragnancyStatus"],
                              "lastCalving": toIso(
                                rawValues["breedingStatus.lastCalving"],
                              ),
                              "numberOfCalves":
                                  rawValues["breedingStatus.numberOfCalves"] !=
                                          ""
                                      ? int.tryParse(
                                        rawValues["breedingStatus.numberOfCalves"],
                                      )
                                      : null,
                            }..removeWhere((_, v) => v == null || v == "");

                            body["birthDate"] = toIso(rawValues["birthDate"]);
                            body["healthCheck"] = toIso(
                              rawValues["healthCheck"],
                            );

                            if (breedingStatus.isNotEmpty) {
                              body["breedingStatus"] = breedingStatus;
                            }

                            if (_uploadedImageFile != null) {
                              final uploadedUrl = await _fileProvider
                                  .uploadFile(
                                    FileModel(
                                      file: _uploadedImageFile!,
                                      subfolder: 'Images/Cattle',
                                    ),
                                  );
                              body['imageUrl'] = uploadedUrl;
                            } else {
                              body['imageUrl'] = cattle?.imageUrl;
                            }

                            if (_uploadedPdfFile != null) {
                              final uploadedPdfUrl = await _fileProvider
                                  .uploadFile(
                                    FileModel(
                                      file: _uploadedPdfFile!,
                                      subfolder: 'Documents/MilkCartons',
                                    ),
                                  );
                              body['milkCartonUrl'] = uploadedPdfUrl;
                            } else {
                              body['milkCartonUrl'] = cattle?.milkCartonUrl;
                            }

                            if (isEdit) {
                              await showCustomDialog(
                                context: context,
                                title: "Update Cattle",
                                message:
                                    "Are you sure you want to update '${cattle.name}'?",
                                onConfirm: () async {
                                  await _cattleProvider.update(cattle.id, body);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Cattle Updated successfully",
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
                                title: "Add Cattle",
                                message:
                                    "Are you sure you want to add '${body['name']}'?",
                                onConfirm: () async {
                                  await _cattleProvider.create(body);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Cattle Added successfully",
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

                            await _fetchCattle();
                            widget.closeForm();
                          }
                        },
                        child: Text(isEdit ? 'Update Cattle' : 'Create Cattle'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCattleView({required Cattle cattle}) {
    final overview = cattle.overview;
    final breeding = cattle.breedingStatus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (cattle.imageUrl != null && cattle.imageUrl!.isNotEmpty)
          FilePickerWithPreview(imageUrl: cattle.imageUrl,hasButton: false,),
        const SizedBox(height: 16),

        if (cattle.milkCartonUrl != null && cattle.milkCartonUrl!.isNotEmpty)
          Center(
            child: ElevatedButton.icon(
              onPressed: () async {
                await _cattleProvider.downloadPdfToUserLocation(
                  cattle.milkCartonUrl,
                );
              },
              icon: const Icon(Icons.picture_as_pdf),
              label: Text('Download milk carton for ${cattle.name}'),
            ),
          ),
        const SizedBox(height: 24),

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
                buildInfoRow('Name', cattle.name),
                buildInfoRow('Tag Number', cattle.tagNumber),
                buildInfoRow('Breed', cattle.breedOfCattle),
                buildInfoRow('Category', cattle.cattleCategory?.name),
                buildInfoRow('Liters per Day', "${cattle.litersPerDay} L"),
                buildInfoRow('Monthly Value', "${cattle.monthlyValue} BAM"),
                buildInfoRow(
                  'Birth Date',
                  cattle.birthDate != null
                      ? DateFormat.yMMMd().format(cattle.birthDate!)
                      : '-',
                ),
                buildInfoRow(
                  'Last Health Check',
                  cattle.healthCheck != null
                      ? DateFormat.yMMMd().format(cattle.healthCheck!)
                      : '-',
                ),
              ],
            ),
          ),
        ),

        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overview',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                buildInfoRow('Description', overview?.description),
                buildInfoRow('Weight (kg)', overview?.weight?.toString()),
                buildInfoRow('Height (cm)', overview?.height?.toString()),
                buildInfoRow('Diet', overview?.diet),
              ],
            ),
          ),
        ),

        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Breeding Status',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                buildInfoRow(
                  'Pregnancy Status',
                  breeding?.pragnancyStatus == true ? 'Yes' : 'No',
                ),
                buildInfoRow(
                  'Last Calving',
                  (breeding?.lastCalving != null &&
                          breeding!.lastCalving.isAfter(DateTime(1, 1, 1)))
                      ? DateFormat.yMMMd().format(breeding!.lastCalving)
                      : '-',
                ),

                buildInfoRow(
                  'Number of Calves',
                  breeding?.numberOfCalves?.toString() ?? '-',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }



  Container _buildCattle(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        border: Border.all(color: Theme.of(context).colorScheme.tertiary),
      ),
      padding: const EdgeInsets.only(left: 15, bottom: 15),
      child: MasterWidget(
        title: 'Cattle List',
        subtitle: 'All registered cattle',
        titleStyle: Theme.of(context).textTheme.headlineMedium,
        subtitleStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.tertiary,
        ),
        body: _cattleProvider.isLoading? const Center(child: CircularProgressIndicator()) :
        _cattle.isEmpty? NoDataWidget() : SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: DataTable(
              columnSpacing: 50,
              dataRowHeight: 40,
              headingTextStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Theme.of(context).colorScheme.tertiary,
              ),
              dataTextStyle: Theme.of(context).textTheme.bodyLarge,
              border: TableBorder(
                horizontalInside: BorderSide(
                  color: Theme.of(context).colorScheme.tertiary,
                  width: 2,
                ),
              ),
              columns: const [
                DataColumn(label: Text('Tag Number')),
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Type')),
                DataColumn(label: Text('Age')),
                DataColumn(label: Text('Milk production')),
                DataColumn(label: Text('Revenue')),
                DataColumn(label: Text('Actions')),
              ],
              rows:
                  _cattle.map((cattle) {
                    return DataRow(
                      cells: [
                        DataCell(
                          SizedBox(
                            width: 70,
                            child: Text(
                              "#${cattle.tagNumber}",
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width:50,
                            child: Text(cattle.name, overflow: TextOverflow.ellipsis)
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 90,
                            child: Text(
                              "${cattle.cattleCategory?.name ?? 'Undefined'}",
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(SizedBox(width: 80,child: Text("${cattle.age} years",overflow: TextOverflow.ellipsis,))),
                        DataCell(
                          SizedBox(
                            width: 100,
                            child: Text(
                              "${formatDouble(cattle.litersPerDay)} L/day",
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 90,
                            child: Text(
                              "${formatDouble(cattle.monthlyValue)} BAM",
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  child: leadingIcon(
                                    'assets/icons/eye.png',
                                    width: 24,
                                    height: 24,
                                  ),
                                  onTap: () async {
                                    await _fetchById(cattle.id);

                                    widget.openForm(
                                      SingleChildScrollView(
                                        child: MasterWidget(
                                          title: cattle.name,
                                          subtitle:
                                              '${cattle.breedOfCattle?.isNotEmpty == true ? '${cattle.breedOfCattle} - ' : ''} ${cattle.age} years old',
                                          headerActions: Center(
                                            child: ElevatedButton(
                                              onPressed:
                                                  () => widget.closeForm(),

                                              child: const Text('X'),
                                            ),
                                          ),
                                          body: _buildCattleView(
                                            cattle: _singleCattle!,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 5),
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  child: leadingIcon(
                                    'assets/icons/pentool_transparent_icon.png',
                                    width: 24,
                                    height: 24,
                                  ),
                                  onTap: () async {
                                    await _fetchById(cattle.id);
                                    widget.openForm(
                                      SingleChildScrollView(
                                        child: MasterWidget(
                                          title: 'Edit Cattle',
                                          subtitle: cattle.name,
                                          body: _buildCattleForm(
                                            cattle: _singleCattle,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 5),
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  child: leadingIcon(
                                    'assets/icons/trash_transparent_icon.png',
                                    width: 24,
                                    height: 24,
                                  ),
                                  onTap: () async {
                                    await showCustomDialog(
                                      context: context,
                                      title: "Delete Cattle",
                                      message:
                                          "Are you sure you want to delete '${cattle.name}'?",
                                      onConfirm: () async {
                                        await _deleteCattle(cattle);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Cattle Deleted successfully",
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
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

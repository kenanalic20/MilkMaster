import 'dart:math';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:milkmaster_desktop/main.dart';
import 'package:milkmaster_desktop/models/cattle_category_model.dart';
import 'package:milkmaster_desktop/models/cattle_model.dart';
import 'package:milkmaster_desktop/providers/cattle_category_provider.dart';
import 'package:milkmaster_desktop/providers/cattle_provider.dart';
import 'package:milkmaster_desktop/utils/widget_helpers.dart';
import 'package:milkmaster_desktop/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class CattleScreen extends StatefulWidget {
  const CattleScreen({super.key});

  @override
  State<CattleScreen> createState() => _CattleScreenState();
}

class _CattleScreenState extends State<CattleScreen> {
  late CattleProvider _cattleProvider;
  late CattleCategoryProvider _cattleCategoryProvider;
  List<Cattle> _cattle = [];
  List<CattleCategory> _categories = [];
  int _pageSize = 8;
  int _totalCount = 0;
  int _currentPage = 1;
  double _totalLiters = 0;
  double _totalRevenue = 0; 
  int? _selectedCategory;
  String? _selectedSort;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cattleProvider = context.read<CattleProvider>();
    _cattleCategoryProvider = context.read<CattleCategoryProvider>();
    _fetchCategories();
    _fetchCattle(extraQuery: {"pageSize": _pageSize});
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
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearch(),
        _buildCattleStats(),
        _cattleProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildCattle(context),
        _buildPagination(),
      ],
    );
  }

  Widget _buildCattleStats() {
    return Padding(
      padding: EdgeInsets.only(bottom: Theme.of(context).extension<AppSpacing>()!.large),
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
                    style: BorderStyle.solid
                  )
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Total Cattle",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: Theme.of(context).extension<AppSpacing>()!.small,
                        children: [
                          leadingIcon('assets/icons/cow_icon_yellow.png'),
                          Text(
                            _totalCount.toString(),
                             style: Theme.of(context).textTheme.headlineMedium
                          ),
                        ],
                      )
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
                    style: BorderStyle.solid
                  )
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Milk Production",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: Theme.of(context).extension<AppSpacing>()!.small,

                        children: [
                          leadingIcon('assets/icons/milk_icon_yellow.png'),
                          Text(
                            "${formatDouble(_totalLiters)} L",
                             style: Theme.of(context).textTheme.headlineMedium
                          ),
                        ],
                      )
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
                    style: BorderStyle.solid
                  )
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      Text(
                        "Total Revenue",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: Theme.of(context).extension<AppSpacing>()!.small,
                        children: [
                          Text(
                            formatDouble(_totalRevenue),
                             style: Theme.of(context).textTheme.headlineMedium
                          ),
                          Text(
                            "BAM",
                             style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Theme.of(context).colorScheme.secondary
                             )
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              )
          
            ]
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
      {'label': 'Revenue Desc', 'value': 'revenue_desc'},
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
                    'cattleCategoryId': _selectedCategory ?? 1,
                    'orderBy': _selectedSort ?? '',
                    'pageSize': _pageSize,
                    'pageNumber': _currentPage,
                  },
                );
              },
            ),
          ),

          SizedBox(width: Theme.of(context).extension<AppSpacing>()!.medium),

          SizedBox(
            width: 140,
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
                  print(_selectedCategory);
                  await _fetchCattle(
                    extraQuery: {
                      'search': _searchController.text,
                      'cattleCategoryId': _selectedCategory ?? 1,
                      'orderBy': _selectedSort ?? '',
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
                  setState(() {
                    _selectedSort = value;
                    _currentPage = 1;
                  });

                  await _fetchCattle(
                    extraQuery: {
                      'search': _searchController.text,
                      'cattleCategoryId': _selectedCategory ?? 1,
                      'orderBy': _selectedSort ?? '',
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
        ],
      ),
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
        body: SingleChildScrollView(
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
              columnSpacing: 63,
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
                          Text(
                            "#${cattle.tagNumber}",
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DataCell(
                          Text(
                            cattle.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DataCell(Text("${cattle.cattleCategory.name}",overflow: TextOverflow.ellipsis,)),
                        DataCell(Text("${cattle.age} years")),
                        DataCell(
                          Text(
                            "${formatDouble(cattle.litersPerDay)} L/day",
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DataCell(
                          Text("${formatDouble(cattle.monthlyValue)} BAM",
                          overflow: TextOverflow.ellipsis,),
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
                                  onTap: () {},
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
                                  onTap: () {},
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
                                      title: "Delete Order",
                                      message:
                                          "Are you sure you want to delete '${cattle.name}'?",
                                      onConfirm: () async {
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

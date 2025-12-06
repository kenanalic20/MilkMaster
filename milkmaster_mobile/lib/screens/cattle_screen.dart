import 'package:flutter/material.dart';
import 'package:milkmaster_mobile/main.dart';
import 'package:milkmaster_mobile/models/cattle_category_model.dart';
import 'package:milkmaster_mobile/models/cattle_model.dart';
import 'package:milkmaster_mobile/providers/cattle_category_provider.dart';
import 'package:milkmaster_mobile/providers/cattle_provider.dart';
import 'package:milkmaster_mobile/screens/cattle_details_screen.dart';
import 'package:milkmaster_mobile/utils/widget_helpers.dart';
import 'package:provider/provider.dart';

class CattleScreen extends StatefulWidget {
  final int? selectedCattleCategory;
  final void Function(int productId)? onNavigateToProductDetails;
  final void Function(int cattleId)? onNavigateToCattleDetails;
  
  const CattleScreen({
    super.key,
    this.selectedCattleCategory,
    this.onNavigateToProductDetails,
    this.onNavigateToCattleDetails,
  });

  @override
  State<CattleScreen> createState() => _CattleScreenState();
}

class _CattleScreenState extends State<CattleScreen> {
  late CattleProvider _cattleProvider;
  late CattleCategoryProvider _cattleCategoryProvider;
  final TextEditingController _searchController = TextEditingController();
  List<Cattle> _cattle = [];
  List<CattleCategory> _cattleCategories = [];
  int _currentPage = 1;
  int _pageSize = 8;
  int _totalCount = 0;
  int? _selectedCattleCategory;
  bool _sortDescending = true;

  @override
  void initState() {
    super.initState();
    _cattleProvider = context.read<CattleProvider>();
    _cattleCategoryProvider = context.read<CattleCategoryProvider>();
    _selectedCattleCategory = widget.selectedCattleCategory;
    _fetchCattle();
    _fetchCattleCategories();
  }

  Future<void> _fetchCattleCategories() async {
    final result = await _cattleCategoryProvider.fetchAll();
    if (mounted) {
      setState(() {
        _cattleCategories = result.items;
      });
    }
  }

  @override
  void didUpdateWidget(CattleScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCattleCategory != oldWidget.selectedCattleCategory) {
      setState(() {
        _selectedCattleCategory = widget.selectedCattleCategory;
        _currentPage = 1;
      });
      _fetchCattle();
    }
  }

  Future<void> _fetchCattle({int? page, Map<String, dynamic>? extraQuery}) async {
    try {
      final queryParams = {
        "pageSize": _pageSize,
        "pageNumber": page ?? _currentPage,
        if (_selectedCattleCategory != null) 
          'cattleCategoryId': _selectedCattleCategory,
        if (extraQuery != null) ...extraQuery,
      };

      final result = await _cattleProvider.fetchAll(queryParams: queryParams);

      if (mounted) {
        setState(() {
          _cattle = result.items;
          _totalCount = result.totalCount;
        });
      }
    } catch (e) {
      print("Error fetching cattle: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: Theme.of(context).extension<AppSpacing>()?.medium),
          _buildSearchAndFilter(),
          Expanded(child: _buildCattleList()),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 35,
            child: TextField(
              style: Theme.of(context).textTheme.bodyMedium,
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search cattle...",
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.tertiary,
                  size: 20,
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: const Color.fromRGBO(229, 229, 229, 1),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              ),
              onChanged: (value) async {
                setState(() {
                  _currentPage = 1;
                });
                await _fetchCattle(
                  extraQuery: {
                    'search': value,
                    'sortDescending': _sortDescending,
                  },
                );
              },
            ),
          ),
          SizedBox(height: Theme.of(context).extension<AppSpacing>()?.medium),
          
         
          if (_cattleCategories.isNotEmpty)
            SizedBox(
              height: 30,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _cattleCategories.length,
                itemBuilder: (context, index) {
                  final category = _cattleCategories[index];
                  final isSelected = _selectedCattleCategory == category.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category.name.toLowerCase()),
                      selected: isSelected,
                      onSelected: (selected) async {
                        setState(() {
                          _selectedCattleCategory = selected ? category.id : null;
                          _currentPage = 1;
                        });
                        await _fetchCattle(
                          extraQuery: {
                            'name': _searchController.text,
                            'sortDescending': _sortDescending,
                          },
                        );
                      },
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      selectedColor: Colors.white,
                      labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.black
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isSelected 
                            ? Colors.black26 
                            : Theme.of(context).colorScheme.primary,
                          width: 1,
                        ),
                      ),
                      showCheckmark: false,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    ),
                  );
                },
              ),
            ),
          SizedBox(height: Theme.of(context).extension<AppSpacing>()?.medium),
          
          
        ],
      ),
    );
  }

  Widget _buildCattleList() {
    if (_cattleProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_cattle.isEmpty) {
      return const NoDataWidget();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        children: [
          SizedBox(height: Theme.of(context).extension<AppSpacing>()?.medium),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_totalCount ${_totalCount == 1 ? 'cattle found' : 'cattles found'}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
             
            ],
          ),
          SizedBox(height: Theme.of(context).extension<AppSpacing>()?.medium),
          Expanded(
            child: ListView.builder(
              itemCount: _cattle.length,
              itemBuilder: (context, index) {
                final cattle = _cattle[index];
                return _buildCattleCard(cattle);
              },
            ),
          ),
          PaginationWidget(
            currentPage: _currentPage,
            totalItems: _totalCount,
            pageSize: _pageSize,
            onPageChanged: (page) {
              setState(() {
                _currentPage = page;
              });
              _fetchCattle(
                page: page,
                extraQuery: {
                  'name': _searchController.text,
                  'sortDescending': _sortDescending,
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCattleCard(Cattle cattle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.network(
                  fixLocalhostUrl(cattle.imageUrl),
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(Icons.pets, size: 80),
                      ),
                ),
              ),
              if (cattle.cattleCategory != null)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      cattle.cattleCategory!.name.toLowerCase(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cattle.name,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                if (cattle.breedOfCattle != null || cattle.age > 0)
                  Row(
                    children: [
                      Text(
                        '${cattle.breedOfCattle ?? ''} ${cattle.breedOfCattle != null && cattle.age > 0 ? '-' : ''} ${cattle.age > 0 ? '${cattle.age} years old' : ''}',
                      ),
                    ],
                  ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Milk Production',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                          Text(
                            '${formatDouble(cattle.litersPerDay)} L/day',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Monthly Value',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                          Text(
                            '${formatDouble(cattle.monthlyValue)} BAM',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Theme.of(context).extension<AppSpacing>()?.small),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          if (widget.onNavigateToCattleDetails != null) {
                            widget.onNavigateToCattleDetails!(cattle.id);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CattleDetailsScreen(
                                  cattleId: cattle.id,
                                  onNavigateToProductDetails: widget.onNavigateToProductDetails,
                                ),
                              ),
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'View Details',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: Theme.of(context).extension<AppSpacing>()?.medium),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          if (cattle.milkCartonUrl != null && cattle.milkCartonUrl.isNotEmpty) {
                            final success = await _cattleProvider.downloadMilkCarton(
                              fixLocalhostUrl(cattle.milkCartonUrl),
                            );
                            
                            if (mounted) {
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Opening milk carton for ${cattle.name}'),
                                    backgroundColor: Theme.of(context).colorScheme.secondary,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Failed to open milk carton'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No milk carton available for this cattle'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Colors.black,
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Download Milk Card',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
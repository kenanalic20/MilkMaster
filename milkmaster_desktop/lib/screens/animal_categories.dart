import 'package:flutter/material.dart';
import 'package:milkmaster_desktop/models/cattle_category_model.dart';
import 'package:milkmaster_desktop/providers/cattle_category_provider.dart';
import 'package:milkmaster_desktop/utils/widget_helpers.dart';
import 'package:milkmaster_desktop/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class AnimalCategoriesScreen extends StatefulWidget {
  const AnimalCategoriesScreen({super.key});

  @override
  State<AnimalCategoriesScreen> createState() => _AnimalCategoriesScreenState();
}

class _AnimalCategoriesScreenState extends State<AnimalCategoriesScreen> {
  late CattleCategoryProvider _cattleCategoryProvider;
  List<CattleCategory> _cattleCategories = [];
  int? _hoveredCategoryId;
  bool _showForm = false;

  @override
  void initState() {
    super.initState();
    _cattleCategoryProvider = context.read<CattleCategoryProvider>();
    _fetchCattleCategories();
  }

  Future<void> _fetchCattleCategories() async {
    try {
      var fetchedItems = await _cattleCategoryProvider.fetchAll();
      if (mounted) {
        setState(() {
          _cattleCategories = fetchedItems;
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

  Widget _buildCattleCategories() {
    return MasterWidget(
      title: 'Animal Categories',
      subtitle: 'Manage your cattle categories',
      headerActions: Text('Cattle Categories Header Action'),
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
                onEnter:
                    (_) => setState(() => _hoveredCategoryId = category.id),
                onExit: (_) => setState(() => _hoveredCategoryId = null),
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
              onTap: (){
                // Open edit form
                print('Edit category: ${category.name}');
                setState(() {
                  _showForm = true;
                });
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

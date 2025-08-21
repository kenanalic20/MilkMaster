import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:milkmaster_desktop/models/orders_model.dart';
import 'package:milkmaster_desktop/providers/orders_provider.dart';
import 'package:milkmaster_desktop/utils/widget_helpers.dart';
import 'package:milkmaster_desktop/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late OrdersProvider _ordersProvider;
  List<Order> _orders = [];
  int _pageSize = 8;
  int _totalCount = 0;
  int _currentPage = 1;
  String? _selectedStatus = 'All';
  String? _selectedSort;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ordersProvider = context.read<OrdersProvider>();
    _fatchOrders(extraQuery: {"pageSize": _pageSize});
  }

  Future<void> _fatchOrders({
    int? page,
    Map<String, dynamic>? extraQuery,
  }) async {
    try {
      final queryParams = {
        "pageSize": _pageSize,
        "pageNumber": page ?? _currentPage,
        if (extraQuery != null) ...extraQuery,
      };

      final result = await _ordersProvider.fetchAll(queryParams: queryParams);

      if (mounted) {
        setState(() {
          _orders = result.items;
          _totalCount = result.totalCount;
        });
      }
    } catch (e) {
      print("Error fetching orders: $e");
    }
  }

  Future<void> _deleteOrder(order) async {
    await _ordersProvider.delete(order.id);
    await _fatchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearch(),
        _ordersProvider.isLoading
            ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: CircularProgressIndicator(),
              ),
            )
            : _buildOrders(context),
        _buildPagination(),
      ],
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
        await _fatchOrders(extraQuery: {"page": page, "pageSize": _pageSize});
      },
    );
  }

  Widget _buildSearch() {
    final orderStatuses = [
      'All',
      'Pending',
      'Processing',
      'Completed',
      'Cancelled',
    ];
    final sortOptions = [
      {'label': 'Date Asc', 'value': 'date_asc'},
      {'label': 'Date Desc', 'value': 'date_desc'},
      {'label': 'Total Asc', 'value': 'total_asc'},
      {'label': 'Total Desc', 'value': 'total_desc'},
      {'label': 'Items Count Asc', 'value': 'itemscount_asc'},
      {'label': 'Items Count Desc', 'value': 'itemscount_desc'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Row(
        children: [
          // Search bar
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search by Order Number or Customer",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) async {
                setState(() {
                  _currentPage = 1; // reset pagination
                });
                await _fatchOrders(
                  extraQuery: {
                    'search': value,
                    'orderStatus':
                        _selectedStatus == 'All' ? '' : _selectedStatus,
                    'orderBy': _selectedSort,
                    'pageSize': _pageSize,
                    'pageNumber': _currentPage,
                  },
                );
              },
            ),
          ),

          const SizedBox(width: 10),

          // Status Dropdown
          DropdownButton<String>(
            value: _selectedStatus ?? 'All',
            items:
                orderStatuses.map((status) {
                  return DropdownMenuItem(value: status, child: Text(status));
                }).toList(),
            onChanged: (value) async {
              setState(() {
                _selectedStatus = value;
                _currentPage = 1; // reset pagination
              });
              await _fatchOrders(
                extraQuery: {
                  'search': _searchController.text,
                  'orderStatus': value == 'All' ? '' : value,
                  'orderBy': _selectedSort,
                  'pageSize': _pageSize,
                  'pageNumber': _currentPage,
                },
              );
            },
            hint: const Text('Status'),
          ),

          const SizedBox(width: 10),

          // Sort Dropdown
          DropdownButton<String>(
            value: _selectedSort,
            items:
                sortOptions.map((option) {
                  return DropdownMenuItem(
                    value: option['value'],
                    child: Text(option['label']!),
                  );
                }).toList(),
            onChanged: (value) async {
              setState(() {
                _selectedSort = value;
                _currentPage = 1; // reset pagination
              });
              await _fatchOrders(
                extraQuery: {
                  'search': _searchController.text,
                  'orderStatus':
                      _selectedStatus == 'All' ? '' : _selectedStatus,
                  'orderBy': value,
                  'pageSize': _pageSize,
                  'pageNumber': _currentPage,
                },
              );
            },
            hint: const Text('Sort by'),
          ),
        ],
      ),
    );
  }

  Container _buildOrders(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.tertiary),
          left: BorderSide(color: Theme.of(context).colorScheme.tertiary),
          right: BorderSide(color: Theme.of(context).colorScheme.tertiary),
          bottom: BorderSide(color: Theme.of(context).colorScheme.tertiary),
        ),
      ),
      padding: EdgeInsets.only(left: 15, right: 15, bottom: 15),
      child: MasterWidget(
        titleStyle: Theme.of(context).textTheme.headlineMedium,
        title: 'Order List',
        subtitleStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.tertiary,
        ),
        subtitle: 'Latest customer orders',
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
              columnSpacing: 52,
              dataRowHeight: 45,
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
                DataColumn(label: Text('Order Number')),
                DataColumn(label: Text('Customer')),
                DataColumn(label: Text('Products')),
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Total')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Actions')),
              ],
              rows:
                  _orders.map((order) {
                    return DataRow(
                      cells: [
                        DataCell(Text(order.orderNumber)),
                        DataCell(Text(order.customer)),
                        DataCell(Text('${order.itemCount} items')),
                        DataCell(
                          Text(
                            DateFormat('dd/MM/yyyy').format(order.createdAt),
                          ),
                        ),
                        DataCell(
                          Text('${order.total.toStringAsPrecision(2)} BAM'),
                        ),
                        DataCell(
                          Text(
                            order.status!.name,
                            style: TextStyle(
                              color: hexToColor(order.status!.colorCode),
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
                                          "Are you sure you want to delete '${order.orderNumber}'?",
                                      onConfirm: () async {
                                        await _deleteOrder(order);
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

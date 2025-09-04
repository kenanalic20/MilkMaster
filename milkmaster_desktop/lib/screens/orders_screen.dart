import 'dart:math';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:milkmaster_desktop/main.dart';
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
  String? _selectedStatus;
  String? _selectedSort;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ordersProvider = context.read<OrdersProvider>();
    _fetchOrders(extraQuery: {"pageSize": _pageSize});
  }

  Future<void> _fetchOrders({
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

   Future<void> _fetchStatuses() async {
    
  }

  Future<void> _deleteOrder(order) async {
    await _ordersProvider.delete(order.id);
    await _fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearch(),
        _buildOrders(context),
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
        await _fetchOrders(extraQuery: {"page": page, "pageSize": _pageSize});
      },
    );
  }

  Widget _buildSearch() {
    final orderStatuses = ['Pending', 'Processing', 'Completed', 'Cancelled'];

    final sortOptions = [
      {'label': 'Date Asc', 'value': 'date_asc'},
      {'label': 'Date Desc', 'value': 'date_desc'},
      {'label': 'Total Asc', 'value': 'total_asc'},
      {'label': 'Total Desc', 'value': 'total_desc'},
      {'label': 'Items Asc', 'value': 'itemscount_asc'},
      {'label': 'Items Desc', 'value': 'itemscount_desc'},
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
                prefixIcon: Icon(Icons.search,color: Theme.of(context).colorScheme.tertiary),
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
                await _fetchOrders(
                  extraQuery: {
                    'search': value,
                    'orderStatus': _selectedStatus ?? '',
                    'orderBy': _selectedSort ?? '',
                    'pageSize': _pageSize,
                    'pageNumber': _currentPage,
                  },
                );
              },
            ),
          ),

          const SizedBox(width: 10),

          SizedBox(
            width: 120,
            child: DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                value: _selectedStatus,
                items:
                    orderStatuses.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                onChanged: (value) async {
                  setState(() {
                    _selectedStatus = value;
                  });
                  await _fetchOrders(
                    extraQuery: {
                      'search': _searchController.text,
                      'orderStatus': _selectedStatus ?? '',
                      'orderBy': _selectedSort ?? '',
                      'pageSize': _pageSize,
                      'pageNumber': _currentPage,
                    },
                  );
                },
                 hint: Text(
                  'Status',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium,
                ),
                style: Theme.of(context).textTheme.bodyMedium,
                buttonStyleData: ButtonStyleData(
                  height: 45,
                  width: 100,
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

          const SizedBox(width: 10),

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

                  await _fetchOrders(
                    extraQuery: {
                      'search': _searchController.text,
                      'orderStatus': _selectedStatus ?? '',
                      'orderBy': _selectedSort ?? '',
                      'pageSize': _pageSize,
                      'pageNumber': _currentPage,
                    },
                  );
                },
                hint: Text(
                  'Sort',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium,
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
      padding: EdgeInsets.only(left: 15, bottom: 15),
      child: MasterWidget(
        titleStyle: Theme.of(context).textTheme.headlineMedium,
        title: 'Order List',
        subtitleStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.tertiary,
        ),
        subtitle: 'Latest customer orders',
        body: _ordersProvider.isLoading? const Center(child: CircularProgressIndicator()) :
        _orders.isEmpty? NoDataWidget() : SingleChildScrollView(
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
                        DataCell(
                          Text(
                            order.orderNumber,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 120,
                            child: Text(
                              order.customer,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),

                        DataCell(Text('${order.itemCount} items')),
                        DataCell(
                          Text(
                            DateFormat('dd/MM/yyyy').format(order.createdAt),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DataCell(
                          Text(
                            '${order.total.toStringAsPrecision(2)} BAM',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DataCell(
                          Text(
                            order.status!.name,
                            style: TextStyle(
                              color: hexToColor(order.status!.colorCode),
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

import 'dart:math';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:milkmaster_desktop/main.dart';
import 'package:milkmaster_desktop/models/user_model.dart';
import 'package:milkmaster_desktop/providers/user_provider.dart';
import 'package:milkmaster_desktop/utils/widget_helpers.dart';
import 'package:milkmaster_desktop/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class CustomersScreen extends StatefulWidget {
  final void Function(Widget form) openForm;
  final void Function() closeForm;
  const CustomersScreen({
    super.key,
    required this.openForm,
    required this.closeForm,
  });

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  late UserProvider _userProvider;
  int _pageSize = 8;
  int _totalCount = 0;
  int _currentPage = 1;
  final TextEditingController _searchController = TextEditingController();
  final _formKey = GlobalKey<FormBuilderState>();
  List<User> _customers = [];
  String? _selectedSort;

  @override
  void initState() {
    super.initState();
    _userProvider = context.read<UserProvider>();
    _fetchCustomers(extraQuery: {"pageSize": _pageSize});
  }

  Future<void> _fetchCustomers({
    int? page,
    Map<String, dynamic>? extraQuery,
  }) async {
    try {
      final queryParams = {
        "pageSize": _pageSize,
        "pageNumber": page ?? _currentPage,
        if (extraQuery != null) ...extraQuery,
      };

      final result = await _userProvider.fetchAll(queryParams: queryParams);

      if (mounted) {
        setState(() {
          _customers = result.items;
        });
      }
    } catch (e) {
      print("Error fetching orders: $e");
    }
  }

  Future<void> _deleteCustomer(customer) async {
    await _userProvider.delete(customer.id);
    await _fetchCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [_buildSearch(), _buildCustomers(context), _buildPagination()],
    );
  }

  Container _buildCustomers(BuildContext context) {
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
        title: 'Customer List',
        subtitleStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.tertiary,
        ),
        subtitle: 'Latest customers',
        body:
            _userProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _customers.isEmpty
                ? NoDataWidget()
                : SingleChildScrollView(
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
                      columnSpacing: 45,
                      dataRowHeight: 40,
                      headingTextStyle: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.copyWith(
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
                        DataColumn(label: Text('Customer')),
                        DataColumn(label: Text('Street')),
                        DataColumn(label: Text('Orders')),
                        DataColumn(label: Text('Last Order')),
                        DataColumn(label: Text('Phone')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows:
                          _customers.map((customer) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  SizedBox(
                                    width: 90,
                                    child: Text(
                                      'Kenan Alic',
                                      // customer.customerName != null &&
                                      //         customer.customerName!.isNotEmpty
                                      //     ? customer.customerName!
                                      //     : (customer.userName != null &&
                                      //             customer.userName!.isNotEmpty
                                      //         ? customer.userName!
                                      //         : '-'),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 200,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_outlined,
                                          size: 24,
                                        ),
                                        SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            customer.street ?? 'Ulica Bosanska',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                DataCell(Text(customer.orderCount.toString())),
                                DataCell(
                                  SizedBox(
                                    width: 100,
                                    child: Text(
                                      customer.lastOrderDate != null
                                          ? DateFormat(
                                            'dd/MM/yyyy',
                                          ).format(customer.lastOrderDate!)
                                          : 'No orders',
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 170,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.phone, // phone icon
                                          size: 24,
                                        ),
                                        SizedBox(
                                          width: 4,
                                        ), 
                                        Expanded(
                                          child: Text(
                                            customer.phoneNumber ??
                                                '+387 00 000 000', // placeholder
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
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
                                            // await _fetchSingleOrder(order.id);
                                            // widget.openForm(
                                            //   SingleChildScrollView(
                                            //     child: MasterWidget(
                                            //       title:
                                            //           'Order: ${order.orderNumber}',
                                            //       subtitle: '',
                                            //       headerActions: Center(
                                            //         child: ElevatedButton(
                                            //           onPressed:
                                            //               () =>
                                            //                   widget
                                            //                       .closeForm(),
                                            //           child: const Text('X'),
                                            //         ),
                                            //       ),
                                            //       body: _buildOrderView(
                                            //         _singleOrder!,
                                            //       ),
                                            //     ),
                                            //   ),
                                            // );
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
                                            widget.openForm(
                                              SingleChildScrollView(
                                                child: MasterWidget(
                                                  title: 'Update order status',
                                                  subtitle: '',
                                                  body: Text(
                                                    'test',
                                                  ), //_buildOrderForm(order),
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
                                              title: "Delete Customer",
                                              message:
                                                  "Are you sure you want to delete '${customer.userName}'?",
                                              onConfirm: () async {
                                                await _deleteCustomer(customer);
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

  Widget _buildPagination() {
    return PaginationWidget(
      currentPage: _currentPage,
      totalItems: _totalCount,
      pageSize: _pageSize,
      onPageChanged: (page) async {
        setState(() {
          _currentPage = page;
        });
        await _fetchCustomers(
          extraQuery: {"page": page, "pageSize": _pageSize},
        );
      },
    );
  }

  Widget _buildSearch() {
    final sortOptions = [
      {'label': 'Date Asc', 'value': 'date_asc'},
      {'label': 'Date Desc', 'value': 'date_desc'},
      {'label': 'Order Asc', 'value': 'order_asc'},
      {'label': 'Order Desc', 'value': 'order_desc'},
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
                await _fetchCustomers(
                  extraQuery: {
                    'search': value,
                    'pageSize': _pageSize,
                    'pageNumber': _currentPage,
                  },
                );
              },
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

                  await _fetchCustomers(
                    extraQuery: {
                      'search': _searchController.text,
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
}

import 'dart:math';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:milkmaster_desktop/main.dart';
import 'package:milkmaster_desktop/models/order_items_model.dart';
import 'package:milkmaster_desktop/models/order_status_model.dart';
import 'package:milkmaster_desktop/models/orders_model.dart';
import 'package:milkmaster_desktop/providers/order_status_provider.dart';
import 'package:milkmaster_desktop/providers/orders_provider.dart';
import 'package:milkmaster_desktop/utils/widget_helpers.dart';
import 'package:milkmaster_desktop/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class OrdersScreen extends StatefulWidget {
  final void Function(Widget form) openForm;
  final void Function() closeForm;

  const OrdersScreen({
    super.key,
    required this.openForm,
    required this.closeForm,
  });

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late OrdersProvider _ordersProvider;
  late OrderStatusProvider _orderStatusProvider;
  List<Order> _orders = [];
  List<OrderStatus> _orderStatus = [];
  Order? _singleOrder;
  int _pageSize = 8;
  int _totalCount = 0;
  int _currentPage = 1;
  String? _selectedStatus;
  String? _selectedSort;
  final TextEditingController _searchController = TextEditingController();
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
    _ordersProvider = context.read<OrdersProvider>();
    _orderStatusProvider = context.read<OrderStatusProvider>();
    _fetchOrders(extraQuery: {"pageSize": _pageSize});
    _fetchStatuses();
  }

  Future<void> _fetchSingleOrder(int id) async {
    final result = await _ordersProvider.getById(id);
    if (mounted) {
      setState(() {
        _singleOrder = result;
      });
    }
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
    final result = await _orderStatusProvider.fetchAll();
    if (mounted) {
      setState(() {
        _orderStatus = result.items;
      });
    }
  }

  Future<void> _deleteOrder(order) async {
    await _ordersProvider.delete(order.id);
    await _fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [_buildSearch(), _buildOrders(context), _buildPagination()],
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

  FormBuilder _buildOrderForm(Order order) {
    return FormBuilder(
      key: _formKey,
      child: Column(
        children: [
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: FormBuilderDropdown<int>(
                name: 'statusId',
                decoration: const InputDecoration(
                  labelText: 'Order Status',
                  border: OutlineInputBorder(),
                ),
                initialValue: order.status?.id,
                items:
                    _orderStatus
                        .map(
                          (status) => DropdownMenuItem<int>(
                            value: status.id,
                            child: Text(status.name),
                          ),
                        )
                        .toList(),
                validator: FormBuilderValidators.required(),
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
                  onPressed: () {
                    widget.closeForm();
                  },
                  child: const Text('Cancle'),
                ),
                const SizedBox(width: 16),
                Builder(
                  builder: (context) {
                    return ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState?.saveAndValidate() ?? false) {
                          final formData = _formKey.currentState!.value;
                          await showCustomDialog(
                            context: context,
                            title: "Update Order ${order.orderNumber}",
                            message:
                                "Are you sure you want to update '${order.orderNumber}'?",
                            onConfirm: () async {
                              await _ordersProvider.update(order.id, formData);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Order Updated successfully",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  backgroundColor:
                                      Theme.of(context).colorScheme.secondary,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              widget.closeForm();
                            },
                          );
                        }
                      },
                      child: const Text('Update Order'),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
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
                    _orderStatus.map((status) {
                      return DropdownMenuItem(
                        value: status.name,
                        child: Text(status.name),
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
                  style: Theme.of(context).textTheme.bodyMedium,
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

  Widget _buildOrderView(Order order) {
    final status = order.status;
    final items = order.items as List<OrderItem>;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Info',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                buildInfoRow('Order Number', order.orderNumber),
                buildInfoRow(
                  'Created At',
                  order.createdAt != null
                      ? DateFormat.yMMMd().format(order.createdAt)
                      : '-',
                ),
                buildInfoRow('Customer', order.customer),
                buildInfoRow('Email', order.email),
                buildInfoRow('Phone', order.phoneNumber),
                buildInfoRow('Total', "${formatDouble(order.total)} BAM"),
                buildInfoRow('Item Count', order.itemCount.toString()),
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
                Text('Status', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      status?.name ?? '-',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Color(
                          int.parse(
                            status?.colorCode.replaceFirst('#', '0xFF') ??
                                '0xFF9CA3AF',
                          ),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status?.name ?? '-',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
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
                Text('Items', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                ...items.map((item) {
                  return Column(
                    children: [
                      buildInfoRow('Product', item.productTitle),
                      buildInfoRow('Quantity', item.quantity.toString()),
                      buildInfoRow('Unit Size', item.unitSize.toString()),
                      buildInfoRow(
                        'Price per Unit',
                        "${formatDouble(item.pricePerUnit)}",
                      ),
                      buildInfoRow(
                        'Total Price',
                        "${formatDouble(item.totalPrice)}",
                      ),
                      const Divider(),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ],
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
        body:
            _ordersProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _orders.isEmpty
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
                      columnSpacing: 35,
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
                                  SizedBox(
                                    width: 90,
                                    child: Text(
                                      order.orderNumber,
                                      overflow: TextOverflow.ellipsis,
                                    ),
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
                                  SizedBox(
                                    width: 100,
                                    child: Text(
                                      DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(order.createdAt),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 100,
                                    child: Text(
                                      '${formatDouble(order.total)} BAM',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 120,
                                    child: Text(
                                      order.status!.name,
                                      style: TextStyle(
                                        color: hexToColor(
                                          order.status!.colorCode,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
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
                                            'assets/icons/Eye.png',
                                            width: 24,
                                            height: 24,
                                          ),
                                          onTap: () async {
                                            await _fetchSingleOrder(order.id);
                                            widget.openForm(
                                              SingleChildScrollView(
                                                child: MasterWidget(
                                                  title:
                                                      'Order: ${order.orderNumber}',
                                                  subtitle: '',
                                                  body: _buildOrderView(
                                                    _singleOrder!,
                                                  ),
                                                  onClose: widget.closeForm,
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
                                            widget.openForm(
                                              SingleChildScrollView(
                                                child: MasterWidget(
                                                  title: 'Update order status',
                                                  subtitle: '',
                                                  body: _buildOrderForm(order),
                                                  onClose: widget.closeForm,
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
                                              title: "Delete Order",
                                              message:
                                                  "Are you sure you want to delete '${order.orderNumber}'?",
                                              onConfirm: () async {
                                                await _deleteOrder(order);
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      "Order Deleted successfully",
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    backgroundColor:
                                                        Theme.of(
                                                          context,
                                                        ).colorScheme.secondary,
                                                    duration: Duration(
                                                      seconds: 2,
                                                    ),
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

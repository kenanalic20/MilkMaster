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

  @override
  void initState() {
    super.initState();
    _ordersProvider = context.read<OrdersProvider>();
    _fatchOrders();
  }

  Future<void> _fatchOrders() async {
    try {
      var fatchedItems = await _ordersProvider.fetchAll();
      if (mounted) {
        setState(() {
          _orders = fatchedItems;
        });
      }
    } catch (e) {
      print("Error fetching orders: $e");
    }
  }

  Future<void> loadData() async {
    try {
      await _ordersProvider.fetchAll();
    } catch (e) {
      print("Error loading orders: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildOrders(context);
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
            columnSpacing: 53,
            dataRowHeight: 45,
            headingTextStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Theme.of(context).colorScheme.tertiary
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
                      DataCell(Text(DateFormat('dd/MM/yyyy').format(order.createdAt))),
                      DataCell(Text('${order.total.toStringAsFixed(2)} BAM')),
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
                                    onConfirm: () async {},
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

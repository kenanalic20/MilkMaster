import 'package:flutter/material.dart';
import 'package:milkmaster_desktop/providers/orders_provider.dart';
import 'package:provider/provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late OrdersProvider _ordersProvider;

  @override
  void initState() {
    super.initState();
    _ordersProvider = Provider.of<OrdersProvider>(context, listen: false);
    loadData();
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
    return Container(
      child: Consumer<OrdersProvider>(
        builder: (context, provider, child) {
          return ListView.builder(
            itemCount: provider.items.length,
            itemBuilder: (context, index) {
              final order = provider.items[index];
              return ListTile(
                title: Text("Order #${order.orderNumber}"),
                
              );
            },
          );
        },
      ),
    );
  }
}

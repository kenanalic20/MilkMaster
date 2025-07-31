import 'package:flutter/material.dart';
import 'package:milkmaster_desktop/screens/categories_screen.dart';
import 'package:milkmaster_desktop/screens/cattle_screen.dart';
import 'package:milkmaster_desktop/screens/customers_screen.dart';
import 'package:milkmaster_desktop/widgets/master_screen.dart';
import 'package:milkmaster_desktop/widgets/nav_sidebar.dart';
import '../screens/dashboard_screen.dart';
import '../screens/products_screen.dart';
import '../screens/orders_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  final List<String> _titles = [
    'Dashboard',
    'Products',
    'Cattle',
    'Categories',
    'Orders',
    'Customers',
  ];

  final List<String> _subtitles = [
    'Overview of your dashboard',
    'Manage your products',
    'Manage your cattle',
    'Manage your categories',
    'Track orders',
    'Manage your customers',
  ];

  final List<Widget> _pages = [
    const DashboardScreen(),
    const ProductScreen(),
    const CattleScreen(),
    const CategoriesScreen(),
    const OrdersScreen(),
    const CustomersScreen(),
  ];

  void _onNavItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationSidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: _onNavItemSelected,
          ),
          Expanded(
            child: MasterWidget(
              title: _titles[_selectedIndex],
              subtitle: _subtitles[_selectedIndex],
              body: _pages[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}


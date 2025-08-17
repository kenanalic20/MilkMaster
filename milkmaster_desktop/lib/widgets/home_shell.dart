import 'package:flutter/material.dart';
import 'package:milkmaster_desktop/screens/animal_categories.dart';
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
    'Product categories',
    'Orders',
    'Customers',
  ];

  final List<String> _subtitles = [
    'Overview of your dashboard',
    'Manage your products',
    'Manage your cattle',
    'Manage your product categories',
    'Track orders',
    'Manage your customers',
  ];

  final List<Widget?> _headerActions = [
    Text('Dashboard headeraction'), // Products
    null, // Dashboard
    null, // Cattle
    Text('Categories headeraction'), // Categories
    null, // Orders
    null, // Customers
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

          Container(
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Wrap(
                
                direction: Axis.vertical,
                children: [
                  MasterWidget(
                    title: _titles[_selectedIndex],
                    subtitle: _subtitles[_selectedIndex],
                    body: _pages[_selectedIndex],
                    headerActions: _headerActions[_selectedIndex],
                  ),
                  if (_selectedIndex == 3)
                    AnimalCategoriesScreen(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:milkmaster_mobile/screens/about_screen.dart';
import 'package:milkmaster_mobile/screens/cattle_screen.dart';
import 'package:milkmaster_mobile/screens/home_screen.dart';
import 'package:milkmaster_mobile/screens/product_details_screen.dart';
import 'package:milkmaster_mobile/screens/products_screen.dart';
import 'package:milkmaster_mobile/screens/profile_screen.dart';
import 'package:milkmaster_mobile/screens/search_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;
  int? _selectedProductCategory;
  int? _selectedCattleCategoryForCattle;
  int? _viewingProductId;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _viewingProductId = null;
    });
  }

  void navigateToProducts({int? productCategoryId, int? cattleCategoryId}) {
    setState(() {
      _selectedIndex = 1;
      _selectedProductCategory = productCategoryId;
      _viewingProductId = null;
    });
  }

  void navigateToCattle({int? cattleCategoryId}) {
    setState(() {
      _selectedIndex = 2;
      _selectedCattleCategoryForCattle = cattleCategoryId;
      _viewingProductId = null;
    });
  }

  void navigateToProductDetails(int productId) {
    setState(() {
      _viewingProductId = productId;
    });
  }

  Widget _buildScreen(int index) {
    // If viewing product details, show that instead
    if (_viewingProductId != null) {
      return ProductDetailsScreen(
        productId: _viewingProductId!,
        onNavigateToProductDetails: navigateToProductDetails,
      );
    }

    switch (index) {
      case 0:
        return HomeScreen(
          onNavigateToProducts: navigateToProducts,
          onNavigateToCattle: navigateToCattle,
          onNavigateToProductDetails: navigateToProductDetails,
        );
      case 1:
        return ProductsScreen(
          selectedProductCategory: _selectedProductCategory,
          onNavigateToProductDetails: navigateToProductDetails,
        );
      case 2:
        return CattleScreen(
          selectedCattleCategory: _selectedCattleCategoryForCattle,
        );
      case 3:
        return const AboutScreen();
      case 4:
        return const ProfileScreen();
      default:
        return HomeScreen(
          onNavigateToProducts: navigateToProducts,
          onNavigateToCattle: navigateToCattle,
          onNavigateToProductDetails: navigateToProductDetails,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            title: Padding(
              padding: EdgeInsets.only(top: 16),
              child: Image.asset(
                'assets/images/logo.png',
                height: 35,
                fit: BoxFit.contain,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: IconButton(
                  icon: const Icon(Icons.search),
                  iconSize: 30,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchScreen(
                          onNavigateToProductDetails: navigateToProductDetails,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16, right: 9),
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  iconSize: 30,
                  onPressed: () {
                    // TODO: Implement cart action
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          final inFromRight = _selectedIndex > 0; // or track previous index
          final offsetTween = Tween<Offset>(
            begin: inFromRight ? const Offset(1, 0) : const Offset(-1, 0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeInOut));

          return SlideTransition(
            position: animation.drive(offsetTween),
            child: child,
          );
        },
        child: _buildScreen(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 30.0,
        type: BottomNavigationBarType.fixed,
        selectedIconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.secondary,
        ),
        unselectedIconTheme: const IconThemeData(color: Colors.grey),

        selectedLabelStyle: const TextStyle(color: Colors.black),
        unselectedLabelStyle: const TextStyle(color: Colors.black),
        selectedItemColor: Colors.black,

        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Products',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Cattle'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'About'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

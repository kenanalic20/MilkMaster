import 'package:flutter/material.dart';
import 'package:milkmaster_desktop/main.dart';
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

class _HomeShellState extends State<HomeShell>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  Widget? _activeFormWidget;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  final GlobalKey _categoriesScreenKey = GlobalKey();
 final GlobalKey<DashboardScreenState> _dashboardKey = GlobalKey<DashboardScreenState>();


  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  final List<String> _titles = [
    'Welcome to MilkMaster Administration',
    'Products',
    'Cattle',
    'Product categories',
    'Orders',
    'Customers',
  ];

  final List<String> _subtitles = [
    "Here's an overview of your product sales and performance",
    'Manage your dairy products inventory',
    'Manage and track your cattle',
    'Manage your product categories',
    'Manage and track customer orders',
    'Manage and track customers',
  ];

  List<Widget?> get _headerActions => [
    Container(
      height: 45,
      margin: EdgeInsets.only(
        top: Theme.of(context).extension<AppSpacing>()!.medium,
      ),
      child: ElevatedButton(
        onPressed: ()  => {
          _dashboardKey.currentState?.openForm(),
        },
        child: Text('Download Business Report'),
      ),
    ),// Dashboard
    null, // Products
    null, // Cattle
    ProductCategoriesHeaderAction(
      onPressed: () {
        setState(() => _selectedIndex = 3);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          (_categoriesScreenKey.currentState as dynamic)?.openForm();
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          (_categoriesScreenKey.currentState as dynamic)?.openForm();
        });
      },
    ), // Categories
    null, // Orders
    null, // Customers
  ];

  Widget get _currentPage {
    switch (_selectedIndex) {
      case 0:
        return DashboardScreen(key: _dashboardKey,openForm: _onFormOpened,closeForm: _onFormClosed);
      case 1:
        return ProductScreen(openForm: _onFormOpened, closeForm: _onFormClosed);
      case 2:
        return CattleScreen(openForm: _onFormOpened, closeForm: _onFormClosed);
      case 3:
        return CategoriesScreen(
          key: _categoriesScreenKey,
          openForm: _onFormOpened,
          closeForm: _onFormClosed,
        );
      case 4:
        return OrdersScreen(openForm: _onFormOpened, closeForm: _onFormClosed);
      case 5:
        return const CustomersScreen();
      default:
        return DashboardScreen(key: _dashboardKey,openForm: _onFormOpened,closeForm: _onFormClosed);
    }
  }

  void _onFormOpened(Widget form) {
    setState(() {
      _activeFormWidget = form;
    });
    _slideController.forward(from: 0);
  }

  void _onFormClosed() {
    _slideController.reverse().then((_) {
      setState(() {
        _activeFormWidget = null;
      });
    });
  }

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
                  if (_activeFormWidget != null) ...[
                    SlideTransition(
                      position: _slideAnimation,
                      child: Material(
                        elevation: 8,
                        color: Colors.white,
                        child: Container(
                          height: MediaQuery.of(context).size.height,
                          child: _activeFormWidget,
                        ),
                      ),
                    ),
                  ] else ...[
                    MasterWidget(
                      title: _titles[_selectedIndex],
                      subtitle: _subtitles[_selectedIndex],
                      body: _currentPage,
                      headerActions: _headerActions[_selectedIndex],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCategoriesHeaderAction extends StatelessWidget {
  final VoidCallback? onPressed;
  const ProductCategoriesHeaderAction({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      margin: EdgeInsets.only(
        top: Theme.of(context).extension<AppSpacing>()!.medium,
      ),
      child: ElevatedButton(
        onPressed: onPressed ?? () async => {},
        child: Text('Add Product Category'),
      ),
    );
  }
}

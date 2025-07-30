import 'package:flutter/material.dart';
import 'package:milkmaster_desktop/main.dart';

class MasterWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final Widget? headerActions;
  final Widget body;

  const MasterWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.body,
    this.headerActions,
  });

  @override
  State<MasterWidget> createState() => _MasterWidgetState();
}

class _MasterWidgetState extends State<MasterWidget> {
  // Keep track of the current selected index for navigation
  int selectedIndex = 0;

  // List of body widgets corresponding to nav items
  final List<Widget> bodies = [
    Center(child: Text('Dashboard Content')),
    Center(child: Text('Products Content')),
    Center(child: Text('Cattle Content')),
    Center(child: Text('Categories Content')),
    Center(child: Text('Orders Content')),
    Center(child: Text('Customers Content')),
  ];

  // List of nav labels for reuse (optional)
  final List<String> navLabels = [
    'Dashboard',
    'Products',
    'Cattle',
    'Categories',
    'Orders',
    'Customers',
  ];

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacing>()!;

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.28,
            color: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.fromLTRB(15,30,15,30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: spacing.large),
                Column(
                  children: List.generate(navLabels.length, (index) {
                    IconData icon;
                    switch(index) {
                      case 0: icon = Icons.home; break;
                      case 1: icon = Icons.shopping_cart; break;
                      case 2: icon = Icons.pets; break;
                      case 3: icon = Icons.category; break;
                      case 4: icon = Icons.receipt_long; break;
                      case 5: icon = Icons.people; break;
                      default: icon = Icons.circle;
                    }
                    return navItem(icon, navLabels[index], index);
                  }),
                )
              ],
            ),
          ),

          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30,30,0,0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      navLabels[selectedIndex],
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    SizedBox(height: spacing.small),
                    Text(
                      'Subtitle for ${navLabels[selectedIndex]}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    SizedBox(height: spacing.large),

                    // Show the body widget corresponding to selected index
                    bodies[selectedIndex],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget navItem(IconData icon, String label, int index) {
    final isSelected = index == selectedIndex;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Container(
        color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isSelected ? Colors.white : Colors.white70),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

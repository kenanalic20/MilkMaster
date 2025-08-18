import 'package:flutter/material.dart';
import 'package:milkmaster_desktop/main.dart';
import 'package:milkmaster_desktop/providers/auth_provider.dart';
import 'package:milkmaster_desktop/utils/widget_helpers.dart';
import 'package:provider/provider.dart';

class NavigationSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const NavigationSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.21,
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: EdgeInsets.fromLTRB(15, 30, 15, 30),
        child: Column(
          children: [
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                height: 60,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 16),
            NavItem(
              index: 0,
              icon: Icons.home,
              label: 'Dashboard',
              selectedIndex: selectedIndex,
              onItemSelected: onItemSelected,
            ),
            NavItem(
              index: 1,
              icon: 'assets/icons/milk_icon.png',
              label: 'Products',
              selectedIndex: selectedIndex,
              onItemSelected: onItemSelected,
            ),
            NavItem(
              index: 2,
              icon: 'assets/icons/cow_icon.png',
              label: 'Cattle',
              selectedIndex: selectedIndex,
              onItemSelected: onItemSelected,
            ),
            NavItem(
              index: 3,
              icon: 'assets/icons/stacks.png',
              label: 'Categories',
              selectedIndex: selectedIndex,
              onItemSelected: onItemSelected,
            ),
            NavItem(
              index: 4,
              icon: Icons.shopping_cart_outlined,
              label: 'Orders',
              selectedIndex: selectedIndex,
              onItemSelected: onItemSelected,
            ),
            NavItem(
              index: 5,
              icon: Icons.group_outlined,
              label: 'Customers',
              selectedIndex: selectedIndex,
              onItemSelected: onItemSelected,
            ),

            SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: Colors.transparent)
              ),
              onPressed: () async {
                final authProvider = context.read<AuthProvider>();
                await authProvider.logout();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, color: Colors.black),
                  SizedBox(width: 8),
                  Text('Logout', style: TextStyle(color: Colors.black)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavItem extends StatefulWidget {
  final int index;
  final dynamic icon;
  final String label;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const NavItem({
    super.key,
    required this.index,
    required this.icon,
    required this.label,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  State<NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<NavItem> {
  @override
  Widget build(BuildContext context) {
    final isSelected = widget.selectedIndex == widget.index;
    final spacing = Theme.of(context).extension<AppSpacing>()!;

    return GestureDetector(
      onTap: () => widget.onItemSelected(widget.index),
      child: FractionallySizedBox(
        widthFactor: 0.66,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: EdgeInsets.symmetric(vertical: spacing.medium),
          padding: EdgeInsets.symmetric(vertical: isSelected ? 15 : 0),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? const Color.fromRGBO(250, 167, 13, 1)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                leadingIcon(widget.icon),
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: const TextStyle(color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

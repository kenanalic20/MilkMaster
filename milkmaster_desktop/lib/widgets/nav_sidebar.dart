import 'package:flutter/material.dart';
import 'package:milkmaster_desktop/main.dart';

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
            _navItem(context, 0, Icons.home, 'Dashboard'),
            _navItem(context, 1, 'assets/icons/milk_icon.png', 'Products'),
            // _navItem(context, 2, Icons.shopping_cart, 'Cattle'),
            // _navItem(context, 3, Icons.shopping_cart, 'Categories'),
            _navItem(context, 2, Icons.shopping_cart, 'Orders'),

            // _navItem(context, 5, Icons.shopping_cart, 'Customers'),
          ],
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, int index, dynamic icon, String label) {
    final bool isSelected = selectedIndex == index;
    final spacing = Theme.of(context).extension<AppSpacing>()!;

    return GestureDetector(
      onTap: () => onItemSelected(index),
      child: FractionallySizedBox(
        widthFactor: 0.66,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: EdgeInsets.symmetric(vertical: spacing.medium),
          padding: EdgeInsets.symmetric(
            vertical: isSelected ? 20 : 0,
            horizontal: isSelected ? 21 : 20,
          ),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? const Color.fromRGBO(250, 167, 13, 1)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              leadingIcon(icon),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget leadingIcon(dynamic icon) {
    if (icon is IconData) {
      return Icon(icon, color: const Color.fromRGBO(27, 27, 27,1));
    } else if (icon is String) {
      return Image.asset(icon, width: 24, height: 24, fit: BoxFit.contain);
    } else {
      return const SizedBox();
    }
  }
}

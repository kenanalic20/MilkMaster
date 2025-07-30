import 'package:flutter/material.dart';
import 'package:milkmaster_desktop/widgets/master_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final String title = "Welcome to MilkMaster Administration";
  final String subtitle = "Here's an overview of your product sales and performance";

  @override
  Widget build(BuildContext context) {
    final body = Column(children: [
          Center(
            child: Text(
              "Dashboard content goes here",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),Center(
            child: Text(
              "Dashboard content goes here",
              style: Theme.of(context).textTheme.headlineMedium,
            ),

          ),Center(
            child: Text(
              "Dashboard content goes here",
              style: Theme.of(context).textTheme.headlineMedium,
            ),

          ),Center(
            child: Text(
              "Dashboard content goes here",
              style: Theme.of(context).textTheme.headlineMedium,
            ),

          ),Center(
            child: Text(
              "Dashboard content goes here",
              style: Theme.of(context).textTheme.headlineMedium,
            ),

          ),Center(
            child: Text(
              "Dashboard content goes here",
              style: Theme.of(context).textTheme.headlineMedium,
            ),

          ),Center(
            child: Text(
              "Dashboard content goes here",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),Center(
            child: Text(
              "Dashboard content goes here",
              style: Theme.of(context).textTheme.headlineMedium,
            ),

          ),Center(
            child: Text(
              "Dashboard content goes here",
              style: Theme.of(context).textTheme.headlineMedium,
            ),

          ),Center(
            child: Text(
              "Dashboard content goes here",
              style: Theme.of(context).textTheme.headlineMedium,
            ),

          ),Center(
            child: Text(
              "Dashboard content goes here",
              style: Theme.of(context).textTheme.headlineMedium,
            ),

          ),Center(
            child: Text(
              "Dashboard content goes here",
              style: Theme.of(context).textTheme.headlineMedium,
            ),

          ),Center(
            child: Text(
              "Dashboard content goes here",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),Center(
            child: Text(
              "Dashboard content goes here",
              style: Theme.of(context).textTheme.headlineMedium,
            ),

          ),Center(
            child: Text(
              "Dashboard content goes here",
              style: Theme.of(context).textTheme.headlineMedium,
            ),

          ),Center(
            child: Text(
              "Dashboard content goes here",
              style: Theme.of(context).textTheme.headlineMedium,
            ),

          ),Center(
            child: Text(
              "Dashboard content goes here",
              style: Theme.of(context).textTheme.headlineMedium,
            ),

          ),Center(
            child: Text(
              "Dashboard content goes here",
              style: Theme.of(context).textTheme.headlineMedium,
            ),

          ),Center(
            child: Text(
              "Dashboard content goes here",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),Center(
            child: Text(
              "Dashboard content goes here",
              style: Theme.of(context).textTheme.headlineMedium,
            ),

          ),Center(
            child: Text(
              "Dashboard content goes here",
              style: Theme.of(context).textTheme.headlineMedium,
            ),

          ),Center(
            child: Text(
              "Dashboard content goes here",
              style: Theme.of(context).textTheme.headlineMedium,
            ),

          ),Center(
            child: Text(
              "Dashboard content goes here",
              style: Theme.of(context).textTheme.headlineMedium,
            ),

          ),Center(
            child: Text(
              "Dashboard content goes here",
              style: Theme.of(context).textTheme.headlineMedium,
            ),

          ),Center(
            child: Text(
              "Dashboard content goes here",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),Center(
            child: Text(
              "Dashboard content goes here",
              style: Theme.of(context).textTheme.headlineMedium,
            ),

          ),Center(
            child: Text(
              "Dashboard content goes here",
              style: Theme.of(context).textTheme.headlineMedium,
            ),

          ),Center(
            child: Text(
              "Dashboard content goes here",
              style: Theme.of(context).textTheme.headlineMedium,
            ),

          ),Center(
            child: Text(
              "Dashboard content goes here",
              style: Theme.of(context).textTheme.headlineMedium,
            ),

          ),Center(
            child: Text(
              "Dashboard content goes here",
              style: Theme.of(context).textTheme.headlineMedium,
            ),

          ),
    ]);

    return MasterWidget(title: title, subtitle: subtitle, body: body);
  }
}

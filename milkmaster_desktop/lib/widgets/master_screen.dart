import 'package:flutter/material.dart';
import 'package:milkmaster_desktop/main.dart';

class MasterWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacing>()!;

    return Padding(
      padding: EdgeInsets.all(spacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.headlineLarge),
                    SizedBox(height: spacing.small),
                    Text(subtitle, style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.tertiary,
                    )),
                  ],
                ),
              ),
              if (headerActions != null) ...[
                SizedBox(width: spacing.large),
                headerActions!,
              ],
            ],
          ),
          SizedBox(height: spacing.large),
          Expanded(child: body),
        ],
      ),
    );
  }
}


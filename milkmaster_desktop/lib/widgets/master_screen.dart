import 'package:flutter/material.dart';
import 'package:milkmaster_desktop/main.dart';
import 'package:milkmaster_desktop/utils/widget_helpers.dart';

class MasterWidget extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget? headerActions;
  final Widget body;
  final double? padding;
  final bool hasData;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final double? customSpacing;

  const MasterWidget({
    super.key,
    this.title,
    this.subtitle,
    required this.body,
    this.headerActions,
    this.padding,
    this.hasData = true,
    this.titleStyle,
    this.subtitleStyle,
    this.customSpacing
  });

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacing>()!;

    return Container(
      width: MediaQuery.of(context).size.width * 0.79,
      child: Padding(
        padding: EdgeInsets.all(padding ?? spacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style:
                            titleStyle == null
                                ? Theme.of(context).textTheme.headlineLarge
                                : titleStyle,
                      ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style:
                            subtitleStyle == null
                                ? Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.tertiary,
                                )
                                : subtitleStyle,
                      ),
                  ],
                ),
                Spacer(),
                if (headerActions != null) ...[
                  headerActions!,
                ],
              ],
            ),
            SizedBox(height: customSpacing==null ? spacing.medium : customSpacing),

            hasData ? body : NoDataWidget(),
          ],
        ),
      ),
    );
  }
}

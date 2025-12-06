import 'package:flutter/material.dart';
import 'package:milkmaster_mobile/main.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             Center(
               child: ClipRRect(
                 borderRadius: BorderRadius.circular(12),
                 child: Image.asset(
                    'assets/images/logo.png',
                    width: 380,
                    height: 80,
                  ),
               ),
             ),
              
              SizedBox(height: Theme.of(context).extension<AppSpacing>()?.medium),
              _buildSectionTitle(context, 'Our Mission'),
              SizedBox(height: Theme.of(context).extension<AppSpacing>()?.medium),
              Container(
                padding: const EdgeInsets.only(bottom: 8.0),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).colorScheme.secondary,
                      width: 1,
                    ),
                  ),
                ),
                child: _buildSectionText(
                  context,
                  'Experience the true taste of freshness with our all-in-one app that connects you directly to our local dairy farm. From farm-fresh milk to rich dairy delights, everything comes straight from our healthy, well-cared-for cattle – no middleman, no shortcuts.',
                ),
              ),
              SizedBox(height: Theme.of(context).extension<AppSpacing>()?.small),
              Center(
                child: Image.asset(
                  'assets/icons/cow_icon.png',
                  width: 50,
                  height: 50,
                  fit: BoxFit.contain,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              _buildSectionTitle(context, 'Animal Welfare'),
              SizedBox(height: Theme.of(context).extension<AppSpacing>()?.medium),
              _buildSectionText(
                context,
                'We believe healthy, happy animals produce better milk. Our platform helps you monitor and improve animal health.',
              ),
              SizedBox(height: Theme.of(context).extension<AppSpacing>()?.medium),
              Center(
                child: Image.asset(
                  'assets/icons/milk_icon.png',
                  width: 50,
                  height: 50,
                  fit: BoxFit.contain,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),

              _buildSectionTitle(context, 'Farm to Table'),
              SizedBox(height: Theme.of(context).extension<AppSpacing>()?.medium),
              _buildSectionText(
                context,
                'We connect directly with consumers through our marketplace, cutting out middlemen.',
              ),
              SizedBox(height: Theme.of(context).extension<AppSpacing>()?.medium),
              Center(
                child: Icon(
                  Icons.shopping_cart_outlined,
                  size: 50,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              _buildSectionTitle(context, 'Order Fresh Dairy Products'),
              SizedBox(height: Theme.of(context).extension<AppSpacing>()?.medium),
              Center(
                child: Text(
                  'Browse and buy fresh milk, yogurt, cheese, butter, and more – all made naturally on our farm.',
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: Theme.of(context).extension<AppSpacing>()?.medium),
              Center(
                child: Icon(
                  Icons.favorite_border,
                  size: 50,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              _buildSectionTitle(context, 'No additives or preservatives'),
              SizedBox(height: Theme.of(context).extension<AppSpacing>()?.medium),
              Container(
                padding: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).colorScheme.secondary,
                      width: 1,
                    ),
                  ),
                ),
                child: _buildSectionText(
                  context,
                  'Our dairy products are 100% natural – made without any additives, preservatives, or artificial ingredients.',
                ),
              ),
              
              SizedBox(height: Theme.of(context).extension<AppSpacing>()?.medium),
              
              _buildSectionTitle(context, 'Contact Us'),
              SizedBox(height: Theme.of(context).extension<AppSpacing>()?.medium),
              
              InkWell(
                onTap: () async {
                  final Uri emailUri = Uri(
                    scheme: 'mailto',
                    path: 'milkmasterapptest@gmail.com',
                  );
                  try {
                    if (await canLaunchUrl(emailUri)) {
                      await launchUrl(emailUri);
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No email app available')),
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not open email app')),
                      );
                    }
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: 20,
                    ),
                    Text(
                      'milkmasterapptest@gmail.com',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () async {
                  final Uri phoneUri = Uri(
                    scheme: 'tel',
                    path: '+15551234567',
                  );
                  try {
                    if (await canLaunchUrl(phoneUri)) {
                      await launchUrl(phoneUri);
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No phone app available')),
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not open phone app')),
                      );
                    }
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      size: 20,
                    ),
                    Text(
                      '+1 (555) 123 4567',
                      style: Theme.of(context).textTheme.bodyMedium
                    ),
                  ],
                ),
              ),
              
              InkWell(
                onTap: () async {
                  final Uri locationUri = Uri.parse('https://maps.app.goo.gl/ZVn5wQYmQXhWoAKW7');
                  try {
                    if (await canLaunchUrl(locationUri)) {
                      await launchUrl(locationUri, mode: LaunchMode.externalApplication);
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Could not open maps')),
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not open maps app')),
                      );
                    }
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 20,
                    ),
                    Text(
                      'Farm Location',
                      style: Theme.of(context).textTheme.bodyMedium
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: Theme.of(context).extension<AppSpacing>()?.medium),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Center(
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }
  
  Widget _buildSectionText(BuildContext context, String text) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
      ),
    );
  }
}
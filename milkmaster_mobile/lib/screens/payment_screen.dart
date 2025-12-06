import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:milkmaster_mobile/providers/payment_provider.dart';
import 'package:milkmaster_mobile/utils/widget_helpers.dart';
import 'package:provider/provider.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  final VoidCallback onPaymentSuccess;
  final VoidCallback? onPaymentCancel;

  const PaymentScreen({
    super.key,
    required this.amount,
    required this.onPaymentSuccess,
    this.onPaymentCancel,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _handlePayment() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);

      // Create payment intent
      final paymentIntent = await paymentProvider.createPaymentIntent(
        amount: widget.amount,
        currency: 'bam', // Bosnia and Herzegovina Convertible Mark
      );

      if (paymentIntent == null) {
        throw Exception('Failed to create payment intent');
      }

      final clientSecret = paymentIntent['clientSecret'];

      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'MilkMaster',
          style: ThemeMode.light,
        ),
      );

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      // Payment successful
      if (mounted) {
        showCustomDialog(
          context: context,
          title: 'Payment Successful',
          message: 'Your payment has been processed successfully!',
          onConfirm: () {
            widget.onPaymentSuccess();
          },
          showCancel: false,
        );
      }
    } on StripeException catch (e) {
      if (mounted) {
        if (e.error.code == FailureCode.Canceled) {
          // User canceled
          showCustomDialog(
            context: context,
            title: 'Payment Cancelled',
            message: 'You have cancelled the payment.',
            onConfirm: () {
              if (widget.onPaymentCancel != null) {
                widget.onPaymentCancel!();
              }
            },
            showCancel: false,
          );
        } else {
          // Payment failed
          showCustomDialog(
            context: context,
            title: 'Payment Failed',
            message: e.error.message ?? 'Payment failed. Please try again.',
            onConfirm: () {},
            showCancel: false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showCustomDialog(
          context: context,
          title: 'Error',
          message: 'An error occurred: ${e.toString()}',
          onConfirm: () {},
          showCancel: false,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Container(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${widget.amount.toStringAsFixed(2)} BAM',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Payment Method',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Secure payment powered by Stripe',
              style: TextStyle(color: Colors.grey),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _handlePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Colors.white,
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Pay ${widget.amount.toStringAsFixed(2)} BAM',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

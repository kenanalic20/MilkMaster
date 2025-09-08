import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:milkmaster_desktop/main.dart';
import 'package:milkmaster_desktop/models/orders_model.dart';
import 'package:milkmaster_desktop/models/top_selling_product_model.dart';
import 'package:milkmaster_desktop/providers/orders_provider.dart';
import 'package:milkmaster_desktop/providers/products_provider.dart';
import 'package:milkmaster_desktop/providers/report_provider.dart';
import 'package:milkmaster_desktop/utils/widget_helpers.dart';
import 'package:milkmaster_desktop/widgets/master_screen.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  final void Function(Widget form) openForm;
  final void Function() closeForm;

  const DashboardScreen({
    super.key,
    required this.openForm,
    required this.closeForm,
  });

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  late OrdersProvider _ordersProvider;
  late ProductProvider _productProvider;
  late ReportProvider _reportProvider;
  List<Order> _orders = [];
  List<TopSellingProduct> _topSellingProducts = [];
  final _formKey = GlobalKey<FormBuilderState>();
  int _soldProducts = 0;
  double _totalRevenue = 0;
  int _pageSize = 4;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _ordersProvider = context.read<OrdersProvider>();
    _productProvider = context.read<ProductProvider>();
    _reportProvider = context.read<ReportProvider>();
    _fetchOrders(extraQuery: {"pageSize": _pageSize, "orderBy": 'date_desc'});
    _fetchTopProducts();
    _fetchSoldProducts();
    _fetchTotalRevenue();
  }

  void openForm() {
    _formKey.currentState?.reset();
    widget.openForm(
      SingleChildScrollView(
        child: MasterWidget(
          title: 'Report settings',
          subtitle: 'Select what you want to export',
          body: _buildReportForm(),
        ),
      ),
    );
  }

  Future<void> _fetchOrders({
    int? page,
    Map<String, dynamic>? extraQuery,
  }) async {
    try {
      final queryParams = {
        "pageSize": _pageSize,
        if (extraQuery != null) ...extraQuery,
      };

      final result = await _ordersProvider.fetchAll(queryParams: queryParams);

      if (mounted) {
        setState(() {
          _orders = result.items;
          _totalCount = result.totalCount;
        });
      }
    } catch (e) {
      print("Error fetching orders: $e");
    }
  }

  Future<void> _fetchTotalRevenue() async {
    try {
      final result = await _ordersProvider.getTotalRevenue();
      if (mounted) {
        setState(() {
          _totalRevenue = result;
        });
      }
    } catch (e) {
      print("Error fetching top products: $e");
    }
  }

  Future<void> _fetchTopProducts() async {
    try {
      final result = await _productProvider.getTopSellingProducts();
      if (mounted) {
        setState(() {
          _topSellingProducts = result;
        });
      }
    } catch (e) {
      print("Error fetching top products: $e");
    }
  }

  Future<void> _fetchSoldProducts() async {
    try {
      final result = await _productProvider.getSoldProductCount();
      if (mounted) {
        setState(() {
          _soldProducts = result;
        });
      }
    } catch (e) {
      print("Error fetching top products: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [_buildDashboardStats(), _buildDashboard()]);
  }

  Widget _buildDashboard() {
    return Row(
      children: [
        Wrap(
          spacing: Theme.of(context).extension<AppSpacing>()!.large,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                border: Border.all(
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              padding: const EdgeInsets.only(left: 15, bottom: 15),
              width: MediaQuery.of(context).size.width * 0.365,
              child: MasterWidget(
                title: 'Top Selling Products',
                subtitle: 'Your best performing products this month',
                titleStyle: Theme.of(context).textTheme.headlineMedium,
                subtitleStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                body:
                    _productProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _topSellingProducts.isEmpty
                        ? const NoDataWidget()
                        : Column(
                          children:
                              _topSellingProducts.map((product) {
                                return Container(
                                  padding: EdgeInsets.only(
                                    top:
                                        Theme.of(
                                          context,
                                        ).extension<AppSpacing>()!.large,
                                    bottom: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.tertiary,
                                        width: 0.5,
                                      ),
                                    ),
                                  ),
                                  child: SizedBox(
                                    height: 40,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          spacing: 5,
                                          children: [
                                            product.imageUrl != ''
                                                ? Image.network(
                                                  product.imageUrl,
                                                  width: 24,
                                                  height: 24,
                                                  color: Colors.amber,
                                                )
                                                : Image.asset(
                                                  'assets/icons/milk_icon_yellow.png',
                                                ),
                                            Text(
                                              product.title,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodyMedium?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          '${formatDouble(product.totalSales)} BAM',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
              ),
            ),

            Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                border: Border.all(
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              padding: const EdgeInsets.only(left: 15, bottom: 15),
              width: MediaQuery.of(context).size.width * 0.365,
              child: MasterWidget(
                title: 'Recent Orders',
                subtitle: 'Latest customer orders',
                titleStyle: Theme.of(context).textTheme.headlineMedium,
                subtitleStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                body:
                    _ordersProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _orders.isEmpty
                        ? const NoDataWidget()
                        : Column(
                          children:
                              _orders.map((order) {
                                return Container(
                                  padding: EdgeInsets.only(
                                    top:
                                        Theme.of(
                                          context,
                                        ).extension<AppSpacing>()!.large,
                                    bottom: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.tertiary,
                                        width: 0.5,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Order ${order.orderNumber}',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            DateFormat(
                                              'dd/MM/yyyy',
                                            ).format(order.createdAt),
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.copyWith(
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.tertiary,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                        ],
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${formatDouble(order.total)} BAM',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            order.status!.name,
                                            style: TextStyle(
                                              color: hexToColor(
                                                order.status!.colorCode,
                                              ),
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                        ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  FormBuilder _buildReportForm() {
    return FormBuilder(
      key: _formKey,
      child: Column(
        children: [
          // Report Name
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: FormBuilderTextField(
                name: 'name',
                decoration: const InputDecoration(labelText: 'Report Name'),
                validator: FormBuilderValidators.required(
                  errorText: 'Report name is required',
                ),
              ),
            ),
          ),
          SizedBox(height: Theme.of(context).extension<AppSpacing>()!.medium),

          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: FormBuilderTextField(
                name: 'description',
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Report Description',
                ),
                validator: FormBuilderValidators.required()
              ),
            ),
          ),
          SizedBox(height: Theme.of(context).extension<AppSpacing>()!.medium),

          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: FormBuilderTextField(
                name: 'topProductsCount',
                initialValue: '4',
                decoration: const InputDecoration(
                  labelText: 'Top Products Count',
                ),
                keyboardType: TextInputType.number,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: 'Required'),
                  FormBuilderValidators.numeric(errorText: 'Must be a number'),
                ]),
              ),
            ),
          ),
          SizedBox(height: Theme.of(context).extension<AppSpacing>()!.medium),

          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: FormBuilderTextField(
                name: 'recentOrdersCount',
                initialValue: '10',
                decoration: const InputDecoration(
                  labelText: 'Recent Orders Count',
                ),
                keyboardType: TextInputType.number,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: 'Required'),
                  FormBuilderValidators.numeric(errorText: 'Must be a number'),
                ]),
              ),
            ),
          ),
          SizedBox(height: Theme.of(context).extension<AppSpacing>()!.medium),

          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: FormBuilderSwitch(
                name: 'includeTopOrder',
                title: const Text('Include Top Order'),
                initialValue: true,
              ),
            ),
          ),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,

              child: FormBuilderSwitch(
                name: 'includeTopCustomer',
                title: const Text('Include Top Customer'),
                initialValue: true,
              ),
            ),
          ),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,

              child: FormBuilderSwitch(
                name: 'includeLowestSellingProduct',
                title: const Text('Include Lowest Selling Product'),
                initialValue: true,
              ),
            ),
          ),

          SizedBox(height: Theme.of(context).extension<AppSpacing>()!.medium),

          // Submit Button
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => widget.closeForm(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                Builder(
                  builder: (context) {
                    return ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState?.saveAndValidate() ?? false) {
                          final body = Map<String, dynamic>.from(
                            _formKey.currentState!.value,
                          );
                          print('Report options submitted: $body');
                          await showCustomDialog(
                            context: context,
                            title: "Get Report",
                            message:
                                "Are you sure you want to download report?",
                            onConfirm: () async {
                              await _reportProvider.downloadPdfToUserLocation(
                                body: body,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Report Downloaded successfully",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  backgroundColor:
                                      Theme.of(context).colorScheme.secondary,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              widget.closeForm();
                            },
                          );
                        }
                      },
                      child: const Text('Generate Report'),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardStats() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: Theme.of(context).extension<AppSpacing>()!.large,
      ),
      child: Row(
        children: [
          Wrap(
            spacing: Theme.of(context).extension<AppSpacing>()!.large,
            children: [
              Container(
                width: 230,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.tertiary,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Total Revenue",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing:
                            Theme.of(context).extension<AppSpacing>()!.small,
                        children: [
                          Text(
                            formatDouble(_totalRevenue),
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          Text(
                            "BAM",
                            style: Theme.of(
                              context,
                            ).textTheme.headlineMedium?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: 230,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.tertiary,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Total Orders",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing:
                            Theme.of(context).extension<AppSpacing>()!.small,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          Text(
                            _totalCount.toString(),
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: 230,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.tertiary,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Products Sold",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing:
                            Theme.of(context).extension<AppSpacing>()!.small,
                        children: [
                          leadingIcon('assets/icons/milk_icon_yellow.png'),
                          Text(
                            _soldProducts.toString(),
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: 230,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.tertiary,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Total Customers",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing:
                            Theme.of(context).extension<AppSpacing>()!.small,
                        children: [
                          Icon(
                            Icons.group_outlined,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          Text(
                            _totalCount.toString(),
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

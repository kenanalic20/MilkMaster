import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:milkmaster_mobile/models/cattle_model.dart';
import 'package:milkmaster_mobile/models/products_model.dart';
import 'package:milkmaster_mobile/providers/cattle_provider.dart';
import 'package:milkmaster_mobile/providers/products_provider.dart';
import 'package:milkmaster_mobile/providers/cart_provider.dart';
import 'package:milkmaster_mobile/utils/widget_helpers.dart';
import 'package:milkmaster_mobile/widgets/product_slider.dart';
import 'package:provider/provider.dart';

class CattleDetailsScreen extends StatefulWidget {
  final int cattleId;
  final void Function(int productId)? onNavigateToProductDetails;
  final void Function({int? cattleCategoryId})? onNavigateToProducts;

  const CattleDetailsScreen({
    Key? key,
    required this.cattleId,
    this.onNavigateToProductDetails,
    this.onNavigateToProducts,
  }) : super(key: key);

  @override
  State<CattleDetailsScreen> createState() => _CattleDetailsScreenState();
}

class _CattleDetailsScreenState extends State<CattleDetailsScreen> {
  Cattle? _cattle;
  bool _isLoading = true;
  String? _errorMessage;
  late CattleProvider _cattleProvider;
  late ProductProvider _productProvider;
  List<Product> _relatedProducts = [];
  bool _isLoadingRelated = false;

  @override
  void initState() {
    super.initState();
    _cattleProvider = context.read<CattleProvider>();
    _productProvider = context.read<ProductProvider>();
    _fetchCattleDetails();
    _fetchRelatedProducts();
  }

  @override
  void didUpdateWidget(CattleDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cattleId != widget.cattleId) {
      _fetchCattleDetails();
    }
  }

  Future<void> _fetchCattleDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final cattle = await _cattleProvider.getById(widget.cattleId);

      if (mounted) {
        setState(() {
          _cattle = cattle;
          _isLoading = false;
        });
        _fetchRelatedProducts();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load cattle details: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchRelatedProducts() async {
    try {
      setState(() {
        _isLoadingRelated = true;
      });

      // Fetch products with this cattle's category ID
      if (_cattle?.cattleCategory?.id != null) {
        final result = await _productProvider.fetchAll(
          queryParams: {
            'cattleCategoryId': _cattle!.cattleCategory!.id,
            'pageSize': 3,
          },
        );

        if (mounted) {
          setState(() {
            _relatedProducts = result.items;
            _isLoadingRelated = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingRelated = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRelated = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null || _cattle == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Cattle not found',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchCattleDetails,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCattleImage(),
          _buildCattleInfo(),
          _buildDownloadButton(),
          _buildTabs(),
          _buildRelatedProducts(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCattleImage() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Center(
        child: Stack(
          children: [
            Container(
              width: 382,
              height: 215,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  fixLocalhostUrl(_cattle!.imageUrl),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.pets, size: 80),
                  ),
                ),
              ),
            ),
            if (_cattle!.cattleCategory != null)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _cattle!.cattleCategory!.name.toLowerCase(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCattleInfo() {
    final dateFormat = DateFormat('dd/MM/yyyy');
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _cattle!.name,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (_cattle!.breedOfCattle != null || _cattle!.age > 0)
            Text(
              '${_cattle!.breedOfCattle ?? ''} ${_cattle!.breedOfCattle != null && _cattle!.age > 0 ? '-' : ''} ${_cattle!.age > 0 ? '${_cattle!.age} years old' : ''}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.water_drop_outlined,
                          size: 16,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Milk Production',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                        ),
                      ],
                    ),
                    Text(
                      '${formatDouble(_cattle!.litersPerDay)} L/day',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.attach_money,
                          size: 16,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Monthly Value',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                        ),
                      ],
                    ),
                    Text(
                      '${formatDouble(_cattle!.monthlyValue)} BAM',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_month_outlined,
                          size: 16,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Birth Date',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                        ),
                      ],
                    ),
                    Text(
                      dateFormat.format(_cattle!.birthDate),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.favorite_border_outlined,
                          size: 16,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Health check',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                        ),
                      ],
                    ),
                    Text(
                      dateFormat.format(_cattle!.healthCheck),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadButton() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: SizedBox(
        width: double.infinity,
        height: 44,
        child: OutlinedButton(
          onPressed: () async {
            if (_cattle!.milkCartonUrl != null &&
                _cattle!.milkCartonUrl.isNotEmpty) {
              final success = await _cattleProvider.downloadMilkCarton(
                fixLocalhostUrl(_cattle!.milkCartonUrl),
              );

              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Opening milk carton for ${_cattle!.name}'),
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to open milk carton'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No milk carton available for this cattle'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(
              color: Colors.black,
              width: 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.white,
          ),
          child: Text(
            'Download Milk Carton',
            style: Theme.of(context).textTheme.bodyLarge
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return DefaultTabController(
      length: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(50),
              ),
              child: TabBar(
                labelColor: Colors.black,
                unselectedLabelColor: Theme.of(context).colorScheme.tertiary,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.all(8),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Breeding'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildTabContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return Builder(
      builder: (context) {
        final tabController = DefaultTabController.of(context);
        return AnimatedBuilder(
          animation: tabController,
          builder: (context, child) {
            final index = tabController.index;
            return index == 0 ? _buildOverviewTab() : _buildBreedingTab();
          },
        );
      },
    );
  }

  Widget _buildOverviewTab() {
    final overview = _cattle!.overview;
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About ${_cattle!.name}',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 15),
          if (overview?.description != null && overview!.description!.isNotEmpty)
            Text(
              overview.description!,
              style: Theme.of(context).textTheme.bodySmall,
            )
          else
            Text(
              '${_cattle!.name} is one of our top milk producers. She has a calm temperament and adapts well to changes in routine.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          const SizedBox(height: 15),
          if (overview?.weight != null || overview?.height != null)
            Row(
              children: [
                if (overview?.weight != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weight',
                           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                       
                        Text(
                          '${overview!.weight!.toInt()} kg',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                if (overview?.height != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Height',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                        ),
                        
                        Text(
                          '${overview!.height!.toInt()} cm',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          if (overview?.diet != null) ...[
            const SizedBox(height: 15),
            Text(
              'Diet',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 15),
            Text(
              overview!.diet,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBreedingTab() {
    final breeding = _cattle!.breedingStatus;
    final dateFormat = DateFormat('dd/MM/yyyy');

    if (breeding == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Center(child: Text('No breeding information available.')),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Breeding Status',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pregnancy status',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                    ),
                    Text(
                      breeding.pragnancyStatus ? 'Pregnant' : 'Not pregnant',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last Calving',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                    ),
                    Text(
                      dateFormat.format(breeding.lastCalving),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Number of Calves',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.tertiary,
                ),
          ),
          Text(
            breeding.numberOfCalves.toString(),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedProducts() {
    if (_relatedProducts.isEmpty && !_isLoadingRelated) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ProductSlider(
        products: _relatedProducts,
        isLoading: _isLoadingRelated,
        title: 'Related Products',
        onSeeAll: _cattle?.cattleCategory != null
            ? () {
                if (widget.onNavigateToProducts != null) {
                  widget.onNavigateToProducts!(
                    cattleCategoryId: _cattle!.cattleCategory!.id,
                  );
                }
              }
            : null,
        onProductTap: (product) {
          if (widget.onNavigateToProductDetails != null) {
            widget.onNavigateToProductDetails!(product.id);
          }
        },
        onAddToCart: (product) async {
          final cartProvider = Provider.of<CartProvider>(context, listen: false);
          final success = await cartProvider.addToCart(
            product,
            quantity: 1,
            size: 1.0,
          );
          
          if (mounted) {
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Added "${product.title}" to cart'),
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  duration: const Duration(seconds: 2),
                ),
              );
            } else {
              showCustomDialog(
                context: context,
                title: 'Cannot Add to Cart',
                message: 'Not enough stock available or product is out of stock.',
                onConfirm: () {},
                showCancel: false,
              );
            }
          }
        },
      ),
    );
  }
}

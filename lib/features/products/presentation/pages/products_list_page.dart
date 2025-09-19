import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/config/app_config.dart';
import '../providers/products_provider.dart';
import '../../../home/presentation/widgets/product_card.dart';
import '../widgets/products_filter_sheet.dart';

class ProductsListPage extends StatefulWidget {
  final String title;
  final String? category;
  final bool isFeatured;

  const ProductsListPage({
    super.key,
    required this.title,
    this.category,
    this.isFeatured = false,
  });

  @override
  State<ProductsListPage> createState() => _ProductsListPageState();
}

class _ProductsListPageState extends State<ProductsListPage> {
  @override
  void initState() {
    super.initState();
    // تأخير تحميل المنتجات حتى اكتمال مرحلة البناء
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProducts();
    });
  }

  Future<void> _loadProducts() async {
    final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
    await productsProvider.loadProducts();

    if (widget.category != null) {
      productsProvider.filterByCategory(widget.category);
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ProductsFilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: _showFilterSheet,
            icon: Icon(
              Icons.tune,
              color: AppTheme.neonBlue,
            ),
          ),
        ],
      ),
      body: Consumer<ProductsProvider>(
        builder: (context, productsProvider, child) {
          if (productsProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: AppTheme.neonBlue,
              ),
            );
          }

          var products = productsProvider.products;

          if (widget.isFeatured) {
            products = products.where((product) => product.isFeatured).toList();
          }

          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_florist_outlined,
                    size: 100,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد منتجات',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'لم يتم العثور على منتجات في هذه الفئة',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadProducts,
            color: AppTheme.neonBlue,
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductCard(
                  product: product,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppConfig.productDetailsRoute,
                      arguments: {'productId': product.id},
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
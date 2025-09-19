import 'package:flutter/material.dart';

import '../../../../core/models/product_model.dart';
import '../../../../core/config/app_config.dart';
import '../../../home/presentation/widgets/product_card.dart';

class SearchResultsGrid extends StatelessWidget {
  final List<ProductModel> products;

  const SearchResultsGrid({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
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
    );
  }
}
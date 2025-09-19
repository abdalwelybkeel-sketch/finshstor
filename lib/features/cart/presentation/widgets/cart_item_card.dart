import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/models/cart_model.dart';
import '../../../../core/theme/app_theme.dart';

class CartItemCard extends StatelessWidget {
  final CartItemModel item;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.neonBlue.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: item.productImage.isNotEmpty 
                    ? item.productImage 
                    : 'https://images.pexels.com/photos/1070850/pexels-photo-1070850.jpeg',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 80,
                  height: 80,
                  color: AppTheme.neonPurple.withOpacity(0.3),
                  child: Icon(
                    Icons.local_florist,
                    color: AppTheme.neonBlue,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 80,
                  height: 80,
                  color: AppTheme.neonPurple.withOpacity(0.3),
                  child: Icon(
                    Icons.local_florist,
                    color: AppTheme.neonBlue,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    item.productName,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Product Options
                  if (item.selectedSize != null || item.selectedColor != null) ...[
                    Row(
                      children: [
                        if (item.selectedSize != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.neonPurple.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.selectedSize!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.neonBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (item.selectedColor != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.darkGlowingWhite.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.selectedColor!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.darkNeonPurple,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],

                  // Additional Options
                  if (item.giftWrap != null || item.greetingCard != null) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.giftWrap != null)
                          Text(
                            'التغليف: ${item.giftWrap}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onBackground.withOpacity(0.6),
                            ),
                          ),
                        if (item.greetingCard != null)
                          Text(
                            'البطاقة: ${item.greetingCard}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onBackground.withOpacity(0.6),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Price and Quantity Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Text(
                        '${item.totalPrice.toInt()} ر.س',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.neonBlue,
                        ),
                      ),

                      // Quantity Controls
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (item.quantity > 1) {
                                onQuantityChanged(item.quantity - 1);
                              }
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: item.quantity > 1 
                                    ? AppTheme.neonPurple.withOpacity(0.3)
                                    : Colors.grey.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.remove,
                                size: 16,
                                color: item.quantity > 1 
                                    ? AppTheme.neonBlue
                                    : Colors.grey,
                              ),
                            ),
                          ),

                          Container(
                            width: 40,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              item.quantity.toString(),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          GestureDetector(
                            onTap: () {
                              onQuantityChanged(item.quantity + 1);
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppTheme.neonPurple.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.add,
                                size: 16,
                                color: AppTheme.neonBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Remove Button
            IconButton(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('حذف المنتج'),
                    content: Text('هل أنت متأكد من حذف ${item.productName} من السلة؟'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('إلغاء'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(
                          'حذف',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  onRemove();
                }
              },
              icon: Icon(
                Icons.delete_outline,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
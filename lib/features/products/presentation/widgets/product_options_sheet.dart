import 'package:flutter/material.dart';

import '../../../../core/models/product_model.dart';
import '../../../../core/theme/app_theme.dart';

class ProductOptionsSheet extends StatefulWidget {
  final ProductModel product;
  final Function(Map<String, dynamic>) onAddToCart;

  const ProductOptionsSheet({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  @override
  State<ProductOptionsSheet> createState() => _ProductOptionsSheetState();
}

class _ProductOptionsSheetState extends State<ProductOptionsSheet> {
  int _quantity = 1;
  String? _selectedSize;
  String? _selectedColor;
  String? _selectedGiftWrap;
  String? _selectedGreetingCard;

  final List<String> _giftWrapOptions = [
    'بدون تغليف',
    'تغليف هدايا عادي',
    'تغليف هدايا فاخر',
    'تغليف رومانسي',
  ];

  final List<String> _greetingCardOptions = [
    'بدون بطاقة',
    'بطاقة معايدة',
    'بطاقة حب',
    'بطاقة تهنئة',
    'بطاقة شكر',
  ];

  @override
  void initState() {
    super.initState();
    _selectedSize = widget.product.sizes.isNotEmpty ? widget.product.sizes.first : null;
    _selectedColor = widget.product.colors.isNotEmpty ? widget.product.colors.first : null;
    _selectedGiftWrap = _giftWrapOptions.first;
    _selectedGreetingCard = _greetingCardOptions.first;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'خيارات المنتج',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 24),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quantity
                  Text(
                    'الكمية',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _quantity > 1 ? () {
                          setState(() {
                            _quantity--;
                          });
                        } : null,
                        icon: const Icon(Icons.remove),
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.neonPurple.withOpacity(0.3),
                        ),
                      ),
                      Container(
                        width: 60,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          _quantity.toString(),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        onPressed: _quantity < widget.product.stock ? () {
                          setState(() {
                            _quantity++;
                          });
                        } : null,
                        icon: const Icon(Icons.add),
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.neonPurple.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Size Selection
                  if (widget.product.sizes.isNotEmpty) ...[
                    Text(
                      'الحجم',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: widget.product.sizes.map((size) {
                        final isSelected = _selectedSize == size;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedSize = size;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? AppTheme.neonBlue
                                  : AppTheme.neonPurple.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected 
                                    ? AppTheme.neonBlue
                                    : AppTheme.neonPurple,
                              ),
                            ),
                            child: Text(
                              size,
                              style: TextStyle(
                                color: isSelected 
                                    ? Colors.white
                                    : AppTheme.neonBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Color Selection
                  if (widget.product.colors.isNotEmpty) ...[
                    Text(
                      'اللون',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: widget.product.colors.map((color) {
                        final isSelected = _selectedColor == color;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedColor = color;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? AppTheme.darkNeonPurple
                                  : AppTheme.darkGlowingWhite.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected 
                                    ? AppTheme.darkNeonPurple
                                    : AppTheme.darkGlowingWhite,
                              ),
                            ),
                            child: Text(
                              color,
                              style: TextStyle(
                                color: isSelected 
                                    ? Colors.white
                                    : AppTheme.darkNeonPurple,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Gift Wrap
                  Text(
                    'التغليف',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.neonPurple),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedGiftWrap,
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      items: _giftWrapOptions.map((option) {
                        return DropdownMenuItem(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGiftWrap = value;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Greeting Card
                  Text(
                    'بطاقة المعايدة',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.neonPurple),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedGreetingCard,
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      items: _greetingCardOptions.map((option) {
                        return DropdownMenuItem(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGreetingCard = value;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Total Price
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.neonPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.neonPurple.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'الإجمالي',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${(widget.product.finalPrice * _quantity).toInt()} ر.س',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.neonBlue,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onAddToCart({
                          'quantity': _quantity,
                          'size': _selectedSize,
                          'color': _selectedColor,
                          'giftWrap': _selectedGiftWrap != 'بدون تغليف' 
                              ? _selectedGiftWrap 
                              : null,
                          'greetingCard': _selectedGreetingCard != 'بدون بطاقة' 
                              ? _selectedGreetingCard 
                              : null,
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.neonBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'إضافة للسلة',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
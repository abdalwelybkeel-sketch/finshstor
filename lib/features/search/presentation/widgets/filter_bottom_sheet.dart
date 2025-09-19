import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  double _minPrice = 0;
  double _maxPrice = 1000;
  String _sortBy = 'name';
  String? _selectedCategory;

  final List<String> _categories = [
    'باقات الحب',
    'باقات الزفاف',
    'باقات التخرج',
    'باقات المناسبات',
  ];

  final List<Map<String, String>> _sortOptions = [
    {'value': 'name', 'label': 'الاسم'},
    {'value': 'price_low', 'label': 'السعر: من الأقل للأعلى'},
    {'value': 'price_high', 'label': 'السعر: من الأعلى للأقل'},
    {'value': 'rating', 'label': 'التقييم'},
    {'value': 'newest', 'label': 'الأحدث'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'فلترة النتائج',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _minPrice = 0;
                      _maxPrice = 1000;
                      _sortBy = 'name';
                      _selectedCategory = null;
                    });
                  },
                  child: Text(
                    'إعادة تعيين',
                    style: TextStyle(color: AppTheme.neonBlue),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Filter
                  Text(
                    'الفئة',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('جميع الفئات'),
                        selected: _selectedCategory == null,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory =
                            selected ? null : _selectedCategory;
                          });
                        },
                        selectedColor: AppTheme.neonBlue.withOpacity(0.3),
                        checkmarkColor: AppTheme.neonBlue,
                      ),
                      ..._categories.map(
                            (category) => FilterChip(
                          label: Text(category),
                          selected: _selectedCategory == category,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory =
                              selected ? category : null;
                            });
                          },
                          selectedColor: AppTheme.neonBlue.withOpacity(0.3),
                          checkmarkColor: AppTheme.neonBlue,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Price Range
                  Text(
                    'نطاق السعر',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RangeSlider(
                    values: RangeValues(_minPrice, _maxPrice),
                    min: 0,
                    max: 1000,
                    divisions: 20,
                    labels: RangeLabels(
                      '${_minPrice.round()} ر.س',
                      '${_maxPrice.round()} ر.س',
                    ),
                    activeColor: AppTheme.neonBlue,
                    onChanged: (values) {
                      setState(() {
                        _minPrice = values.start;
                        _maxPrice = values.end;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${_minPrice.round()} ر.س'),
                      Text('${_maxPrice.round()} ر.س'),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Sort By
                  Text(
                    'ترتيب حسب',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._sortOptions.map(
                        (option) => RadioListTile<String>(
                      title: Text(option['label']!),
                      value: option['value']!,
                      groupValue: _sortBy,
                      activeColor: AppTheme.neonBlue,
                      onChanged: (value) {
                        setState(() {
                          _sortBy = value!;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, {
                          'category': _selectedCategory,
                          'minPrice': _minPrice,
                          'maxPrice': _maxPrice,
                          'sortBy': _sortBy,
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
                        'تطبيق الفلترة',
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

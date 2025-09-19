import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/search_provider.dart';

class SearchSuggestions extends StatelessWidget {
  const SearchSuggestions({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<SearchProvider>(
      builder: (context, searchProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recent Searches
              if (searchProvider.recentSearches.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'البحث الأخير',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        searchProvider.clearRecentSearches();
                      },
                      child: Text(
                        'مسح الكل',
                        style: TextStyle(color: AppTheme.neonBlue),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...searchProvider.recentSearches.map(
                      (search) => ListTile(
                    leading: Icon(
                      Icons.history,
                      color: theme.colorScheme.onBackground.withOpacity(0.6),
                    ),
                    title: Text(search),
                    onTap: () {
                      searchProvider.searchProducts(search);
                    },
                    trailing: IconButton(
                      onPressed: () {
                        // TODO: remove from recent searches
                      },
                      icon: Icon(
                        Icons.close,
                        color: theme.colorScheme.onBackground.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Popular Searches
              Text(
                'البحث الشائع',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: searchProvider.popularSearches.map((search) {
                  return GestureDetector(
                    onTap: () {
                      searchProvider.searchProducts(search);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.neonPurple.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.neonPurple,
                        ),
                      ),
                      child: Text(
                        search,
                        style: TextStyle(
                          color: AppTheme.neonBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              // Search Tips
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.neonPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.neonPurple.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: AppTheme.neonBlue,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'نصائح البحث',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '• استخدم كلمات مفتاحية بسيطة مثل "ورد أحمر"\n'
                          '• جرب البحث بالفئة مثل "باقات الزفاف"\n'
                          '• استخدم الفلترة لتضييق النتائج\n'
                          '• ابحث بالألوان مثل "ورود بيضاء"',
                      style: TextStyle(height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

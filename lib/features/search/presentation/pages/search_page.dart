import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/search_provider.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/search_results_grid.dart';
import '../widgets/search_suggestions.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadSearchData();
  }

  Future<void> _loadSearchData() async {
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    await searchProvider.loadRecentSearches();
    await searchProvider.loadPopularSearches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('البحث والاستكشاف'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: SearchBarWidget(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: (query) {
                      final searchProvider = Provider.of<SearchProvider>(
                        context,
                        listen: false,
                      );
                      searchProvider.searchProducts(query);
                    },
                    onSubmitted: (query) {
                      final searchProvider = Provider.of<SearchProvider>(
                        context,
                        listen: false,
                      );
                      searchProvider.addToRecentSearches(query);
                      _searchFocusNode.unfocus();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: _showFilterSheet,
                  icon: Icon(
                    Icons.tune,
                    color: AppTheme.neonBlue,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.neonPurple.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search Content
          Expanded(
            child: Consumer<SearchProvider>(
              builder: (context, searchProvider, child) {
                if (searchProvider.searchQuery.isEmpty) {
                  return const SearchSuggestions();
                }

                if (searchProvider.isLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.neonBlue,
                    ),
                  );
                }

                if (searchProvider.searchResults.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 100,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لم يتم العثور على نتائج لـ "${searchProvider.searchQuery}"',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            _searchController.clear();
                            searchProvider.clearSearch();
                          },
                          child: Text(
                            'مسح البحث',
                            style: TextStyle(
                              color: AppTheme.neonBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return SearchResultsGrid(
                  products: searchProvider.searchResults,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
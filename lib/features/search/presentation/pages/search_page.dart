import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/search_provider.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/search_results_grid.dart';
import '../widgets/search_suggestions.dart';
import '../../../home/presentation/widgets/futuristic_background.dart';

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
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          const FuturisticBackground(),
          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.neonBlue.withOpacity(0.2),
                        AppTheme.neonPurple.withOpacity(0.2),
                      ],
                    ),
                  ),
                  child: AppTheme.glassMorphismContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          color: isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'البحث والاستكشاف',
                          style: GoogleFonts.orbitron(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Search Bar
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [AppTheme.darkNeonPurple, AppTheme.darkNeonBlue]
                                : [AppTheme.neonPurple, AppTheme.neonBlue],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: (isDark ? AppTheme.darkNeonPurple : AppTheme.neonPurple)
                                  .withOpacity(0.5),
                              blurRadius: 15,
                              spreadRadius: 0,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: _showFilterSheet,
                          icon: const Icon(
                            Icons.tune,
                            color: Colors.white,
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
                        return AppTheme.glassMorphismContainer(
                          margin: const EdgeInsets.all(20),
                          padding: const EdgeInsets.all(40),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 4,
                                    valueColor: AlwaysStoppedAnimation(
                                      isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'جاري البحث...',
                                  style: GoogleFonts.cairo(
                                    color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (searchProvider.searchResults.isEmpty) {
                        return AppTheme.glassMorphismContainer(
                          margin: const EdgeInsets.all(20),
                          padding: const EdgeInsets.all(40),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 100,
                                  color: isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'لم يتم العثور على نتائج',
                                  style: GoogleFonts.orbitron(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'لـ "${searchProvider.searchQuery}"',
                                  style: GoogleFonts.cairo(
                                    color: isDark ? AppTheme.darkGlowingWhite.withOpacity(0.6) : AppTheme.metallicGray,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                AppTheme.neonButton(
                                  text: 'مسح البحث',
                                  onPressed: () {
                                    _searchController.clear();
                                    searchProvider.clearSearch();
                                  },
                                  color: isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue,
                                  textStyle: GoogleFonts.cairo(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
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
          ),
        ],
        ],
      ),
    );
  }
}
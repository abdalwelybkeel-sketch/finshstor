import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/bottom_navigation_bar.dart';
import '../../../../core/providers/navigation_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../search/presentation/pages/search_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.ultraDarkSpace : const Color(0xFFF8FAFC),
      body: Consumer<NavigationProvider>(
        builder: (context, navigationProvider, child) {
          return IndexedStack(
            index: navigationProvider.currentIndex,
            children: const [
              HomePage(),
              CartPage(),
              SearchPage(),
              ProfilePage(),
            ],
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
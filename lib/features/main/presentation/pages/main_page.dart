import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/bottom_navigation_bar.dart';
import '../../../../core/providers/navigation_provider.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../orders/presentation/pages/orders_page.dart';
import '../../../search/presentation/pages/search_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<NavigationProvider>(
        builder: (context, navigationProvider, child) {
          return IndexedStack(
            index: navigationProvider.currentIndex,
            children: const [
              HomePage(),
              CartPage(),
              OrdersPage(),
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
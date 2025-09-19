import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../theme/app_theme.dart';
import '../providers/navigation_provider.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/products/presentation/providers/products_provider.dart';
import '../../features/cart/presentation/providers/cart_provider.dart';
import '../../features/orders/presentation/providers/orders_provider.dart';
import '../../features/vendor/presentation/providers/vendor_provider.dart';

// Import providers that are created
import '../../features/offers/presentation/providers/offers_provider.dart';
import '../../features/search/presentation/providers/search_provider.dart';
import '../../features/addresses/presentation/providers/addresses_provider.dart';
import '../../features/payment/presentation/providers/payment_provider.dart';
import '../../features/notifications/presentation/providers/notifications_provider.dart';
import '../../features/support/presentation/providers/support_provider.dart';
import '../../features/favorites/presentation/providers/favorites_provider.dart';

class AppProviders {
  static List<SingleChildWidget> get providers => [
    // Theme & Locale & Navigation
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ChangeNotifierProvider(create: (_) => LocaleProvider()),
    ChangeNotifierProvider(create: (_) => NavigationProvider()),
    
    // Auth
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    
    // Products
    ChangeNotifierProvider(create: (_) => ProductsProvider()),
    
    // Cart
    ChangeNotifierProvider(create: (_) => CartProvider()),
    
    // Orders
    ChangeNotifierProvider(create: (_) => OrdersProvider()),
    
    // Vendor
    ChangeNotifierProvider(create: (_) => VendorProvider()),
    
    // Offers
    ChangeNotifierProvider(create: (_) => OffersProvider()),
    
    // Search
    ChangeNotifierProvider(create: (_) => SearchProvider()),
    
    // Addresses
    ChangeNotifierProvider(create: (_) => AddressesProvider()),
    
    // Payment
    ChangeNotifierProvider(create: (_) => PaymentProvider()),
    
    // Notifications
    ChangeNotifierProvider(create: (_) => NotificationsProvider()),
    
    // Support
    ChangeNotifierProvider(create: (_) => SupportProvider()),
    
    // Favorites
    ChangeNotifierProvider(create: (_) => FavoritesProvider()),
  ];
}
import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/main/presentation/pages/main_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/products/presentation/pages/product_details_page.dart';
import '../../features/products/presentation/pages/products_list_page.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/orders/presentation/pages/orders_page.dart';
import '../../features/orders/presentation/pages/order_details_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/vendor/presentation/pages/vendor_dashboard_page.dart';
import '../../features/addresses/presentation/pages/addresses_page.dart';
import '../../features/payment/presentation/pages/payment_methods_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/support/presentation/pages/support_page.dart';
import '../../features/favorites/presentation/pages/favorites_page.dart';
import '../../features/offers/presentation/pages/offers_page.dart';
import '../../features/search/presentation/pages/search_page.dart';

// Import pages that are created dynamically
import '../../features/vendor/presentation/pages/vendor_orders_page.dart';
import '../../features/vendor/presentation/pages/vendor_analytics_page.dart';
import '../../features/profile/presentation/pages/about_page.dart';
import '../../features/profile/presentation/pages/help_page.dart';
import '../../features/notifications/presentation/pages/notification_settings_page.dart';
import '../../features/support/presentation/pages/ticket_details_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/vendor/presentation/pages/add_product_page.dart';
import '../../features/vendor/presentation/pages/manage_products_page.dart';
import '../../features/addresses/presentation/pages/add_address_page.dart';
import '../../features/payment/presentation/pages/add_payment_method_page.dart';
import '../../features/payment/presentation/pages/checkout_page.dart';
import '../../features/support/presentation/pages/create_ticket_page.dart';
import '../../features/offers/presentation/pages/offer_details_page.dart';

class AppConfig {
  static const String appName = 'متجر الورود';
  static const String appVersion = '1.0.0';
  
  // Supported locales
  static const List<Locale> supportedLocales = [
    Locale('ar', 'SA'), // Arabic
    Locale('en', 'US'), // English
  ];
  
  // Default locale
  static const Locale defaultLocale = Locale('ar', 'SA');
  
  // Routes
  static const String splashRoute = '/';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String mainRoute = '/main';
  static const String homeRoute = '/home';
  static const String productDetailsRoute = '/product-details';
  static const String productsListRoute = '/products-list';
  static const String cartRoute = '/cart';
  static const String checkoutRoute = '/checkout';
  static const String ordersRoute = '/orders';
  static const String orderDetailsRoute = '/order-details';
  static const String profileRoute = '/profile';
  static const String editProfileRoute = '/edit-profile';
  static const String addressesRoute = '/addresses';
  static const String addAddressRoute = '/add-address';
  static const String paymentMethodsRoute = '/payment-methods';
  static const String addPaymentMethodRoute = '/add-payment-method';
  static const String notificationsRoute = '/notifications';
  static const String supportRoute = '/support';
  static const String createTicketRoute = '/create-ticket';
  static const String favoritesRoute = '/favorites';
  static const String offersRoute = '/offers';
  static const String offerDetailsRoute = '/offer-details';
  static const String searchRoute = '/search';
  static const String vendorDashboardRoute = '/vendor-dashboard';
  static const String addProductRoute = '/add-product';
  static const String manageProductsRoute = '/manage-products';
  static const String vendorOrdersRoute = '/vendor-orders';
  static const String vendorAnalyticsRoute = '/vendor-analytics';
  static const String aboutRoute = '/about';
  static const String helpRoute = '/help';
  static const String notificationSettingsRoute = '/notification-settings';
  static const String ticketDetailsRoute = '/ticket-details';
  
  // Generate routes
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case loginRoute:
        return _createRoute(const LoginPage());
      case registerRoute:
        return _createRoute(const RegisterPage());
      case mainRoute:
        return _createRoute(const MainPage());
      case homeRoute:
        return _createRoute(const HomePage());
      case productDetailsRoute:
        final args = settings.arguments as Map<String, dynamic>?;
        return _createRoute(ProductDetailsPage(productId: args?['productId'] ?? ''));
      case productsListRoute:
        final args = settings.arguments as Map<String, dynamic>?;
        return _createRoute(ProductsListPage(
          title: args?['title'] ?? 'المنتجات',
          category: args?['category'],
          isFeatured: args?['isFeatured'] ?? false,
        ));
      case cartRoute:
        return _createRoute(const CartPage());
      case checkoutRoute:
        return _createRoute(const CheckoutPage());
      case ordersRoute:
        return _createRoute(const OrdersPage());
      case orderDetailsRoute:
        final args = settings.arguments as Map<String, dynamic>?;
        return _createRoute(OrderDetailsPage(orderId: args?['orderId'] ?? ''));
      case profileRoute:
        return _createRoute(const ProfilePage());
      case editProfileRoute:
        return _createRoute(const EditProfilePage());
      case addressesRoute:
        return _createRoute(const AddressesPage());
      case addAddressRoute:
        final args = settings.arguments as Map<String, dynamic>?;
        return _createRoute(AddAddressPage(address: args?['address']));
      case paymentMethodsRoute:
        return _createRoute(const PaymentMethodsPage());
      case addPaymentMethodRoute:
        return _createRoute(const AddPaymentMethodPage());
      case notificationsRoute:
        return _createRoute(const NotificationsPage());
      case supportRoute:
        return _createRoute(const SupportPage());
      case createTicketRoute:
        return _createRoute(const CreateTicketPage());
      case favoritesRoute:
        return _createRoute(const FavoritesPage());
      case offersRoute:
        return _createRoute(const OffersPage());
      case offerDetailsRoute:
        final args = settings.arguments as Map<String, dynamic>?;
        return _createRoute(OfferDetailsPage(offerId: args?['offerId'] ?? ''));
      case searchRoute:
        return _createRoute(const SearchPage());
      case vendorDashboardRoute:
        return _createRoute(const VendorDashboardPage());
      case addProductRoute:
        return _createRoute(const AddProductPage());
      case manageProductsRoute:
        return _createRoute(const ManageProductsPage());
      case vendorOrdersRoute:
        return _createRoute(const VendorOrdersPage());
      case vendorAnalyticsRoute:
        return _createRoute(const VendorAnalyticsPage());
      case aboutRoute:
        return _createRoute(const AboutPage());
      case helpRoute:
        return _createRoute(const HelpPage());
      case notificationSettingsRoute:
        return _createRoute(const NotificationSettingsPage());
      case ticketDetailsRoute:
        final args = settings.arguments as Map<String, dynamic>?;
        return _createRoute(TicketDetailsPage(ticketId: args?['ticketId'] ?? ''));
      default:
        return null;
    }
  }
  
  static PageRouteBuilder _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;
        
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
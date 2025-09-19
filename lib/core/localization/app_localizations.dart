import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }
  
  static const LocalizationsDelegate<AppLocalizations> delegate = 
      _AppLocalizationsDelegate();
  
  // Common
  String get appName => _localizedValues[locale.languageCode]!['app_name']!;
  String get welcome => _localizedValues[locale.languageCode]!['welcome']!;
  String get loading => _localizedValues[locale.languageCode]!['loading']!;
  String get error => _localizedValues[locale.languageCode]!['error']!;
  String get success => _localizedValues[locale.languageCode]!['success']!;
  String get cancel => _localizedValues[locale.languageCode]!['cancel']!;
  String get confirm => _localizedValues[locale.languageCode]!['confirm']!;
  String get save => _localizedValues[locale.languageCode]!['save']!;
  String get delete => _localizedValues[locale.languageCode]!['delete']!;
  String get edit => _localizedValues[locale.languageCode]!['edit']!;
  String get add => _localizedValues[locale.languageCode]!['add']!;
  String get search => _localizedValues[locale.languageCode]!['search']!;
  String get filter => _localizedValues[locale.languageCode]!['filter']!;
  String get sort => _localizedValues[locale.languageCode]!['sort']!;
  
  // Auth
  String get login => _localizedValues[locale.languageCode]!['login']!;
  String get register => _localizedValues[locale.languageCode]!['register']!;
  String get logout => _localizedValues[locale.languageCode]!['logout']!;
  String get email => _localizedValues[locale.languageCode]!['email']!;
  String get password => _localizedValues[locale.languageCode]!['password']!;
  String get confirmPassword => _localizedValues[locale.languageCode]!['confirm_password']!;
  String get forgotPassword => _localizedValues[locale.languageCode]!['forgot_password']!;
  String get resetPassword => _localizedValues[locale.languageCode]!['reset_password']!;
  String get fullName => _localizedValues[locale.languageCode]!['full_name']!;
  String get phoneNumber => _localizedValues[locale.languageCode]!['phone_number']!;
  String get signInWithGoogle => _localizedValues[locale.languageCode]!['sign_in_with_google']!;
  String get signInWithApple => _localizedValues[locale.languageCode]!['sign_in_with_apple']!;
  
  // Products
  String get products => _localizedValues[locale.languageCode]!['products']!;
  String get productDetails => _localizedValues[locale.languageCode]!['product_details']!;
  String get price => _localizedValues[locale.languageCode]!['price']!;
  String get description => _localizedValues[locale.languageCode]!['description']!;
  String get category => _localizedValues[locale.languageCode]!['category']!;
  String get inStock => _localizedValues[locale.languageCode]!['in_stock']!;
  String get outOfStock => _localizedValues[locale.languageCode]!['out_of_stock']!;
  String get addToCart => _localizedValues[locale.languageCode]!['add_to_cart']!;
  String get buyNow => _localizedValues[locale.languageCode]!['buy_now']!;
  
  // Cart
  String get cart => _localizedValues[locale.languageCode]!['cart']!;
  String get cartEmpty => _localizedValues[locale.languageCode]!['cart_empty']!;
  String get quantity => _localizedValues[locale.languageCode]!['quantity']!;
  String get total => _localizedValues[locale.languageCode]!['total']!;
  String get subtotal => _localizedValues[locale.languageCode]!['subtotal']!;
  String get tax => _localizedValues[locale.languageCode]!['tax']!;
  String get shipping => _localizedValues[locale.languageCode]!['shipping']!;
  String get checkout => _localizedValues[locale.languageCode]!['checkout']!;
  
  // Orders
  String get orders => _localizedValues[locale.languageCode]!['orders']!;
  String get orderHistory => _localizedValues[locale.languageCode]!['order_history']!;
  String get orderDetails => _localizedValues[locale.languageCode]!['order_details']!;
  String get orderStatus => _localizedValues[locale.languageCode]!['order_status']!;
  String get pending => _localizedValues[locale.languageCode]!['pending']!;
  String get processing => _localizedValues[locale.languageCode]!['processing']!;
  String get shipped => _localizedValues[locale.languageCode]!['shipped']!;
  String get delivered => _localizedValues[locale.languageCode]!['delivered']!;
  String get cancelled => _localizedValues[locale.languageCode]!['cancelled']!;
  
  // Profile
  String get profile => _localizedValues[locale.languageCode]!['profile']!;
  String get settings => _localizedValues[locale.languageCode]!['settings']!;
  String get darkMode => _localizedValues[locale.languageCode]!['dark_mode']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get notifications => _localizedValues[locale.languageCode]!['notifications']!;
  String get addresses => _localizedValues[locale.languageCode]!['addresses']!;
  String get paymentMethods => _localizedValues[locale.languageCode]!['payment_methods']!;
  
  // Vendor
  String get vendorDashboard => _localizedValues[locale.languageCode]!['vendor_dashboard']!;
  String get myProducts => _localizedValues[locale.languageCode]!['my_products']!;
  String get addProduct => _localizedValues[locale.languageCode]!['add_product']!;
  String get editProduct => _localizedValues[locale.languageCode]!['edit_product']!;
  String get sales => _localizedValues[locale.languageCode]!['sales']!;
  String get revenue => _localizedValues[locale.languageCode]!['revenue']!;
  String get analytics => _localizedValues[locale.languageCode]!['analytics']!;
  
  static const Map<String, Map<String, String>> _localizedValues = {
    'ar': {
      'app_name': 'متجر الورود',
      'welcome': 'مرحباً',
      'loading': 'جاري التحميل...',
      'error': 'خطأ',
      'success': 'نجح',
      'cancel': 'إلغاء',
      'confirm': 'تأكيد',
      'save': 'حفظ',
      'delete': 'حذف',
      'edit': 'تعديل',
      'add': 'إضافة',
      'search': 'بحث',
      'filter': 'تصفية',
      'sort': 'ترتيب',
      
      // Auth
      'login': 'تسجيل الدخول',
      'register': 'إنشاء حساب',
      'logout': 'تسجيل الخروج',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'confirm_password': 'تأكيد كلمة المرور',
      'forgot_password': 'نسيت كلمة المرور؟',
      'reset_password': 'إعادة تعيين كلمة المرور',
      'full_name': 'الاسم الكامل',
      'phone_number': 'رقم الهاتف',
      'sign_in_with_google': 'تسجيل الدخول بجوجل',
      'sign_in_with_apple': 'تسجيل الدخول بآبل',
      
      // Products
      'products': 'المنتجات',
      'product_details': 'تفاصيل المنتج',
      'price': 'السعر',
      'description': 'الوصف',
      'category': 'الفئة',
      'in_stock': 'متوفر',
      'out_of_stock': 'غير متوفر',
      'add_to_cart': 'إضافة للسلة',
      'buy_now': 'اشتري الآن',
      
      // Cart
      'cart': 'السلة',
      'cart_empty': 'السلة فارغة',
      'quantity': 'الكمية',
      'total': 'الإجمالي',
      'subtotal': 'المجموع الفرعي',
      'tax': 'الضريبة',
      'shipping': 'الشحن',
      'checkout': 'الدفع',
      
      // Orders
      'orders': 'الطلبات',
      'order_history': 'تاريخ الطلبات',
      'order_details': 'تفاصيل الطلب',
      'order_status': 'حالة الطلب',
      'pending': 'في الانتظار',
      'processing': 'قيد المعالجة',
      'shipped': 'تم الشحن',
      'delivered': 'تم التسليم',
      'cancelled': 'ملغي',
      
      // Profile
      'profile': 'الملف الشخصي',
      'settings': 'الإعدادات',
      'dark_mode': 'الوضع الداكن',
      'language': 'اللغة',
      'notifications': 'الإشعارات',
      'addresses': 'العناوين',
      'payment_methods': 'طرق الدفع',
      
      // Vendor
      'vendor_dashboard': 'لوحة التاجر',
      'my_products': 'منتجاتي',
      'add_product': 'إضافة منتج',
      'edit_product': 'تعديل المنتج',
      'sales': 'المبيعات',
      'revenue': 'الإيرادات',
      'analytics': 'التحليلات',
    },
    'en': {
      'app_name': 'Roses Store',
      'welcome': 'Welcome',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'search': 'Search',
      'filter': 'Filter',
      'sort': 'Sort',
      
      // Auth
      'login': 'Login',
      'register': 'Register',
      'logout': 'Logout',
      'email': 'Email',
      'password': 'Password',
      'confirm_password': 'Confirm Password',
      'forgot_password': 'Forgot Password?',
      'reset_password': 'Reset Password',
      'full_name': 'Full Name',
      'phone_number': 'Phone Number',
      'sign_in_with_google': 'Sign in with Google',
      'sign_in_with_apple': 'Sign in with Apple',
      
      // Products
      'products': 'Products',
      'product_details': 'Product Details',
      'price': 'Price',
      'description': 'Description',
      'category': 'Category',
      'in_stock': 'In Stock',
      'out_of_stock': 'Out of Stock',
      'add_to_cart': 'Add to Cart',
      'buy_now': 'Buy Now',
      
      // Cart
      'cart': 'Cart',
      'cart_empty': 'Cart is Empty',
      'quantity': 'Quantity',
      'total': 'Total',
      'subtotal': 'Subtotal',
      'tax': 'Tax',
      'shipping': 'Shipping',
      'checkout': 'Checkout',
      
      // Orders
      'orders': 'Orders',
      'order_history': 'Order History',
      'order_details': 'Order Details',
      'order_status': 'Order Status',
      'pending': 'Pending',
      'processing': 'Processing',
      'shipped': 'Shipped',
      'delivered': 'Delivered',
      'cancelled': 'Cancelled',
      
      // Profile
      'profile': 'Profile',
      'settings': 'Settings',
      'dark_mode': 'Dark Mode',
      'language': 'Language',
      'notifications': 'Notifications',
      'addresses': 'Addresses',
      'payment_methods': 'Payment Methods',
      
      // Vendor
      'vendor_dashboard': 'Vendor Dashboard',
      'my_products': 'My Products',
      'add_product': 'Add Product',
      'edit_product': 'Edit Product',
      'sales': 'Sales',
      'revenue': 'Revenue',
      'analytics': 'Analytics',
    },
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  
  @override
  bool isSupported(Locale locale) {
    return ['ar', 'en'].contains(locale.languageCode);
  }
  
  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }
  
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/order_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../orders/presentation/providers/orders_provider.dart';
import '../../../addresses/presentation/providers/addresses_provider.dart';
import '../../../payment/presentation/providers/payment_provider.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cashOnDelivery;
  AddressModel? _selectedAddress;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final addressesProvider = Provider.of<AddressesProvider>(context, listen: false);
    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);

    if (authProvider.isAuthenticated) {
      await addressesProvider.loadAddresses(authProvider.currentUser!.id);
      await paymentProvider.loadPaymentMethods(authProvider.currentUser!.id);

      // Set default address
      final defaultAddress = addressesProvider.addresses
          .where((address) => address.isDefault)
          .firstOrNull;
      if (defaultAddress != null) {
        setState(() {
          _selectedAddress = defaultAddress;
        });
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (_selectedAddress == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى اختيار عنوان التوصيل')),
        );
      }
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);

    if (!authProvider.isAuthenticated || cartProvider.items.isEmpty) {
      if (kDebugMode) {
        print('CheckoutPage: Cannot place order. Authenticated: ${authProvider.isAuthenticated}, Cart items: ${cartProvider.items.length}');
      }
      return;
    }

    // Get vendorId from the first item (assuming all items are from the same vendor)
    String? vendorId;
    if (cartProvider.items.isNotEmpty) {
      vendorId = cartProvider.items.first.vendorId;
      if (vendorId == null || vendorId.isEmpty) {
        if (kDebugMode) {
          print('CheckoutPage: No valid vendorId found in cart items');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطأ: لا يمكن إنشاء الطلب بدون بائع')),
        );
        return;
      }
    } else {
      if (kDebugMode) {
        print('CheckoutPage: Cart is empty');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('السلة فارغة')),
      );
      return;
    }

    // Validate that all items have the same vendorId
    final allSameVendor = cartProvider.items.every((item) => item.vendorId == vendorId);
    if (!allSameVendor) {
      if (kDebugMode) {
        print('CheckoutPage: Cart contains items from multiple vendors');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار منتجات من بائع واحد فقط')),
      );
      return;
    }

    if (kDebugMode) {
      print('CheckoutPage: Placing order with vendorId: $vendorId');
    }

    final order = await ordersProvider.createOrder(
      userId: authProvider.currentUser!.id,
      userEmail: authProvider.currentUser!.email,
      userName: authProvider.currentUser!.fullName,
      vendorId: vendorId,
      items: cartProvider.items,
      subtotal: cartProvider.subtotal,
      tax: cartProvider.tax,
      shipping: cartProvider.shipping,
      total: cartProvider.total,
      paymentMethod: _selectedPaymentMethod,
      shippingAddress: {
        'name': _selectedAddress!.name,
        'address': _selectedAddress!.address,
        'city': _selectedAddress!.city,
        'phone': _selectedAddress!.phone,
      },
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    if (order != null && mounted) {
      // Clear cart
      await cartProvider.clearCart(authProvider.currentUser!.id);

      // Navigate to order confirmation
      Navigator.pushReplacementNamed(
        context,
        '/order-details',
        arguments: {'orderId': order.id},
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم إنشاء الطلب بنجاح'),
          backgroundColor: AppTheme.neonBlue,
        ),
      );
    } else {
      if (kDebugMode) {
        print('CheckoutPage: Failed to create order');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل إنشاء الطلب')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إتمام الطلب'),
      ),
      body: Consumer3<CartProvider, AddressesProvider, PaymentProvider>(
        builder: (context, cartProvider, addressesProvider, paymentProvider, child) {
          if (cartProvider.items.isEmpty) {
            return const Center(
              child: Text('السلة فارغة'),
            );
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order Items
                      Text(
                        'المنتجات',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...cartProvider.items.map((item) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item.productImage.isNotEmpty
                                      ? item.productImage
                                      : 'https://images.pexels.com/photos/1070850/pexels-photo-1070850.jpeg',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 60,
                                      height: 60,
                                      color: AppTheme.neonPurple.withOpacity(0.3),
                                      child: Icon(
                                        Icons.local_florist,
                                        color: AppTheme.neonBlue,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.productName,
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'الكمية: ${item.quantity}',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${item.totalPrice.toInt()} ر.س',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.neonBlue,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),

                      const SizedBox(height: 24),

                      // Delivery Address
                      Text(
                        'عنوان التوصيل',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_selectedAddress != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.neonBlue),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedAddress!.name,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(_selectedAddress!.address),
                              Text(_selectedAddress!.city),
                              Text(_selectedAddress!.phone),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red),
                          ),
                          child: const Text(
                            'يرجى اختيار عنوان التوصيل',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Payment Method
                      Text(
                        'طريقة الدفع',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      RadioListTile<PaymentMethod>(
                        title: const Text('الدفع عند الاستلام'),
                        value: PaymentMethod.cashOnDelivery,
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod = value!;
                          });
                        },
                        activeColor: AppTheme.neonBlue,
                      ),
                      RadioListTile<PaymentMethod>(
                        title: const Text('بطاقة ائتمان'),
                        value: PaymentMethod.stripe,
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod = value!;
                          });
                        },
                        activeColor: AppTheme.neonBlue,
                      ),

                      const SizedBox(height: 24),

                      // Notes
                      Text(
                        'ملاحظات إضافية',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          hintText: 'أي ملاحظات خاصة بالطلب...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),

              // Order Summary
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('المجموع الفرعي'),
                        Text('${cartProvider.subtotal.toInt()} ر.س'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('الضريبة'),
                        Text('${cartProvider.tax.toInt()} ر.س'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('الشحن'),
                        Text('${cartProvider.shipping.toInt()} ر.س'),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'الإجمالي',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${cartProvider.total.toInt()} ر.س',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.neonBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _placeOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.neonBlue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'تأكيد الطلب',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
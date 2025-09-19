import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/offers_provider.dart';
import '../widgets/offer_card.dart';
import '../widgets/coupon_card.dart';

class OffersPage extends StatefulWidget {
  const OffersPage({super.key});

  @override
  State<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    final offersProvider = Provider.of<OffersProvider>(context, listen: false);
    await offersProvider.loadOffers();
    await offersProvider.loadCoupons();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('العروض والكوبونات'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.neonBlue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.neonBlue,
          tabs: const [
            Tab(text: 'العروض الخاصة'),
            Tab(text: 'كوبونات الخصم'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOffersTab(),
          _buildCouponsTab(),
        ],
      ),
    );
  }

  Widget _buildOffersTab() {
    return Consumer<OffersProvider>(
      builder: (context, offersProvider, child) {
        if (offersProvider.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: AppTheme.neonBlue,
            ),
          );
        }

        if (offersProvider.offers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_offer_outlined,
                  size: 100,
                  color: Colors.grey.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'لا توجد عروض متاحة حالياً',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadOffers,
          color: AppTheme.neonBlue,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: offersProvider.offers.length,
            itemBuilder: (context, index) {
              final offer = offersProvider.offers[index];
              return OfferCard(
                offer: offer,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/offer-details',
                    arguments: {'offerId': offer.id},
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCouponsTab() {
    return Consumer<OffersProvider>(
      builder: (context, offersProvider, child) {
        if (offersProvider.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: AppTheme.neonBlue,
            ),
          );
        }

        if (offersProvider.coupons.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.confirmation_number_outlined,
                  size: 100,
                  color: Colors.grey.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'لا توجد كوبونات متاحة حالياً',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadOffers,
          color: AppTheme.neonBlue,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: offersProvider.coupons.length,
            itemBuilder: (context, index) {
              final coupon = offersProvider.coupons[index];
              return CouponCard(
                coupon: coupon,
                onCopy: () {
                  // Copy coupon code to clipboard
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم نسخ كود الخصم: ${coupon.code}'),
                      backgroundColor: AppTheme.neonBlue,
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/offers_provider.dart';

class OfferDetailsPage extends StatefulWidget {
  final String offerId;

  const OfferDetailsPage({
    super.key,
    required this.offerId,
  });

  @override
  State<OfferDetailsPage> createState() => _OfferDetailsPageState();
}

class _OfferDetailsPageState extends State<OfferDetailsPage> {
  OfferModel? _offer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOffer();
  }

  Future<void> _loadOffer() async {
    final offersProvider = Provider.of<OffersProvider>(context, listen: false);
    final offer = await offersProvider.getOffer(widget.offerId);
    
    setState(() {
      _offer = offer;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.neonBlue,
          ),
        ),
      );
    }

    if (_offer == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('العرض غير موجود'),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppTheme.neonBlue,
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: _offer!.image.isNotEmpty 
                    ? _offer!.image 
                    : 'https://images.pexels.com/photos/1070850/pexels-photo-1070850.jpeg',
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppTheme.neonPurple.withOpacity(0.3),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.neonBlue,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppTheme.neonPurple.withOpacity(0.3),
                  child: Icon(
                    Icons.local_florist,
                    color: AppTheme.neonBlue,
                    size: 64,
                  ),
                ),
              ),
            ),
          ),

          // Offer Details
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Discount Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'خصم ${_offer!.discount.toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Title
                    Text(
                      _offer!.title,
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Description
                    Text(
                      _offer!.description,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Validity Period
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
                                Icons.access_time,
                                color: AppTheme.neonBlue,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'فترة العرض',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'من ${DateFormat('dd/MM/yyyy', 'ar').format(_offer!.startDate)} إلى ${DateFormat('dd/MM/yyyy', 'ar').format(_offer!.endDate)}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Terms and Conditions
                    Text(
                      'الشروط والأحكام',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '• العرض ساري لفترة محدودة\n'
                      '• لا يمكن دمج هذا العرض مع عروض أخرى\n'
                      '• العرض قابل للتطبيق على المنتجات المحددة فقط\n'
                      '• الشركة تحتفظ بحق تعديل أو إلغاء العرض في أي وقت',
                      style: TextStyle(height: 1.6),
                    ),

                    const SizedBox(height: 32),

                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppConfig.productsListRoute);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.neonBlue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'تسوق الآن',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
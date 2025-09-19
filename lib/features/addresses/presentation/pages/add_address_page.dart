import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:math' as math;

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/addresses_provider.dart';
import '../../../home/presentation/widgets/futuristic_background.dart';

class AddAddressPage extends StatefulWidget {
  final AddressModel? address;

  const AddAddressPage({super.key, this.address});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isDefault = false;

  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  bool _isLoadingLocation = false;

  late AnimationController _animationController;
  late AnimationController _particleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    if (widget.address != null) {
      _nameController.text = widget.address!.name;
      _addressController.text = widget.address!.address;
      _cityController.text = widget.address!.city;
      _phoneController.text = widget.address!.phone;
      _isDefault = widget.address!.isDefault;

      // Set location if available
      if (widget.address!.latitude != null && widget.address!.longitude != null) {
        _selectedLocation = LatLng(
          widget.address!.latitude!,
          widget.address!.longitude!,
        );
      }
    }
    _getCurrentLocation();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _animationController.forward();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'تم رفض إذن الموقع',
                  style: GoogleFonts.cairo(color: Colors.white),
                ),
                backgroundColor: AppTheme.neonPink,
              ),
            );
          }
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition();
      final newLocation = LatLng(position.latitude, position.longitude);

      setState(() {
        _selectedLocation = newLocation;
      });

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(newLocation),
        );
      }

      // Get address from coordinates
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty && mounted) {
        final placemark = placemarks.first;
        setState(() {
          _addressController.text =
          '${placemark.street ?? ''}, ${placemark.subLocality ?? ''}';
          _cityController.text = placemark.locality ?? '';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'فشل في الحصول على الموقع',
              style: GoogleFonts.cairo(color: Colors.white),
            ),
            backgroundColor: AppTheme.neonPink,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _mapController?.dispose();
    _animationController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final addressesProvider = Provider.of<AddressesProvider>(context, listen: false);

    if (!authProvider.isAuthenticated) return;

    bool success;
    if (widget.address == null) {
      // Add new address
      success = await addressesProvider.addAddress(
        userId: authProvider.currentUser!.id,
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        phone: _phoneController.text.trim(),
        latitude: _selectedLocation?.latitude,
        longitude: _selectedLocation?.longitude,
        isDefault: _isDefault,
      );
    } else {
      // Update existing address
      success = await addressesProvider.updateAddress(
        widget.address!.copyWith(
          name: _nameController.text.trim(),
          address: _addressController.text.trim(),
          city: _cityController.text.trim(),
          phone: _phoneController.text.trim(),
          latitude: _selectedLocation?.latitude,
          longitude: _selectedLocation?.longitude,
          isDefault: _isDefault,
        ),
      );
    }

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.address == null ? 'تم إضافة العنوان بنجاح' : 'تم تحديث العنوان بنجاح',
            style: GoogleFonts.cairo(color: Colors.white),
          ),
          backgroundColor: AppTheme.neonBlue,
        ),
      );
    }
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
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      backgroundColor: Colors.transparent,
                      flexibleSpace: Container(
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
                        child: Center(
                          child: Text(
                            widget.address == null ? 'إضافة عنوان جديد' : 'تعديل العنوان',
                            style: GoogleFonts.orbitron(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                            ),
                          ),
                        ),
                      ),
                      actions: [
                        Consumer<AddressesProvider>(
                          builder: (context, addressesProvider, child) {
                            return TextButton(
                              onPressed: addressesProvider.isLoading ? null : () => _saveAddress(),
                              child: Text(
                                'حفظ',
                                style: GoogleFonts.cairo(
                                  color: AppTheme.neonBlue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  shadows: [
                                    Shadow(
                                      color: AppTheme.neonBlue.withOpacity(0.5),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Map
                              AppTheme.glassMorphismContainer(
                                 // Increased height for better visibility
                                margin: const EdgeInsets.only(bottom: 24),
                                child: Container(
                                  height: 300,
                                  child: Stack(
                                    children: [
                                      _selectedLocation == null
                                          ? Center(
                                        child: CircularProgressIndicator(
                                          color: AppTheme.neonBlue,
                                        ),
                                      )
                                          : GoogleMap(
                                        initialCameraPosition: CameraPosition(
                                          target: _selectedLocation!,
                                          zoom: 15,
                                        ),
                                        onMapCreated: (controller) {
                                          _mapController = controller;
                                        },
                                        markers: {
                                          if (_selectedLocation != null)
                                            Marker(
                                              markerId: const MarkerId('selected-location'),
                                              position: _selectedLocation!,
                                            ),
                                        },
                                        onTap: (position) {
                                          setState(() {
                                            _selectedLocation = position;
                                          });
                                          _mapController?.animateCamera(
                                            CameraUpdate.newLatLng(position),
                                          );
                                        },
                                      ),
                                      Positioned(
                                        top: 16,
                                        right: 16,
                                        child: FloatingActionButton(
                                          onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                                          backgroundColor: AppTheme.neonBlue,
                                          mini: true,
                                          child: _isLoadingLocation
                                              ? const CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          )
                                              : const Icon(Icons.my_location, color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Name Field
                              AppTheme.glassMorphismContainer(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: TextFormField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    labelText: 'اسم العنوان (مثال: المنزل، العمل)',
                                    prefixIcon: Icon(Icons.label, color: AppTheme.neonBlue),
                                    labelStyle: GoogleFonts.cairo(
                                      color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                  style: GoogleFonts.cairo(
                                    color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                  ),
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) {
                                      return 'يرجى إدخال اسم العنوان';
                                    }
                                    return null;
                                  },
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Address Field
                              AppTheme.glassMorphismContainer(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: TextFormField(
                                  controller: _addressController,
                                  decoration: InputDecoration(
                                    labelText: 'العنوان',
                                    prefixIcon: Icon(Icons.location_on, color: AppTheme.neonBlue),
                                    labelStyle: GoogleFonts.cairo(
                                      color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                  style: GoogleFonts.cairo(
                                    color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                  ),
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) {
                                      return 'يرجى إدخال العنوان';
                                    }
                                    return null;
                                  },
                                ),
                              ),

                              const SizedBox(height: 16),

                              // City Field
                              AppTheme.glassMorphismContainer(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: TextFormField(
                                  controller: _cityController,
                                  decoration: InputDecoration(
                                    labelText: 'المدينة',
                                    prefixIcon: Icon(Icons.location_city, color: AppTheme.neonBlue),
                                    labelStyle: GoogleFonts.cairo(
                                      color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                  style: GoogleFonts.cairo(
                                    color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                  ),
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) {
                                      return 'يرجى إدخال المدينة';
                                    }
                                    return null;
                                  },
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Phone Field
                              AppTheme.glassMorphismContainer(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: TextFormField(
                                  controller: _phoneController,
                                  decoration: InputDecoration(
                                    labelText: 'رقم الهاتف',
                                    prefixIcon: Icon(Icons.phone, color: AppTheme.neonBlue),
                                    labelStyle: GoogleFonts.cairo(
                                      color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                  style: GoogleFonts.cairo(
                                    color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                  ),
                                  keyboardType: TextInputType.phone,
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) {
                                      return 'يرجى إدخال رقم الهاتف';
                                    }
                                    return null;
                                  },
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Coordinates
                              if (_selectedLocation != null)
                                AppTheme.glassMorphismContainer(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: AppTheme.neonBlue,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'الإحداثيات المحددة',
                                              style: GoogleFonts.cairo(
                                                fontWeight: FontWeight.w600,
                                                color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                              ),
                                            ),
                                            Text(
                                              'خط العرض: ${_selectedLocation!.latitude.toStringAsFixed(6)}',
                                              style: GoogleFonts.cairo(
                                                color: isDark ? AppTheme.darkGlowingWhite.withOpacity(0.6) : AppTheme.metallicGray,
                                              ),
                                            ),
                                            Text(
                                              'خط الطول: ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                                              style: GoogleFonts.cairo(
                                                color: isDark ? AppTheme.darkGlowingWhite.withOpacity(0.6) : AppTheme.metallicGray,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              const SizedBox(height: 24),

                              // Default Address Switch
                              AppTheme.glassMorphismContainer(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.home_outlined,
                                      color: AppTheme.neonBlue,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'العنوان الافتراضي',
                                            style: GoogleFonts.cairo(
                                              fontWeight: FontWeight.w600,
                                              color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                            ),
                                          ),
                                          Text(
                                            'سيتم استخدام هذا العنوان افتراضياً في الطلبات',
                                            style: GoogleFonts.cairo(
                                              color: isDark ? AppTheme.darkGlowingWhite.withOpacity(0.6) : AppTheme.metallicGray,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Switch(
                                      value: _isDefault,
                                      onChanged: (value) {
                                        setState(() {
                                          _isDefault = value;
                                        });
                                      },
                                      activeColor: AppTheme.neonBlue,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Save Button
                              Consumer<AddressesProvider>(
                                builder: (context, addressesProvider, child) {
                                  return SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: addressesProvider.isLoading ? null : _saveAddress,
                                      child: addressesProvider.isLoading
                                          ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                          : Text(widget.address == null ? 'إضافة العنوان' : 'حفظ التغييرات'),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 120),
                            ],
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
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'dart:math' as math;

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../home/presentation/widgets/futuristic_background.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _imageFile;
  String? _imageUrl;
  bool _isUploadingImage = false;

  late AnimationController _animationController;
  late AnimationController _particleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      _fullNameController.text = authProvider.currentUser!.fullName;
      _phoneController.text = authProvider.currentUser!.phoneNumber ?? '';
      _imageUrl = authProvider.currentUser!.profileImage;
    }
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )
      ..repeat();

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

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _animationController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
        await _uploadProfileImage();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'فشل اختيار الصورة',
              style: GoogleFonts.cairo(color: Colors.white),
            ),
            backgroundColor: AppTheme.neonPink,
          ),
        );
      }
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_imageFile == null) return;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final fileName = 'profile_images/${authProvider.currentUser!.id}.jpg';
      final ref = FirebaseStorage.instance.ref().child(fileName);

      final uploadTask = ref.putFile(_imageFile!);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        _imageUrl = downloadUrl;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'فشل رفع الصورة',
              style: GoogleFonts.cairo(color: Colors.white),
            ),
            backgroundColor: AppTheme.neonPink,
          ),
        );
      }
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.updateProfile(
      fullName: _fullNameController.text.trim(),
      phoneNumber: _phoneController.text
          .trim()
          .isEmpty ? null : _phoneController.text.trim(),
      profileImage: _imageUrl,
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم تحديث الملف الشخصي بنجاح',
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
                            'تعديل الملف الشخصي',
                            style: GoogleFonts.orbitron(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppTheme.darkGlowingWhite
                                  : AppTheme.metallicGray,
                            ),
                          ),
                        ),
                      ),
                      actions: [
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            return TextButton(
                              onPressed: authProvider.isLoading ? null : () =>
                                  _saveProfile(),
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
                      child: Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          if (authProvider.currentUser == null) {
                            return Container(
                              margin: const EdgeInsets.all(20),
                              child: AppTheme.glassMorphismContainer(
                                child: Center(
                                  child: Text(
                                    'لا يوجد مستخدم مسجل',
                                    style: GoogleFonts.cairo(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppTheme.darkGlowingWhite
                                          : AppTheme.metallicGray,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }

                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  AnimatedBuilder(
                                    animation: _particleController,
                                    builder: (context, child) {
                                      return AppTheme.glassMorphismContainer(
                                        padding: const EdgeInsets.all(20),
                                        child: Stack(
                                          children: [
                                            CircleAvatar(
                                              radius: 60,
                                              backgroundColor: AppTheme
                                                  .neonPurple,
                                              backgroundImage: _imageFile !=
                                                  null
                                                  ? FileImage(
                                                  _imageFile!) as ImageProvider
                                                  : _imageUrl != null
                                                  ? NetworkImage(
                                                  _imageUrl!) as ImageProvider
                                                  : null,
                                              child: _imageFile == null &&
                                                  _imageUrl == null
                                                  ? Icon(
                                                Icons.person,
                                                size: 60,
                                                color: AppTheme.neonBlue,
                                              )
                                                  : null,
                                            ),
                                            Positioned(
                                              bottom: 0,
                                              right: 0,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: AppTheme.neonBlue,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 2,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: AppTheme.neonBlue
                                                          .withOpacity(
                                                          0.3 + 0.2 * math.sin(
                                                              _particleController
                                                                  .value * 2 *
                                                                  math.pi)),
                                                      blurRadius: 20,
                                                      spreadRadius: 0,
                                                    ),
                                                  ],
                                                ),
                                                child: _isUploadingImage
                                                    ? const Padding(
                                                  padding: EdgeInsets.all(8),
                                                  child: SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor: AlwaysStoppedAnimation<
                                                          Color>(Colors.white),
                                                    ),
                                                  ),
                                                )
                                                    : IconButton(
                                                  onPressed: _pickImage,
                                                  icon: const Icon(
                                                    Icons.camera_alt,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                  constraints: const BoxConstraints(
                                                    minWidth: 40,
                                                    minHeight: 40,
                                                  ),
                                                  padding: EdgeInsets.zero,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 32),
                                  AppTheme.glassMorphismContainer(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    child: TextFormField(
                                      initialValue: authProvider.currentUser!
                                          .email,
                                      decoration: InputDecoration(
                                        labelText: 'البريد الإلكتروني',
                                        prefixIcon: Icon(Icons.email_outlined,
                                            color: AppTheme.neonBlue),
                                        labelStyle: GoogleFonts.cairo(
                                          color: isDark ? AppTheme
                                              .darkGlowingWhite : AppTheme
                                              .metallicGray,
                                        ),
                                        border: InputBorder.none,
                                      ),
                                      enabled: false,
                                      style: GoogleFonts.cairo(
                                        color: isDark ? AppTheme
                                            .darkGlowingWhite : AppTheme
                                            .metallicGray,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  AppTheme.glassMorphismContainer(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    child: TextFormField(
                                      controller: _fullNameController,
                                      decoration: InputDecoration(
                                        labelText: 'الاسم الكامل',
                                        prefixIcon: Icon(Icons.person_outline,
                                            color: AppTheme.neonBlue),
                                        labelStyle: GoogleFonts.cairo(
                                          color: isDark ? AppTheme
                                              .darkGlowingWhite : AppTheme
                                              .metallicGray,
                                        ),
                                        border: InputBorder.none,
                                      ),
                                      style: GoogleFonts.cairo(
                                        color: isDark ? AppTheme
                                            .darkGlowingWhite : AppTheme
                                            .metallicGray,
                                      ),
                                      validator: (value) {
                                        if (value?.isEmpty ?? true) {
                                          return 'يرجى إدخال الاسم الكامل';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  AppTheme.glassMorphismContainer(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    child: TextFormField(
                                      controller: _phoneController,
                                      decoration: InputDecoration(
                                        labelText: 'رقم الهاتف',
                                        prefixIcon: Icon(Icons.phone_outlined,
                                            color: AppTheme.neonBlue),
                                        labelStyle: GoogleFonts.cairo(
                                          color: isDark ? AppTheme
                                              .darkGlowingWhite : AppTheme
                                              .metallicGray,
                                        ),
                                        border: InputBorder.none,
                                      ),
                                      style: GoogleFonts.cairo(
                                        color: isDark ? AppTheme
                                            .darkGlowingWhite : AppTheme
                                            .metallicGray,
                                      ),
                                      keyboardType: TextInputType.phone,
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  AppTheme.glassMorphismContainer(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Icon(
                                          authProvider.currentUser!.isVendor
                                              ? Icons.store
                                              : Icons.person,
                                          color: AppTheme.neonBlue,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment
                                                .start,
                                            children: [
                                              Text(
                                                'نوع الحساب',
                                                style: GoogleFonts.cairo(
                                                  fontWeight: FontWeight.w600,
                                                  color: isDark
                                                      ? AppTheme
                                                      .darkGlowingWhite
                                                      : AppTheme.metallicGray,
                                                ),
                                              ),
                                              Text(
                                                authProvider.currentUser!
                                                    .isVendor
                                                    ? 'حساب تاجر'
                                                    : 'حساب مستخدم',
                                                style: GoogleFonts.cairo(
                                                  color: isDark
                                                      ? AppTheme
                                                      .darkGlowingWhite
                                                      .withOpacity(0.6)
                                                      : AppTheme.metallicGray
                                                      .withOpacity(0.6),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 4),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: authProvider.currentUser!
                                                  .isVendor
                                                  ? [
                                                AppTheme.darkNeonPurple,
                                                AppTheme.neonPurple
                                              ]
                                                  : [
                                                AppTheme.neonBlue,
                                                AppTheme.darkNeonBlue
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                                12),
                                          ),
                                          child: Text(
                                            authProvider.currentUser!.isVendor
                                                ? 'تاجر'
                                                : 'مستخدم',
                                            style: GoogleFonts.cairo(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: authProvider.isLoading ? null : _saveProfile,
                                      child: authProvider.isLoading
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
                                          : const Text('حفظ التغييرات'),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  AppTheme.neonButton(
                                    text: 'حذف الحساب',
                                    onPressed: () async {
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (context) =>
                                            AlertDialog(
                                              backgroundColor: Colors
                                                  .transparent,
                                              content: AppTheme
                                                  .glassMorphismContainer(
                                                child: Column(
                                                  mainAxisSize: MainAxisSize
                                                      .min,
                                                  children: [
                                                    Text(
                                                      'حذف الحساب',
                                                      style: GoogleFonts
                                                          .orbitron(
                                                        fontSize: 20,
                                                        fontWeight: FontWeight
                                                            .bold,
                                                        color: isDark
                                                            ? AppTheme
                                                            .darkGlowingWhite
                                                            : AppTheme
                                                            .metallicGray,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 16),
                                                    Text(
                                                      'هل أنت متأكد من حذف حسابك؟ هذا الإجراء لا يمكن التراجع عنه.',
                                                      style: GoogleFonts.cairo(
                                                        color: isDark
                                                            ? AppTheme
                                                            .darkGlowingWhite
                                                            : AppTheme
                                                            .metallicGray,
                                                        height: 1.5,
                                                      ),
                                                      textAlign: TextAlign
                                                          .center,
                                                    ),
                                                    const SizedBox(height: 24),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment
                                                          .spaceEvenly,
                                                      children: [
                                                        AppTheme.neonButton(
                                                          text: 'إلغاء',
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context,
                                                                  false),
                                                          color: AppTheme
                                                              .neonBlue,
                                                          textStyle: GoogleFonts
                                                              .cairo(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight
                                                                .bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        AppTheme.neonButton(
                                                          text: 'حذف',
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context,
                                                                  true),
                                                          color: AppTheme
                                                              .neonPink,
                                                          textStyle: GoogleFonts
                                                              .cairo(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight
                                                                .bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                      );

                                      if (confirmed == true && mounted) {
                                        ScaffoldMessenger
                                            .of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'ميزة حذف الحساب ستكون متاحة قريباً',
                                              style: GoogleFonts.cairo(
                                                  color: Colors.white),
                                            ),
                                            backgroundColor: AppTheme.neonPink,
                                          ),
                                        );
                                      }
                                    },
                                    color: AppTheme.neonPink,
                                    textStyle: GoogleFonts.cairo(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 16),
                                  ),
                                  const SizedBox(height: 120),
                                ],
                              ),
                            ),
                          );
                        },
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
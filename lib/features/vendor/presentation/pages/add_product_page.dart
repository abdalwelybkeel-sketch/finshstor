import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/vendor_provider.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _discountController = TextEditingController();

  String _selectedCategory = 'باقات الحب';
  bool _isFeatured = false;
  final List<String> _imageUrls = [];
  final List<File> _imageFiles = [];
  final ImagePicker _picker = ImagePicker();
  final List<String> _sizes = [];
  final List<String> _colors = [];
  final List<String> _tags = [];

  final List<String> _categories = [
    'باقات الحب',
    'باقات الزفاف',
    'باقات التخرج',
    'باقات المناسبات',
  ];

  final List<String> _availableSizes = [
    'صغير',
    'متوسط',
    'كبير',
    'كبير جداً',
  ];

  final List<String> _availableColors = [
    'أحمر',
    'أبيض',
    'وردي',
    'أصفر',
    'بنفسجي',
    'برتقالي',
    'متعدد الألوان',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate()) {
      if (kDebugMode) {
        print('AddProductPage: Form validation failed');
      }
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final vendorProvider = Provider.of<VendorProvider>(context, listen: false);

    if (!authProvider.isAuthenticated || !authProvider.currentUser!.isVendor) {
      if (kDebugMode) {
        print('AddProductPage: User is not authenticated or not a vendor');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب أن تكون تاجرًا مصادقًا')),
      );
      return;
    }

    // Upload images first
    if (_imageFiles.isNotEmpty) {
      final success = await _uploadImages();
      if (!success) {
        if (kDebugMode) {
          print('AddProductPage: Image upload failed');
        }
        return;
      }
    }

    // Add default image if no images provided
    if (_imageUrls.isEmpty) {
      _imageUrls.add('https://images.pexels.com/photos/1070850/pexels-photo-1070850.jpeg');
      if (kDebugMode) {
        print('AddProductPage: Using default image');
      }
    }

    final success = await vendorProvider.addProduct(
      vendorId: authProvider.currentUser!.id,
      vendorName: authProvider.currentUser!.fullName,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.parse(_priceController.text),
      images: _imageUrls,
      category: _selectedCategory,
      stock: int.parse(_stockController.text),
      sizes: _sizes,
      colors: _colors,
      tags: _tags,
      isFeatured: _isFeatured,
      discount: _discountController.text.isEmpty
          ? null
          : double.parse(_discountController.text),
    );

    if (success && mounted) {
      if (kDebugMode) {
        print('AddProductPage: Product added successfully');
      }
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم إضافة المنتج بنجاح'),
          backgroundColor: AppTheme.neonBlue,
        ),
      );
    } else {
      if (kDebugMode) {
        print('AddProductPage: Failed to add product');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vendorProvider.errorMessage ?? 'فشل إضافة المنتج'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> _uploadImages() async {
    try {
      final uploadTasks = _imageFiles.asMap().entries.map((entry) async {
        final index = entry.key;
        final file = entry.value;
        final fileName = 'products/${DateTime.now().millisecondsSinceEpoch}_$index.jpg';
        final ref = FirebaseStorage.instance.ref().child(fileName);

        if (kDebugMode) {
          print('AddProductPage: Uploading image $fileName');
        }
        final uploadTask = ref.putFile(file);
        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();
        if (kDebugMode) {
          print('AddProductPage: Uploaded image $fileName, URL: $downloadUrl');
        }
        _imageUrls.add(downloadUrl);
      }).toList();

      await Future.wait(uploadTasks);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('AddProductPage: Error uploading images: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل رفع الصور: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _imageFiles.addAll(images.map((xfile) => File(xfile.path)));
          if (kDebugMode) {
            print('AddProductPage: Picked ${images.length} images');
          }
        });
      } else {
        if (kDebugMode) {
          print('AddProductPage: No images picked');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('AddProductPage: Error picking images: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل اختيار الصور')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة منتج جديد'),
        actions: [
          Consumer<VendorProvider>(
            builder: (context, vendorProvider, child) {
              return TextButton(
                onPressed: vendorProvider.isLoading ? null : _addProduct,
                child: Text(
                  'حفظ',
                  style: TextStyle(
                    color: AppTheme.neonBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Images
              Text(
                'صور المنتج',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _imageFiles.isEmpty && _imageUrls.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 40,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'إضافة صور المنتج',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: _pickImages,
                        child: const Text('اختيار من المعرض'),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imageFiles.length + _imageUrls.length + 1,
                  itemBuilder: (context, index) {
                    final totalImages = _imageFiles.length + _imageUrls.length;
                    if (index == totalImages) {
                      return Container(
                        width: 100,
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          onPressed: _pickImages,
                          icon: const Icon(Icons.add),
                        ),
                      );
                    }
                    return Container(
                      width: 100,
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: index < _imageFiles.length
                                ? Image.file(
                              _imageFiles[index],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 100,
                                  height: 100,
                                  color: AppTheme.neonPurple.withOpacity(0.3),
                                  child: Icon(
                                    Icons.error,
                                    color: AppTheme.neonBlue,
                                  ),
                                );
                              },
                            )
                                : Image.network(
                              _imageUrls[index - _imageFiles.length],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 100,
                                  height: 100,
                                  color: AppTheme.neonPurple.withOpacity(0.3),
                                  child: Icon(
                                    Icons.error,
                                    color: AppTheme.neonBlue,
                                  ),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (index < _imageFiles.length) {
                                    _imageFiles.removeAt(index);
                                  } else {
                                    _imageUrls.removeAt(index - _imageFiles.length);
                                  }
                                  if (kDebugMode) {
                                    print('AddProductPage: Removed image at index $index');
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Product Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم المنتج',
                  prefixIcon: Icon(Icons.local_florist),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'يرجى إدخال اسم المنتج';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'الفئة',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                    if (kDebugMode) {
                      print('AddProductPage: Selected category: $_selectedCategory');
                    }
                  });
                },
              ),

              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'وصف المنتج',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'يرجى إدخال وصف المنتج';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Price and Stock
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'السعر (ر.س)',
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'يرجى إدخال السعر';
                        }
                        if (double.tryParse(value!) == null) {
                          return 'سعر غير صحيح';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      decoration: const InputDecoration(
                        labelText: 'الكمية المتاحة',
                        prefixIcon: Icon(Icons.inventory),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'يرجى إدخال الكمية';
                        }
                        if (int.tryParse(value!) == null) {
                          return 'كمية غير صحيحة';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Discount
              TextFormField(
                controller: _discountController,
                decoration: const InputDecoration(
                  labelText: 'نسبة الخصم (اختياري)',
                  prefixIcon: Icon(Icons.percent),
                  hintText: 'مثال: 10',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final discount = double.tryParse(value);
                    if (discount == null || discount < 0 || discount > 100) {
                      return 'نسبة خصم غير صحيحة (0-100)';
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Sizes
              Text(
                'الأحجام المتاحة',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _availableSizes.map((size) {
                  final isSelected = _sizes.contains(size);
                  return FilterChip(
                    label: Text(size),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _sizes.add(size);
                        } else {
                          _sizes.remove(size);
                        }
                        if (kDebugMode) {
                          print('AddProductPage: Updated sizes: $_sizes');
                        }
                      });
                    },
                    selectedColor: AppTheme.neonBlue.withOpacity(0.3),
                    checkmarkColor: AppTheme.neonBlue,
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Colors
              Text(
                'الألوان المتاحة',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _availableColors.map((color) {
                  final isSelected = _colors.contains(color);
                  return FilterChip(
                    label: Text(color),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _colors.add(color);
                        } else {
                          _colors.remove(color);
                        }
                        if (kDebugMode) {
                          print('AddProductPage: Updated colors: $_colors');
                        }
                      });
                    },
                    selectedColor: AppTheme.darkNeonPurple.withOpacity(0.3),
                    checkmarkColor: AppTheme.darkNeonPurple,
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Featured Product
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.neonPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.neonPurple.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.star_outline,
                      color: AppTheme.neonBlue,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'منتج مميز',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'سيظهر في قسم المنتجات المميزة',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onBackground.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isFeatured,
                      onChanged: (value) {
                        setState(() {
                          _isFeatured = value;
                          if (kDebugMode) {
                            print('AddProductPage: isFeatured set to $_isFeatured');
                          }
                        });
                      },
                      activeColor: AppTheme.neonBlue,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Add Product Button
              Consumer<VendorProvider>(
                builder: (context, vendorProvider, child) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: vendorProvider.isLoading ? null : _addProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.neonBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: vendorProvider.isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                          : const Text(
                        'إضافة المنتج',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/support_provider.dart';

class CreateTicketPage extends StatefulWidget {
  const CreateTicketPage({super.key});

  @override
  State<CreateTicketPage> createState() => _CreateTicketPageState();
}

class _CreateTicketPageState extends State<CreateTicketPage> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'general';
  TicketPriority _selectedPriority = TicketPriority.medium;

  final List<Map<String, String>> _categories = [
    {'value': 'general', 'label': 'استفسار عام'},
    {'value': 'order', 'label': 'مشكلة في الطلب'},
    {'value': 'payment', 'label': 'مشكلة في الدفع'},
    {'value': 'delivery', 'label': 'مشكلة في التوصيل'},
    {'value': 'product', 'label': 'مشكلة في المنتج'},
    {'value': 'account', 'label': 'مشكلة في الحساب'},
    {'value': 'technical', 'label': 'مشكلة تقنية'},
    {'value': 'other', 'label': 'أخرى'},
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createTicket() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final supportProvider = Provider.of<SupportProvider>(context, listen: false);

    if (!authProvider.isAuthenticated) return;

    final success = await supportProvider.createTicket(
      userId: authProvider.currentUser!.id,
      userEmail: authProvider.currentUser!.email,
      userName: authProvider.currentUser!.fullName,
      subject: _subjectController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      priority: _selectedPriority,
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم إنشاء تذكرة الدعم بنجاح'),
          backgroundColor: AppTheme.neonBlue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء تذكرة دعم جديدة'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card
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
                          Icons.info_outline,
                          color: AppTheme.neonBlue,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'معلومات مهمة',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'سيتم الرد على استفسارك خلال 24 ساعة. يرجى تقديم أكبر قدر من التفاصيل لمساعدتنا في حل مشكلتك بسرعة.',
                      style: TextStyle(height: 1.5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Category
              Text(
                'فئة المشكلة',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category['value'],
                    child: Text(category['label']!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Priority
              Text(
                'الأولوية',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<TicketPriority>(
                value: _selectedPriority,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.priority_high_outlined),
                ),
                items: TicketPriority.values.map((priority) {
                  String label;
                  switch (priority) {
                    case TicketPriority.low:
                      label = 'منخفضة';
                      break;
                    case TicketPriority.medium:
                      label = 'متوسطة';
                      break;
                    case TicketPriority.high:
                      label = 'عالية';
                      break;
                    case TicketPriority.urgent:
                      label = 'عاجلة';
                      break;
                  }
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(label),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPriority = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Subject
              Text(
                'موضوع المشكلة',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  hintText: 'اكتب موضوع المشكلة باختصار',
                  prefixIcon: Icon(Icons.subject_outlined),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'يرجى إدخال موضوع المشكلة';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                'وصف المشكلة',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  hintText: 'اشرح المشكلة بالتفصيل...',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'يرجى إدخال وصف المشكلة';
                  }
                  if (value!.length < 20) {
                    return 'يرجى إدخال وصف أكثر تفصيلاً (20 حرف على الأقل)';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Submit Button
              Consumer<SupportProvider>(
                builder: (context, supportProvider, child) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                      supportProvider.isLoading ? null : _createTicket,
                      child: supportProvider.isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Text('إرسال التذكرة'),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Contact Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.neonPurple.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'طرق التواصل الأخرى',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.phone,
                          color: AppTheme.neonBlue,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        const Text('772586514'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.email,
                          color: AppTheme.neonBlue,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        const Text('د/ مختار الشرعبي  - 772586514'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

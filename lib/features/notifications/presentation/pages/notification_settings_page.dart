import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _orderUpdates = true;
  bool _offers = true;
  bool _newProducts = true;
  bool _generalNotifications = true;
  bool _emailNotifications = false;
  bool _smsNotifications = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _orderUpdates = prefs.getBool('order_updates') ?? true;
      _offers = prefs.getBool('offers') ?? true;
      _newProducts = prefs.getBool('new_products') ?? true;
      _generalNotifications = prefs.getBool('general_notifications') ?? true;
      _emailNotifications = prefs.getBool('email_notifications') ?? false;
      _smsNotifications = prefs.getBool('sms_notifications') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('order_updates', _orderUpdates);
    await prefs.setBool('offers', _offers);
    await prefs.setBool('new_products', _newProducts);
    await prefs.setBool('general_notifications', _generalNotifications);
    await prefs.setBool('email_notifications', _emailNotifications);
    await prefs.setBool('sms_notifications', _smsNotifications);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم حفظ إعدادات الإشعارات'),
        backgroundColor: AppTheme.neonBlue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات الإشعارات'),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: Text(
              'حفظ',
              style: TextStyle(
                color: AppTheme.neonBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Push Notifications
            Text(
              'الإشعارات الفورية',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildSettingItem(
              'تحديثات الطلبات',
              'إشعارات حول حالة طلباتك',
              _orderUpdates,
              (value) {
                setState(() {
                  _orderUpdates = value;
                });
              },
            ),

            _buildSettingItem(
              'العروض والخصومات',
              'إشعارات حول العروض الجديدة',
              _offers,
              (value) {
                setState(() {
                  _offers = value;
                });
              },
            ),

            _buildSettingItem(
              'المنتجات الجديدة',
              'إشعارات حول المنتجات الجديدة',
              _newProducts,
              (value) {
                setState(() {
                  _newProducts = value;
                });
              },
            ),

            _buildSettingItem(
              'الإشعارات العامة',
              'إشعارات عامة من التطبيق',
              _generalNotifications,
              (value) {
                setState(() {
                  _generalNotifications = value;
                });
              },
            ),

            const SizedBox(height: 24),

            // Other Notifications
            Text(
              'طرق التواصل الأخرى',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildSettingItem(
              'البريد الإلكتروني',
              'تلقي إشعارات عبر البريد الإلكتروني',
              _emailNotifications,
              (value) {
                setState(() {
                  _emailNotifications = value;
                });
              },
            ),

            _buildSettingItem(
              'الرسائل النصية',
              'تلقي إشعارات عبر الرسائل النصية',
              _smsNotifications,
              (value) {
                setState(() {
                  _smsNotifications = value;
                });
              },
            ),

            const SizedBox(height: 32),

            // Contact Support
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
                        Icons.support_agent,
                        color: AppTheme.neonBlue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'تحتاج مساعدة؟',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'تواصل مع فريق الدعم: د/ مختار الشرعبي \nرقم الهاتف: 772586514',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final Uri phoneUri = Uri(scheme: 'tel', path: '772586514');
                            if (await canLaunchUrl(phoneUri)) {
                              await launchUrl(phoneUri);
                            }
                          },
                          icon: const Icon(Icons.phone),
                          label: const Text('اتصال'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final Uri whatsappUri = Uri.parse(
                              'https://wa.me/966772586514?text=مرحباً، أحتاج مساعدة في تطبيق متجر الورود',
                            );
                            if (await canLaunchUrl(whatsappUri)) {
                              await launchUrl(whatsappUri);
                            }
                          },
                          icon: const Icon(Icons.message),
                          label: const Text('واتساب'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.neonBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
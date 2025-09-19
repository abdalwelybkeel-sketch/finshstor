import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/support_provider.dart';
import '../widgets/support_ticket_card.dart';
import 'create_ticket_page.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final supportProvider = Provider.of<SupportProvider>(context, listen: false);

    if (authProvider.isAuthenticated) {
      await supportProvider.loadTickets(authProvider.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المساعدة والدعم'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Support Team Info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.neonBlue.withOpacity(0.1),
                    AppTheme.darkGlowingWhite.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.neonBlue.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppTheme.neonBlue,
                    child: const Icon(
                      Icons.support_agent,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'فريق الدعم',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'عبددالولي بازل',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppTheme.neonBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'نحن هنا لمساعدتك في أي وقت\nفريق الدعم متاح 24/7',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Contact Options
            Text(
              'طرق التواصل',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildContactCard(
                    icon: Icons.chat_bubble_outline,
                    title: 'محادثة مباشرة',
                    subtitle: 'ابدأ محادثة الآن',
                    color: AppTheme.neonBlue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateTicketPage(),
                        ),
                      ).then((_) => _loadTickets());
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildContactCard(
                    icon: Icons.phone,
                    title: 'اتصال هاتفي',
                    subtitle: '772586514',
                    color: Colors.green,
                    onTap: () async {
                      final Uri phoneUri = Uri(scheme: 'tel', path: '+966501234567');
                      if (await canLaunchUrl(phoneUri)) {
                        await launchUrl(phoneUri);
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildContactCard(
                    icon: Icons.email_outlined,
                    title: 'البريد الإلكتروني',
                    subtitle: 'د/ مختار الشرعبي  - 772586514',
                    color: Colors.blue,
                    onTap: () async {
                      final Uri emailUri = Uri(
                        scheme: 'mailto',
                        path: 'support@roses.com',
                        query: 'subject=استفسار من تطبيق متجر الورود',
                      );
                      if (await canLaunchUrl(emailUri)) {
                        await launchUrl(emailUri);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildContactCard(
                    icon: Icons.message,
                    title: 'واتساب',
                    subtitle: 'تواصل سريع',
                    color: Colors.green[600]!,
                    onTap: () async {
                      final Uri whatsappUri = Uri.parse(
                        'https://wa.me/966501234567?text=مرحباً، أحتاج مساعدة في تطبيق متجر الورود',
                      );
                      if (await canLaunchUrl(whatsappUri)) {
                        await launchUrl(whatsappUri);
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Support Tickets
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'تذاكر الدعم',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateTicketPage(),
                      ),
                    ).then((_) => _loadTickets());
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('تذكرة جديدة'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Consumer<SupportProvider>(
              builder: (context, supportProvider, child) {
                if (supportProvider.isLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.neonBlue,
                    ),
                  );
                }

                if (supportProvider.tickets.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.support_outlined,
                          size: 64,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد تذاكر دعم',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'يمكنك إنشاء تذكرة دعم جديدة للحصول على المساعدة',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: supportProvider.tickets.map((ticket) {
                    return SupportTicketCard(
                      ticket: ticket,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppConfig.ticketDetailsRoute,
                          arguments: {'ticketId': ticket.id},
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 32),

            // FAQ Section
            Text(
              'الأسئلة الشائعة',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildFAQItem(
              'كيف يمكنني تتبع طلبي؟',
              'يمكنك تتبع طلبك من خلال صفحة "طلباتي" في الملف الشخصي، أو من خلال الرابط المرسل في رسالة التأكيد.',
            ),
            _buildFAQItem(
              'ما هي مدة التوصيل؟',
              'نقوم بتوصيل الطلبات خلال 24-48 ساعة داخل المدن الرئيسية، و3-5 أيام للمناطق الأخرى.',
            ),
            _buildFAQItem(
              'هل يمكنني إلغاء طلبي؟',
              'يمكنك إلغاء الطلب قبل تأكيده من التاجر. بعد التأكيد، يرجى التواصل مع فريق الدعم.',
            ),
            _buildFAQItem(
              'كيف يمكنني استخدام كوبون الخصم؟',
              'أدخل كود الكوبون في صفحة السلة قبل إتمام الشراء، وسيتم تطبيق الخصم تلقائياً.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: TextStyle(
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/support_provider.dart';

class TicketDetailsPage extends StatefulWidget {
  final String ticketId;

  const TicketDetailsPage({
    super.key,
    required this.ticketId,
  });

  @override
  State<TicketDetailsPage> createState() => _TicketDetailsPageState();
}

class _TicketDetailsPageState extends State<TicketDetailsPage> {
  SupportTicketModel? _ticket;
  bool _isLoading = true;
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTicket();
  }

  Future<void> _loadTicket() async {
    final supportProvider = Provider.of<SupportProvider>(context, listen: false);
    final ticket = await supportProvider.getTicket(widget.ticketId);
    
    setState(() {
      _ticket = ticket;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final supportProvider = Provider.of<SupportProvider>(context, listen: false);

    if (!authProvider.isAuthenticated) return;

    final success = await supportProvider.addMessage(
      ticketId: widget.ticketId,
      senderId: authProvider.currentUser!.id,
      senderName: authProvider.currentUser!.fullName,
      message: _messageController.text.trim(),
    );

    if (success) {
      _messageController.clear();
      _loadTicket(); // Reload to get updated messages
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('تفاصيل التذكرة')),
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.neonBlue,
          ),
        ),
      );
    }

    if (_ticket == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('تفاصيل التذكرة')),
        body: const Center(
          child: Text('التذكرة غير موجودة'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('تذكرة #${_ticket!.id.substring(0, 8)}'),
      ),
      body: Column(
        children: [
          // Ticket Info
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _ticket!.statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _ticket!.statusText,
                        style: TextStyle(
                          color: _ticket!.statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _ticket!.priorityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _ticket!.priorityText,
                        style: TextStyle(
                          color: _ticket!.priorityColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _ticket!.subject,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _ticket!.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'تم الإنشاء: ${DateFormat('dd/MM/yyyy - hh:mm a', 'ar').format(_ticket!.createdAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: _ticket!.messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد رسائل بعد',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ابدأ المحادثة مع فريق الدعم',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _ticket!.messages.length,
                    itemBuilder: (context, index) {
                      final message = _ticket!.messages[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: message.isFromSupport
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.end,
                          children: [
                            Container(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.7,
                              ),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: message.isFromSupport
                                    ? AppTheme.neonPurple.withOpacity(0.3)
                                    : AppTheme.neonBlue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message.senderName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: message.isFromSupport
                                          ? AppTheme.neonBlue
                                          : Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    message.message,
                                    style: TextStyle(
                                      color: message.isFromSupport
                                          ? Colors.black87
                                          : Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('hh:mm a', 'ar').format(message.createdAt),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: message.isFromSupport
                                          ? Colors.grey
                                          : Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Message Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'اكتب رسالتك...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.withOpacity(0.1),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  backgroundColor: AppTheme.neonBlue,
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
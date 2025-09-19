import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/services/firebase_service.dart';

enum TicketStatus {
  open,
  inProgress,
  resolved,
  closed,
}

enum TicketPriority {
  low,
  medium,
  high,
  urgent,
}

class SupportTicketModel {
  final String id;
  final String userId;
  final String userEmail;
  final String userName;
  final String subject;
  final String description;
  final TicketStatus status;
  final TicketPriority priority;
  final String category;
  final List<String> attachments;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? assignedTo;
  final List<TicketMessage> messages;

  SupportTicketModel({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.subject,
    required this.description,
    this.status = TicketStatus.open,
    this.priority = TicketPriority.medium,
    required this.category,
    this.attachments = const [],
    required this.createdAt,
    required this.updatedAt,
    this.assignedTo,
    this.messages = const [],
  });

  factory SupportTicketModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SupportTicketModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userEmail: data['userEmail'] ?? '',
      userName: data['userName'] ?? '',
      subject: data['subject'] ?? '',
      description: data['description'] ?? '',
      status: TicketStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => TicketStatus.open,
      ),
      priority: TicketPriority.values.firstWhere(
        (e) => e.name == data['priority'],
        orElse: () => TicketPriority.medium,
      ),
      category: data['category'] ?? '',
      attachments: List<String>.from(data['attachments'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      assignedTo: data['assignedTo'],
      messages: (data['messages'] as List<dynamic>?)
          ?.map((msg) => TicketMessage.fromMap(msg))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'userName': userName,
      'subject': subject,
      'description': description,
      'status': status.name,
      'priority': priority.name,
      'category': category,
      'attachments': attachments,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'assignedTo': assignedTo,
      'messages': messages.map((msg) => msg.toMap()).toList(),
    };
  }

  String get statusText {
    switch (status) {
      case TicketStatus.open:
        return 'مفتوح';
      case TicketStatus.inProgress:
        return 'قيد المعالجة';
      case TicketStatus.resolved:
        return 'تم الحل';
      case TicketStatus.closed:
        return 'مغلق';
    }
  }

  String get priorityText {
    switch (priority) {
      case TicketPriority.low:
        return 'منخفضة';
      case TicketPriority.medium:
        return 'متوسطة';
      case TicketPriority.high:
        return 'عالية';
      case TicketPriority.urgent:
        return 'عاجلة';
    }
  }

  Color get statusColor {
    switch (status) {
      case TicketStatus.open:
        return Colors.blue;
      case TicketStatus.inProgress:
        return Colors.orange;
      case TicketStatus.resolved:
        return Colors.green;
      case TicketStatus.closed:
        return Colors.grey;
    }
  }

  Color get priorityColor {
    switch (priority) {
      case TicketPriority.low:
        return Colors.green;
      case TicketPriority.medium:
        return Colors.orange;
      case TicketPriority.high:
        return Colors.red;
      case TicketPriority.urgent:
        return Colors.purple;
    }
  }
}

class TicketMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final bool isFromSupport;
  final DateTime createdAt;

  TicketMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    this.isFromSupport = false,
    required this.createdAt,
  });

  factory TicketMessage.fromMap(Map<String, dynamic> data) {
    return TicketMessage(
      id: data['id'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      message: data['message'] ?? '',
      isFromSupport: data['isFromSupport'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'isFromSupport': isFromSupport,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class SupportProvider extends ChangeNotifier {
  List<SupportTicketModel> _tickets = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<SupportTicketModel> get tickets => _tickets;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadTickets(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      final querySnapshot = await FirebaseService.firestore
          .collection('support_tickets')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      _tickets = querySnapshot.docs
          .map((doc) => SupportTicketModel.fromFirestore(doc))
          .toList();

      notifyListeners();
    } catch (e) {
      _setError('فشل تحميل تذاكر الدعم');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createTicket({
    required String userId,
    required String userEmail,
    required String userName,
    required String subject,
    required String description,
    required String category,
    TicketPriority priority = TicketPriority.medium,
    List<String> attachments = const [],
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final ticket = SupportTicketModel(
        id: '',
        userId: userId,
        userEmail: userEmail,
        userName: userName,
        subject: subject,
        description: description,
        category: category,
        priority: priority,
        attachments: attachments,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final docRef = await FirebaseService.firestore
          .collection('support_tickets')
          .add(ticket.toFirestore());

      _tickets.insert(0, SupportTicketModel(
        id: docRef.id,
        userId: userId,
        userEmail: userEmail,
        userName: userName,
        subject: subject,
        description: description,
        category: category,
        priority: priority,
        attachments: attachments,
        createdAt: ticket.createdAt,
        updatedAt: ticket.updatedAt,
      ));

      notifyListeners();
      return true;
    } catch (e) {
      _setError('فشل إنشاء تذكرة الدعم');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<SupportTicketModel?> getTicket(String ticketId) async {
    try {
      final doc = await FirebaseService.firestore
          .collection('support_tickets')
          .doc(ticketId)
          .get();

      if (doc.exists) {
        return SupportTicketModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      _setError('فشل تحميل تذكرة الدعم');
      return null;
    }
  }

  Future<bool> addMessage({
    required String ticketId,
    required String senderId,
    required String senderName,
    required String message,
    bool isFromSupport = false,
  }) async {
    try {
      final ticketMessage = TicketMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: senderId,
        senderName: senderName,
        message: message,
        isFromSupport: isFromSupport,
        createdAt: DateTime.now(),
      );

      await FirebaseService.firestore
          .collection('support_tickets')
          .doc(ticketId)
          .update({
        'messages': FieldValue.arrayUnion([ticketMessage.toMap()]),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Update local state
      final ticketIndex = _tickets.indexWhere((t) => t.id == ticketId);
      if (ticketIndex != -1) {
        // Reload the ticket to get updated messages
        final updatedTicket = await getTicket(ticketId);
        if (updatedTicket != null) {
          _tickets[ticketIndex] = updatedTicket;
        }
        
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError('فشل إضافة الرسالة');
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
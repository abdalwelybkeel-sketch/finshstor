import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

class FirebaseService {
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  static FirebaseStorage get storage => FirebaseStorage.instance;
  static FirebaseMessaging get messaging => FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // Configure Firestore settings
    firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    // Request notification permissions
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  
  // Collections
  static CollectionReference get usersCollection => 
      firestore.collection('users');
  
  static CollectionReference get productsCollection => 
      firestore.collection('products');
  
  static CollectionReference get ordersCollection => 
      firestore.collection('orders');
  
  static CollectionReference get cartCollection => 
      firestore.collection('cart');
  
  static CollectionReference get categoriesCollection => 
      firestore.collection('categories');
  
  static CollectionReference get couponsCollection => 
      firestore.collection('coupons');
  
  static CollectionReference get reviewsCollection => 
      firestore.collection('reviews');
  
  static CollectionReference get notificationsCollection => 
      firestore.collection('notifications');
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
}
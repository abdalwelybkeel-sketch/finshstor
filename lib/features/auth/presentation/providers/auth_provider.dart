import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../core/models/user_model.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/services/notification_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  Future<void> checkAuthStatus() async {
    final user = FirebaseService.auth.currentUser;
    if (user != null) {
      await _loadUserData(user.uid);
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();

      final credential = await FirebaseService.auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await _loadUserData(credential.user!.uid);
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('حدث خطأ غير متوقع');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
    bool isVendor = false,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final credential = await FirebaseService.auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final fcmToken = await NotificationService.getToken();
        
        final userModel = UserModel(
          id: credential.user!.uid,
          email: email,
          fullName: fullName,
          phoneNumber: phoneNumber,
          isVendor: isVendor,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          fcmToken: fcmToken,
        );

        await FirebaseService.usersCollection
            .doc(credential.user!.uid)
            .set(userModel.toFirestore());

        _currentUser = userModel;
        notifyListeners();
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('حدث خطأ غير متوقع');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _clearError();

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return false;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseService.auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        await _handleSocialSignIn(userCredential.user!);
        return true;
      }
      return false;
    } catch (e) {
      _setError('فشل تسجيل الدخول بجوجل');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithApple() async {
    try {
      _setLoading(true);
      _clearError();

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await FirebaseService.auth.signInWithCredential(oauthCredential);
      
      if (userCredential.user != null) {
        await _handleSocialSignIn(
          userCredential.user!,
          fullName: appleCredential.givenName != null && appleCredential.familyName != null
              ? '${appleCredential.givenName} ${appleCredential.familyName}'
              : null,
        );
        return true;
      }
      return false;
    } catch (e) {
      _setError('فشل تسجيل الدخول بآبل');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();

      await FirebaseService.auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('حدث خطأ غير متوقع');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseService.auth.signOut();
      await GoogleSignIn().signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _setError('فشل تسجيل الخروج');
    }
  }

  Future<bool> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? profileImage,
  }) async {
    if (_currentUser == null) return false;

    try {
      _setLoading(true);
      _clearError();

      final updatedUser = _currentUser!.copyWith(
        fullName: fullName,
        phoneNumber: phoneNumber,
        profileImage: profileImage,
        updatedAt: DateTime.now(),
      );

      await FirebaseService.usersCollection
          .doc(_currentUser!.id)
          .update(updatedUser.toFirestore());

      _currentUser = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('فشل تحديث الملف الشخصي');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadUserData(String userId) async {
    try {
      final doc = await FirebaseService.usersCollection.doc(userId).get();
      if (doc.exists) {
        _currentUser = UserModel.fromFirestore(doc);
        notifyListeners();
      }
    } catch (e) {
      _setError('فشل تحميل بيانات المستخدم');
    }
  }

  Future<void> _handleSocialSignIn(User user, {String? fullName}) async {
    final doc = await FirebaseService.usersCollection.doc(user.uid).get();
    
    if (doc.exists) {
      _currentUser = UserModel.fromFirestore(doc);
    } else {
      final fcmToken = await NotificationService.getToken();
      
      final userModel = UserModel(
        id: user.uid,
        email: user.email ?? '',
        fullName: fullName ?? user.displayName ?? 'مستخدم',
        profileImage: user.photoURL,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        fcmToken: fcmToken,
      );

      await FirebaseService.usersCollection
          .doc(user.uid)
          .set(userModel.toFirestore());

      _currentUser = userModel;
    }
    notifyListeners();
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

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'لا يوجد مستخدم بهذا البريد الإلكتروني';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل';
      case 'weak-password':
        return 'كلمة المرور ضعيفة';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صحيح';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب';
      case 'too-many-requests':
        return 'تم تجاوز عدد المحاولات المسموح';
      default:
        return 'حدث خطأ في المصادقة';
    }
  }
}
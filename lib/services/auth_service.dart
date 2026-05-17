import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// LOGIN + YETKİ KONTROL
  static Future<User> loginWithFirma(
    String email,
    String password,
    String firmaKodu,
  ) async {
    // 1️⃣ Firebase login
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = result.user!;

    // 2️⃣ Firestore yetki kontrol
    final doc = await _firestore
        .collection("firmalar")
        .doc(firmaKodu)
        .collection("kullanicilar")
        .doc(user.uid)
        .get();

    if (!doc.exists) {
      await _auth.signOut();
      throw Exception("Bu firmaya giriş yetkiniz yok");
    }

    return user;
  }

  /// LOGOUT
  static Future<void> logout() async {
    await _auth.signOut();
  }

  /// MEVCUT KULLANICI
  static User? currentUser() {
    return _auth.currentUser;
  }

  /// UID
  static String? getUid() {
    return _auth.currentUser?.uid;
  }

  /// LOGIN DURUMU
  static bool isLoggedIn() {
    return _auth.currentUser != null;
  }
}

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/firma_bilgi.dart';

class LocalDB {
  static SharedPreferences? _prefs;

  /// ================= INIT =================
  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// ================= SAVE =================
  static void save(String key, dynamic value) {
    _prefs!.setString(key, jsonEncode(value));
  }

  /// ================= GET =================
  static dynamic get(String key, {dynamic defaultValue}) {
    final data = _prefs!.getString(key);

    if (data == null) return defaultValue;

    return jsonDecode(data);
  }

  /// ================= FİRMA =================
  static void firmaKaydet(FirmaBilgi firma) {
    save("firma", firma.toMap());
  }

  static FirmaBilgi firmaGetir() {
    final data = get("firma");

    if (data == null) {
      return FirmaBilgi(
        firmaAdi: "",
        telefon: "",
        adres: "",
        logoYolu: null,
      );
    }

    return FirmaBilgi.fromMap(
      Map<String, dynamic>.from(data),
    );
  }

  /// ================= AUTO LOGIN =================
  static void loginKaydet(
    String kullaniciAdi,
    String sifre,
  ) {
    save("autoLogin", {
      "kullaniciAdi": kullaniciAdi,
      "sifre": sifre,
    });
  }

  static Map<String, dynamic>? loginGetir() {
    final data = get("autoLogin");

    if (data == null) return null;

    return Map<String, dynamic>.from(data);
  }

  static void loginTemizle() {
    _prefs!.remove("autoLogin");
  }

  /// ================= SERVİS NUMARASI =================
  static String yeniServisNo() {
    int no = _prefs!.getInt("servisNo") ?? 0;

    no++;

    _prefs!.setInt("servisNo", no);

    final yil = DateTime.now().year;

    return "SR-$yil-${no.toString().padLeft(6, '0')}";
  }
}

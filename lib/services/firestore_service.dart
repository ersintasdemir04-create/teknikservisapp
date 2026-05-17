import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/musteri.dart';
import '../models/cihaz.dart';
import '../models/servis.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// ===============================
  /// MÜŞTERİLER
  /// ===============================

  static Stream<List<Musteri>> musterileriDinle(String firmaId) {
    if (firmaId.isEmpty) return const Stream.empty();

    return _db
        .collection("firmalar")
        .doc(firmaId)
        .collection("musteriler")
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((d) => Musteri.fromMap(d.id, d.data()))
            .toList());
  }

  static Future<void> musteriEkle(String firmaId, Musteri musteri) async {
    final data = musteri.toMap();
    data["firmaId"] = firmaId;

    await _db
        .collection("firmalar")
        .doc(firmaId)
        .collection("musteriler")
        .add(data);
  }

  static Future<void> musteriTamSil(String firmaId, String musteriId) async {
    final musteriRef = _db
        .collection("firmalar")
        .doc(firmaId)
        .collection("musteriler")
        .doc(musteriId);

    final cihazlar = await musteriRef.collection("cihazlar").get();

    for (var cihaz in cihazlar.docs) {
      await cihazSil(firmaId, musteriId, cihaz.id);
    }

    await musteriRef.delete();
  }

  /// ===============================
  /// CİHAZLAR
  /// ===============================

  static Stream<List<Cihaz>> cihazlariDinle(String firmaId, String musteriId) {
    return _db
        .collection("firmalar")
        .doc(firmaId)
        .collection("musteriler")
        .doc(musteriId)
        .collection("cihazlar")
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((d) => Cihaz.fromMap(d.id, d.data()))
            .toList());
  }

  static Future<void> cihazEkle(
      String firmaId, String musteriId, Cihaz cihaz) async {
    final data = cihaz.toMap();
    data["firmaId"] = firmaId;
    data["musteriId"] = musteriId;

    await _db
        .collection("firmalar")
        .doc(firmaId)
        .collection("musteriler")
        .doc(musteriId)
        .collection("cihazlar")
        .add(data);
  }

  static Future<void> cihazSil(
      String firmaId, String musteriId, String cihazId) async {
    final cihazRef = _db
        .collection("firmalar")
        .doc(firmaId)
        .collection("musteriler")
        .doc(musteriId)
        .collection("cihazlar")
        .doc(cihazId);

    final servisler = await cihazRef.collection("servisler").get();

    for (var doc in servisler.docs) {
      await doc.reference.delete();
    }

    await cihazRef.delete();
  }

  /// ===============================
  /// SERVİSLER
  /// ===============================

  static Stream<List<Servis>> servisleriDinle(
    String firmaId,
    String musteriId,
    String cihazId,
  ) {
    return _db
        .collection("firmalar")
        .doc(firmaId)
        .collection("musteriler")
        .doc(musteriId)
        .collection("cihazlar")
        .doc(cihazId)
        .collection("servisler")
        .orderBy("tarih", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((d) => Servis.fromMap(d.id, d.data()))
            .toList());
  }

  static Future<void> servisEkle(
    String firmaId,
    String musteriId,
    String cihazId,
    Servis servis,
  ) async {
    final data = servis.toMap();

    /// 🔥 KRİTİK ALANLAR
    data["firmaId"] = firmaId;
    data["musteriId"] = musteriId;
    data["cihazId"] = cihazId;

    await _db
        .collection("firmalar")
        .doc(firmaId)
        .collection("musteriler")
        .doc(musteriId)
        .collection("cihazlar")
        .doc(cihazId)
        .collection("servisler")
        .doc(servis.id)
        .set(data);
  }

  static Future<void> servisSil(
    String firmaId,
    String musteriId,
    String cihazId,
    String servisId,
  ) async {
    await _db
        .collection("firmalar")
        .doc(firmaId)
        .collection("musteriler")
        .doc(musteriId)
        .collection("cihazlar")
        .doc(cihazId)
        .collection("servisler")
        .doc(servisId)
        .delete();
  }

  static Future<void> servisDurumGuncelle(
    String firmaId,
    String musteriId,
    String cihazId,
    String servisId,
    String durum,
  ) async {
    await _db
        .collection("firmalar")
        .doc(firmaId)
        .collection("musteriler")
        .doc(musteriId)
        .collection("cihazlar")
        .doc(cihazId)
        .collection("servisler")
        .doc(servisId)
        .update({"durum": durum});
  }

  static Future<Servis?> acikServisGetir(
    String firmaId,
    String musteriId,
    String cihazId,
  ) async {
    final snap = await _db
        .collection("firmalar")
        .doc(firmaId)
        .collection("musteriler")
        .doc(musteriId)
        .collection("cihazlar")
        .doc(cihazId)
        .collection("servisler")
        .where("durum", isEqualTo: "acik")
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;

    return Servis.fromMap(snap.docs.first.id, snap.docs.first.data());
  }

  /// ===============================
  /// 🔥 DASHBOARD (STABİL + GERİYE DÖNÜK)
  /// ===============================

  static Stream<int> acikServisSayisi(String firmaId) {
    return _db.collectionGroup("servisler").snapshots().map((snapshot) {
      return snapshot.docs.where((doc) {
        final data = doc.data();

        return data["durum"] == "acik" &&
            (data["firmaId"] == firmaId || data["firmaId"] == null);
      }).length;
    });
  }

  static Stream<int> kapaliServisSayisi(String firmaId) {
    return _db.collectionGroup("servisler").snapshots().map((snapshot) {
      return snapshot.docs.where((doc) {
        final data = doc.data();

        return data["durum"] == "kapali" &&
            (data["firmaId"] == firmaId || data["firmaId"] == null);
      }).length;
    });
  }

  /// ===============================
  /// TASLAKLAR
  /// ===============================

  static Future<void> taslakKaydet(
      String firmaId, String taslakId, Map<String, dynamic> data) async {
    await _db
        .collection("firmalar")
        .doc(firmaId)
        .collection("servisTaslaklari")
        .doc(taslakId)
        .set(data);
  }

  static Future<Map<String, dynamic>?> taslakGetir(
      String firmaId, String taslakId) async {
    final doc = await _db
        .collection("firmalar")
        .doc(firmaId)
        .collection("servisTaslaklari")
        .doc(taslakId)
        .get();

    return doc.data();
  }

  static Future<void> taslakSil(String firmaId, String taslakId) async {
    await _db
        .collection("firmalar")
        .doc(firmaId)
        .collection("servisTaslaklari")
        .doc(taslakId)
        .delete();
  }
}
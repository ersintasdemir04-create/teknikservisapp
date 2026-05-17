import 'package:cloud_firestore/cloud_firestore.dart';

class Servis {
  final String id;
  final String firmaId;
  final String musteriId;
  final String cihazId;

  final String servisNo;
  final String ariza;
  final String yapilanIslem;
  final String aciklama;

  final String musteriImza;
  final String personelImza;
  final String musteriImzaAd;

  final DateTime tarih;
  final String durum;

  final List<Map<String, dynamic>> fotograflar;
  final List<dynamic> analizler;

  Servis({
    required this.id,
    required this.firmaId,
    required this.musteriId,
    required this.cihazId,
    required this.servisNo,
    required this.ariza,
    required this.yapilanIslem,
    required this.aciklama,
    required this.musteriImza,
    required this.personelImza,
    required this.tarih,
    required this.musteriImzaAd,
    required this.fotograflar,
    required this.durum,
    required this.analizler,
  });

  Map<String, dynamic> toMap() {
    return {
      "firmaId": firmaId,
      "musteriId": musteriId,
      "cihazId": cihazId,
      "servisNo": servisNo,
      "ariza": ariza,
      "yapilanIslem": yapilanIslem,
      "aciklama": aciklama,
      "musteriImza": musteriImza,
      "personelImza": personelImza,
      "musteriImzaAd": musteriImzaAd,
      "tarih": Timestamp.fromDate(tarih),
      "fotograflar": fotograflar,
      "durum": durum,
      "analizler": analizler,
    };
  }

  factory Servis.fromMap(String id, Map<String, dynamic> map) {
    return Servis(
      id: id,
      firmaId: map["firmaId"] ?? "",
      musteriId: map["musteriId"] ?? "",
      cihazId: map["cihazId"] ?? "",
      servisNo: map["servisNo"] ?? "",
      ariza: map["ariza"] ?? "",
      yapilanIslem: map["yapilanIslem"] ?? "",
      aciklama: map["aciklama"] ?? "",
      musteriImza: map["musteriImza"] ?? "",
      personelImza: map["personelImza"] ?? "",
      musteriImzaAd: map["musteriImzaAd"] ?? "",
      tarih: (map["tarih"] as Timestamp?)?.toDate() ?? DateTime.now(),
      fotograflar: (map["fotograflar"] as List?)?.map((e) {
            /// 🟢 YENİ FORMAT
            if (e is Map<String, dynamic>) {
              return e;
            }

            /// 🟡 ESKİ FORMAT (STRING)
            if (e is String) {
              return {
                "path": e,
                "aciklama": "",
              };
            }

            /// 🔴 HATALI VERİ
            return {
              "path": "",
              "aciklama": "",
            };
          }).toList() ??
          [],
      durum: map["durum"] ?? "acik",
      analizler: (map["analizler"] as List?) ?? [],
    );
  }
}

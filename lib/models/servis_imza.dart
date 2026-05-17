class ServisImza {
  String servisId;

  /// MÜŞTERİ
  String musteriImzaYolu;
  String musteriAdSoyad;

  /// PERSONEL
  String personelImzaYolu;
  String personelAdSoyad;

  ServisImza({
    required this.servisId,
    required this.musteriImzaYolu,
    required this.musteriAdSoyad,
    required this.personelImzaYolu,
    required this.personelAdSoyad,
  });

  Map<String, dynamic> toMap() {
    return {
      "servisId": servisId,
      "musteriImzaYolu": musteriImzaYolu,
      "musteriAdSoyad": musteriAdSoyad,
      "personelImzaYolu": personelImzaYolu,
      "personelAdSoyad": personelAdSoyad,
    };
  }

  factory ServisImza.fromMap(Map<String, dynamic> map) {
    return ServisImza(
      servisId: map["servisId"],
      musteriImzaYolu: map["musteriImzaYolu"] ?? "",
      musteriAdSoyad: map["musteriAdSoyad"] ?? "",
      personelImzaYolu: map["personelImzaYolu"] ?? "",
      personelAdSoyad: map["personelAdSoyad"] ?? "",
    );
  }
}

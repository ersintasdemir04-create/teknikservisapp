class FirmaBilgi {
  String firmaAdi;
  String telefon;
  String adres;
  String? logoYolu;

  FirmaBilgi({
    required this.firmaAdi,
    required this.telefon,
    required this.adres,
    this.logoYolu,
  });

  Map<String, dynamic> toMap() {
    return {
      "firmaAdi": firmaAdi,
      "telefon": telefon,
      "adres": adres,
      "logoYolu": logoYolu,
    };
  }

  factory FirmaBilgi.fromMap(Map<String, dynamic> map) {
    return FirmaBilgi(
      firmaAdi: map["firmaAdi"] ?? "",
      telefon: map["telefon"] ?? "",
      adres: map["adres"] ?? "",
      logoYolu: map["logoYolu"],
    );
  }
}

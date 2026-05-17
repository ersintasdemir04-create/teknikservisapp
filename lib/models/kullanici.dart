class Kullanici {
  String id;
  String kullaniciAdi;
  String sifre;
  String adSoyad;
  String rol; // admin / personel
  String? imzaYolu;

  Kullanici({
    required this.id,
    required this.kullaniciAdi,
    required this.sifre,
    required this.adSoyad,
    required this.rol,
    this.imzaYolu,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "kullaniciAdi": kullaniciAdi,
      "sifre": sifre,
      "adSoyad": adSoyad,
      "rol": rol,
      "imzaYolu": imzaYolu,
    };
  }

  factory Kullanici.fromMap(Map<String, dynamic> map) {
    return Kullanici(
      id: map["id"],
      kullaniciAdi: map["kullaniciAdi"],
      sifre: map["sifre"],
      adSoyad: map["adSoyad"],
      rol: map["rol"] ?? "personel",
      imzaYolu: map["imzaYolu"],
    );
  }
}

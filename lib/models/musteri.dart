class Musteri {
  final String id;
  final String firmaId;
  final String firmaAdi;
  final String yetkili;
  final String telefon;

  Musteri({
    required this.id,
    required this.firmaId,
    required this.firmaAdi,
    required this.yetkili,
    required this.telefon,
  });

  /// FIRESTORE → MODEL

  factory Musteri.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return Musteri(
      id: id,
      firmaId: map['firmaId'] ?? '',
      firmaAdi: map['firmaAdi'] ?? '',
      yetkili: map['yetkili'] ?? '',
      telefon: map['telefon'] ?? '',
    );
  }

  /// MODEL → FIRESTORE

  Map<String, dynamic> toMap() {
    return {
      "firmaId": firmaId,
      "firmaAdi": firmaAdi,
      "yetkili": yetkili,
      "telefon": telefon,
    };
  }
}

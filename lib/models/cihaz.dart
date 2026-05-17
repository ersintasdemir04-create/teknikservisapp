class Cihaz {
  final String id;
  final String firmaId;
  final String musteriId;
  final String cihazAdi;
  final String model;
  final String seriNo;

  Cihaz({
    required this.id,
    required this.firmaId,
    required this.musteriId,
    required this.cihazAdi,
    required this.model,
    required this.seriNo,
  });

  /// FIRESTORE → MODEL
  factory Cihaz.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return Cihaz(
      id: id,
      firmaId: map['firmaId'] ?? '',
      musteriId: map['musteriId'] ?? '',
      cihazAdi: map['cihazAdi'] ?? '',
      model: map['model'] ?? '',
      seriNo: map['seriNo'] ?? '',
    );
  }

  /// MODEL → FIRESTORE
  Map<String, dynamic> toMap() {
    return {
      "firmaId": firmaId,
      "musteriId": musteriId,
      "cihazAdi": cihazAdi,
      "model": model,
      "seriNo": seriNo,
    };
  }
}

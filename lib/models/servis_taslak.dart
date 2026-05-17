class ServisTaslak {
  final String id;
  final String cihazId;
  final String musteriId;

  final String ariza;
  final String yapilanIslem;
  final String aciklama;

  ServisTaslak({
    required this.id,
    required this.cihazId,
    required this.musteriId,
    required this.ariza,
    required this.yapilanIslem,
    required this.aciklama,
  });

  Map<String, dynamic> toMap() {
    return {
      "cihazId": cihazId,
      "musteriId": musteriId,
      "ariza": ariza,
      "yapilanIslem": yapilanIslem,
      "aciklama": aciklama,
    };
  }

  factory ServisTaslak.fromMap(String id, Map<String, dynamic> map) {
    return ServisTaslak(
      id: id,
      cihazId: map["cihazId"] ?? "",
      musteriId: map["musteriId"] ?? "",
      ariza: map["ariza"] ?? "",
      yapilanIslem: map["yapilanIslem"] ?? "",
      aciklama: map["aciklama"] ?? "",
    );
  }
}

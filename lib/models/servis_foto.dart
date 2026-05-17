class ServisFoto {
  final String id;
  final String servisID;
  final String fotoYolu;
  final String aciklama;

  ServisFoto({
    required this.id,
    required this.servisID,
    required this.fotoYolu,
    required this.aciklama,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'servisId': servisID,
      'fotoYolu': fotoYolu,
      'aciklama': aciklama,
    };
  }

  factory ServisFoto.fromMap(Map<String, dynamic> map) {
    return ServisFoto(
      id: map['id'],
      servisID: map['servisID'],
      fotoYolu: map['fotoYolu'],
      aciklama: map['aciklama'],
    );
  }
}

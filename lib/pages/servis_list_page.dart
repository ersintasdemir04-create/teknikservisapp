import 'package:flutter/material.dart';

import '../models/cihaz.dart';
import '../models/musteri.dart';
import '../models/servis.dart';
import '../services/firestore_service.dart';
import 'servis_form_page.dart';
import 'servis_detay_page.dart';

class ServisListPage extends StatefulWidget {
  final String firmaId;
  final Musteri musteri;
  final Cihaz cihaz;

  const ServisListPage({
    super.key,
    required this.firmaId,
    required this.musteri,
    required this.cihaz,
  });

  @override
  State<ServisListPage> createState() => _ServisListPageState();
}

class _ServisListPageState extends State<ServisListPage> {
  String filter = "hepsi";

  Future<void> openForm() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServisFormPage(
          firmaId: widget.firmaId,
          musteriId: widget.musteri.id,
          cihaz: widget.cihaz,
        ),
      ),
    );

    if (result == true) {
      setState(() {}); // 🔥 anlık refresh
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cihaz.cihazAdi),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                filter = value;
              });
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: "hepsi", child: Text("Tümü")),
              PopupMenuItem(value: "acik", child: Text("Açık Servisler")),
              PopupMenuItem(value: "kapali", child: Text("Kapalı Servisler")),
            ],
          )
        ],
      ),

      /// 🔥 FAB (STREAM YAPTIK → ANLIK)
      floatingActionButton: StreamBuilder<List<Servis>>(
        stream: FirestoreService.servisleriDinle(
          widget.firmaId,
          widget.musteri.id,
          widget.cihaz.id,
        ),
        builder: (context, snapshot) {
          final servisler = snapshot.data ?? [];

          final acikVar = servisler.any((s) => s.durum == "acik");

          if (acikVar) {
            return FloatingActionButton.extended(
              backgroundColor: Colors.orange,
              icon: const Icon(Icons.play_arrow),
              label: const Text("DEVAM ET"),
              onPressed: openForm,
            );
          }

          return FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: openForm,
          );
        },
      ),

      body: Column(
        children: [
          /// 🔥 AÇIK SERVİS KARTI (STREAM → ANLIK)
          StreamBuilder<List<Servis>>(
            stream: FirestoreService.servisleriDinle(
              widget.firmaId,
              widget.musteri.id,
              widget.cihaz.id,
            ),
            builder: (context, snapshot) {
              final servisler = snapshot.data ?? [];

              final acikServis =
                  servisler.where((s) => s.durum == "acik").toList();

              if (acikServis.isEmpty) return const SizedBox();

              final servis = acikServis.first;

              return Card(
                color: Colors.orange.shade100,
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: const Icon(Icons.build_circle, color: Colors.orange),
                  title: const Text("Devam Eden Servis"),
                  subtitle: Text(servis.ariza),
                  trailing: const Text(
                    "DEVAM",
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: openForm,
                ),
              );
            },
          ),

          /// 🔥 SERVİS LİSTESİ
          Expanded(
            child: StreamBuilder<List<Servis>>(
              stream: FirestoreService.servisleriDinle(
                widget.firmaId,
                widget.musteri.id,
                widget.cihaz.id,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Hata: ${snapshot.error}"));
                }

                List<Servis> servisler = snapshot.data ?? [];

                /// 🔥 AÇIK SERVİSİ LİSTEDEN ÇIKAR (üstte zaten var)
                servisler = servisler.where((s) => s.durum != "acik").toList();

                /// FİLTRE
                if (filter == "acik") {
                  servisler =
                      servisler.where((s) => s.durum == "acik").toList();
                } else if (filter == "kapali") {
                  servisler =
                      servisler.where((s) => s.durum == "kapali").toList();
                }

                /// SIRALA
                servisler.sort((a, b) => b.tarih.compareTo(a.tarih));

                if (servisler.isEmpty) {
                  return const Center(child: Text("Servis yok"));
                }

                return ListView.builder(
                  itemCount: servisler.length,
                  itemBuilder: (context, index) {
                    final servis = servisler[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: Icon(
                          servis.durum == "acik"
                              ? Icons.build_circle
                              : Icons.check_circle,
                          color: servis.durum == "acik"
                              ? Colors.orange
                              : Colors.green,
                        ),
                        title: Text(servis.ariza),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Servis No: ${servis.servisNo}"),
                            Text(
                              "${servis.tarih.day}.${servis.tarih.month}.${servis.tarih.year}",
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: Text(
                          servis.durum == "acik" ? "Açık" : "Kapalı",
                          style: TextStyle(
                            color: servis.durum == "acik"
                                ? Colors.orange
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () async {
                          if (servis.durum == "acik") {
                            await openForm();
                          } else {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ServisDetayPage(
                                  firmaId: widget.firmaId,
                                  musteri: widget.musteri,
                                  cihaz: widget.cihaz,
                                  servis: servis,
                                ),
                              ),
                            );
                            setState(() {});
                          }
                        },
                        onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Servis Sil"),
                              content: const Text(
                                  "Bu servis kaydını silmek istiyor musunuz?"),
                              actions: [
                                TextButton(
                                  child: const Text("İptal"),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                TextButton(
                                  child: const Text("Sil"),
                                  onPressed: () async {
                                    await FirestoreService.servisSil(
                                      widget.firmaId,
                                      widget.musteri.id,
                                      widget.cihaz.id,
                                      servis.id,
                                    );

                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/servis.dart';
import '../models/musteri.dart';
import '../models/cihaz.dart';
import '../services/firestore_service.dart';
import '../services/pdf_service.dart';

class ServisDetayPage extends StatelessWidget {
  final String firmaId;
  final Musteri musteri;
  final Cihaz cihaz;
  final Servis servis;

  const ServisDetayPage({
    super.key,
    required this.firmaId,
    required this.musteri,
    required this.cihaz,
    required this.servis,
  });

  @override
  Widget build(BuildContext context) {
    final isAcik = servis.durum == "acik";

    return Scaffold(
      appBar: AppBar(
        title: Text(servis.servisNo),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              await PdfService.servisPdfOlustur(
                firmaId,
                servis,
                musteri,
                cihaz,
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// 🔴 DURUM
          Card(
            color: isAcik ? Colors.orange.shade100 : Colors.green.shade100,
            child: ListTile(
              title: Text(
                isAcik ? "DEVAM EDEN SERVİS" : "SERVİS TAMAMLANDI",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          /// 🏢 FİRMA + MÜŞTERİ
          _card([
            _row("Firma", musteri.firmaAdi),
            _row("Yetkili", musteri.yetkili),
            _row("Telefon", musteri.telefon),
          ]),

          /// ⚙️ CİHAZ
          _card([
            _row("Cihaz", cihaz.cihazAdi),
            _row("Model", cihaz.model),
            _row("Seri No", cihaz.seriNo),
          ]),

          /// 🔧 ARIZA
          _section("Arıza", servis.ariza),

          /// 🛠️ İŞLEM
          _section("Yapılan İşlem", servis.yapilanIslem),

          /// 📝 AÇIKLAMA
          _section("Açıklama", servis.aciklama),

          /// 📅 TARİH
          _card([
            _row(
              "Tarih",
              "${servis.tarih.day}.${servis.tarih.month}.${servis.tarih.year}",
            ),
          ]),

          /// 📷 FOTOĞRAFLAR
          if (servis.fotograflar.isNotEmpty)
            _fotoGrid(context, servis.fotograflar),

          /// ✍️ İMZA
          _imza(),
        ],
      ),
    );
  }

  /// 📦 CARD
  Widget _card(List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: children),
      ),
    );
  }

  /// 📄 ROW
  Widget _row(String t, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            t,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Flexible(child: Text(v)),
        ],
      ),
    );
  }

  /// 📝 TEXT BLOK
  Widget _section(String title, String value) {
    if (value.isEmpty) return const SizedBox();

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 5),
            Text(value),
          ],
        ),
      ),
    );
  }

  /// 📷 FOTO GRID
  Widget _fotoGrid(
    BuildContext context,
    List<dynamic> fotograflar,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Fotoğraflar",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: fotograflar.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemBuilder: (context, index) {
                final foto = fotograflar[index];

                String path = "";
                String aciklama = "";

                if (foto is Map) {
                  path = foto["path"] ?? "";
                  aciklama = foto["aciklama"] ?? "";
                } else if (foto is String) {
                  path = foto;
                }

                if (path.isEmpty) {
                  return const SizedBox();
                }

                if (!File(path).existsSync()) {
                  return const SizedBox();
                }

                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      /// FOTO
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => Dialog(
                                child: InteractiveViewer(
                                  child: Image.file(
                                    File(path),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Image.file(
                            File(path),
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),

                      /// AÇIKLAMA
                      if (aciklama.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            aciklama,
                            style: const TextStyle(fontSize: 10),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      /// SİL
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () async {
                          try {
                            File(path).deleteSync();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Fotoğraf silindi"),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Silinemedi: $e",
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// ✍️ İMZA
  Widget _imza() {
    if (servis.musteriImza.isEmpty) {
      return const SizedBox();
    }

    Uint8List bytes = base64Decode(servis.musteriImza);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Text(
              "Müşteri İmza",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Image.memory(
              bytes,
              height: 80,
            ),

            const SizedBox(height: 10),

            Text(servis.musteriImzaAd),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../data/app_data.dart';
import '../models/servis_imza.dart';
import '../services/pdf_service.dart';

class ImzaPage extends StatefulWidget {
  final String servisId;

  const ImzaPage({super.key, required this.servisId});

  @override
  State<ImzaPage> createState() => _ImzaPageState();
}

class _ImzaPageState extends State<ImzaPage> {
  final musteriController = TextEditingController();

  final SignatureController musteriImza =
      SignatureController(penStrokeWidth: 3);

  /// PERSONEL İMZASI AYARLARDAN GELECEK
  String? personelImzaYolu;

  Future<String> imzaKaydet(SignatureController controller) async {
    final bytes = await controller.toPngBytes();

    final dir = await getTemporaryDirectory();

    final file = File(
      "${dir.path}/imza_${DateTime.now().millisecondsSinceEpoch}.png",
    );

    await file.writeAsBytes(bytes!);

    return file.path;
  }

  Future<void> kaydet() async {
    if (musteriController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Müşteri ad soyad giriniz")),
      );
      return;
    }

    if (musteriImza.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Müşteri imza atmalı")),
      );
      return;
    }

    /// MÜŞTERİ İMZA
    final musteriPath = await imzaKaydet(musteriImza);

    /// PERSONEL İMZA (AYARLARDAN)
    personelImzaYolu = AppData.aktifKullanici?.imzaYolu ?? "";

    AppData.servisImzalari.add(
      ServisImza(
        servisId: widget.servisId,
        musteriImzaYolu: musteriPath,
        musteriAdSoyad: musteriController.text,
        personelImzaYolu: personelImzaYolu ?? "",
        personelAdSoyad: AppData.aktifKullanici?.adSoyad ?? "",
      ),
    );

    AppData.saveAll();

    final servis = AppData.servisler.firstWhere((s) => s.id == widget.servisId);

    await PdfService.servisPdfGoster(servis);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Müşteri İmzası")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: musteriController,
              decoration: const InputDecoration(
                labelText: "Müşteri Ad Soyad",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 250,
              decoration: BoxDecoration(border: Border.all()),
              child: Signature(controller: musteriImza),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: kaydet,
              child: const Text("Kaydet ve PDF Oluştur"),
            ),
          ],
        ),
      ),
    );
  }
}

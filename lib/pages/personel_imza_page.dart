import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/app_data.dart';

class PersonelImzaPage extends StatefulWidget {
  final String firmaId;

  const PersonelImzaPage({
    super.key,
    required this.firmaId,
  });

  @override
  State<PersonelImzaPage> createState() => _PersonelImzaPageState();
}

class _PersonelImzaPageState extends State<PersonelImzaPage> {
  final SignatureController controller = SignatureController(
    penStrokeWidth: 3,
  );

  Future<void> kaydet() async {
    final bytes = await controller.toPngBytes();
    if (bytes == null) return;

    final dir = await getApplicationDocumentsDirectory();

    final file = File("${dir.path}/personel_imza.png");

    await file.writeAsBytes(bytes);

    /// eski sistem (bozulmadı)
    AppData.aktifKullanici?.imzaYolu = file.path;
    AppData.saveAll();

    /// YENİ EKLENEN KISIM (PDF için)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("personelImzaYolu", file.path);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("İmza kaydedildi"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Personel İmzası"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              AppData.aktifKullanici?.adSoyad ?? "",
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 220,
              decoration: BoxDecoration(
                border: Border.all(),
              ),
              child: Signature(
                controller: controller,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: kaydet,
              child: const Text("Kaydet"),
            ),
          ],
        ),
      ),
    );
  }
}

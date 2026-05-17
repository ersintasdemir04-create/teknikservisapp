import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class FirmaAyarPage extends StatefulWidget {
  final String firmaId;

  const FirmaAyarPage({
    super.key,
    required this.firmaId,
  });

  @override
  State<FirmaAyarPage> createState() => _FirmaAyarPageState();
}

class _FirmaAyarPageState extends State<FirmaAyarPage> {
  final firmaController = TextEditingController();
  final adresController = TextEditingController();
  final telController = TextEditingController();
  final emailController = TextEditingController();
  final personelController = TextEditingController();

  File? logo;

  /// LOGO SEÇ
  Future<void> logoSec() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      setState(() {
        logo = File(image.path);
      });
    }
  }

  /// KAYDET
  void kaydet() async {
    String logoBase64 = "";

    if (logo != null) {
      final bytes = await logo!.readAsBytes();
      logoBase64 = base64Encode(bytes);
    }

    await FirebaseFirestore.instance
        .collection("firmalar")
        .doc(widget.firmaId)
        .collection("ayarlar")
        .doc("firma")
        .set({
      "firmaAdi": firmaController.text,
      "adres": adresController.text,
      "telefon": telController.text,
      "email": emailController.text,
      "personelAdi": personelController.text,
      "logo": logoBase64,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Firma Ayarları"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            /// LOGO
            GestureDetector(
              onTap: logoSec,
              child: logo == null
                  ? Container(
                      height: 120,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Text("Firma Logosu Seç"),
                      ),
                    )
                  : Image.file(
                      logo!,
                      height: 120,
                    ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: firmaController,
              decoration: const InputDecoration(
                labelText: "Firma Adı",
              ),
            ),

            TextField(
              controller: adresController,
              decoration: const InputDecoration(
                labelText: "Adres",
              ),
            ),

            TextField(
              controller: telController,
              decoration: const InputDecoration(
                labelText: "Telefon",
              ),
            ),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
              ),
            ),

            TextField(
              controller: personelController,
              decoration: const InputDecoration(
                labelText: "Personel Adı",
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

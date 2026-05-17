import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../data/app_security.dart';
import 'firma_ayar_page.dart';
import 'personel_imza_page.dart';
import 'kullanici_list_page.dart';

class AyarlarPage extends StatefulWidget {
  final String firmaId;

  const AyarlarPage({
    super.key,
    required this.firmaId,
  });

  @override
  State<AyarlarPage> createState() => _AyarlarPageState();
}

class _AyarlarPageState extends State<AyarlarPage> {
  File? logoFile;

  @override
  void initState() {
    super.initState();
    logoYukle();
  }

  /// 📌 LOGO YÜKLE
  Future<void> logoYukle() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/logo_${widget.firmaId}.png");

    if (await file.exists()) {
      setState(() {
        logoFile = file;
      });
    }
  }

  /// 📌 LOGO SEÇ + KAYDET
  Future<void> logoSec() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final savedImage = File("${dir.path}/logo_${widget.firmaId}.png");

    await savedImage.writeAsBytes(await picked.readAsBytes());

    setState(() {
      logoFile = savedImage;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Logo kaydedildi")),
    );
  }

  /// 🔐 OEM ŞİFRE
  void oemSifreSor(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("OEM Şifre"),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(labelText: "Şifre"),
        ),
        actions: [
          TextButton(
            child: const Text("İptal"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Giriş"),
            onPressed: () {
              if (controller.text == AppSecurity.oemPassword) {
                AppSecurity.oemUnlocked = true;

                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const KullaniciListPage(),
                  ),
                );
              } else {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Hatalı OEM Şifre"),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ayarlar")),
      body: ListView(
        children: [
          const SizedBox(height: 10),

          /// 🔥 LOGO ALANI
          Center(
            child: GestureDetector(
              onTap: logoSec,
              child: Column(
                children: [
                  if (logoFile != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        logoFile!,
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                    )
                  else
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.image, size: 40),
                    ),
                  const SizedBox(height: 8),
                  const Text("Logo değiştirmek için tıkla"),
                ],
              ),
            ),
          ),

          const Divider(),

          /// FİRMA
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text("Firma Bilgileri"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FirmaAyarPage(
                    firmaId: widget.firmaId,
                  ),
                ),
              );
            },
          ),

          /// İMZA
          ListTile(
            leading: const Icon(Icons.draw),
            title: const Text("Personel İmzası"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PersonelImzaPage(
                    firmaId: widget.firmaId,
                  ),
                ),
              );
            },
          ),

          /// OEM
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text("Kullanıcı Yönetimi"),
            onTap: () => oemSifreSor(context),
          ),
        ],
      ),
    );
  }
}

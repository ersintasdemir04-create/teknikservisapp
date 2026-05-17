import 'package:flutter/material.dart';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/app_data.dart';
import '../models/kullanici.dart';

class KullaniciEklePage extends StatefulWidget {
  const KullaniciEklePage({super.key});

  @override
  State<KullaniciEklePage> createState() => _KullaniciEklePageState();
}

class _KullaniciEklePageState extends State<KullaniciEklePage> {
  final adSoyad = TextEditingController();
  final kullaniciAdi = TextEditingController();
  final sifre = TextEditingController();

  String rol = "personel";

  void kaydet() async {
    /// 🔹 Eski sistem (bozulmadı)
    AppData.kullanicilar.add(
      Kullanici(
        id: Random().nextInt(999999).toString(),
        adSoyad: adSoyad.text,
        kullaniciAdi: kullaniciAdi.text,
        sifre: sifre.text,
        rol: rol,
      ),
    );

    AppData.saveAll();

    /// 🔹 Firebase Authentication kullanıcı oluştur
    try {
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: kullaniciAdi.text,
        password: sifre.text,
      );

      final uid = userCredential.user!.uid;

      /// 🔹 Firestore kullanıcı kaydı
      await FirebaseFirestore.instance
          .collection("firmalar")
          .doc("firma1")
          .collection("kullanicilar")
          .doc(uid)
          .set({
        "email": kullaniciAdi.text,
        "adSoyad": adSoyad.text,
        "rol": rol,
      });
    } catch (e) {
      debugPrint("Firebase kullanıcı oluşturma hatası: $e");
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Yeni Kullanıcı")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: adSoyad,
              decoration: const InputDecoration(labelText: "Ad Soyad"),
            ),
            TextField(
              controller: kullaniciAdi,
              decoration:
                  const InputDecoration(labelText: "Kullanıcı Adı (Email)"),
            ),
            TextField(
              controller: sifre,
              decoration: const InputDecoration(labelText: "Şifre"),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField(
              value: rol,
              items: const [
                DropdownMenuItem(
                  value: "admin",
                  child: Text("Admin"),
                ),
                DropdownMenuItem(
                  value: "personel",
                  child: Text("Personel"),
                ),
              ],
              onChanged: (v) {
                setState(() {
                  rol = v.toString();
                });
              },
              decoration: const InputDecoration(labelText: "Yetki"),
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

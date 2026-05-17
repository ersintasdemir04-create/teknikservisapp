import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/musteri.dart';
import 'yeni_musteri_page.dart';
import 'cihaz_list_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'ayarlar_page.dart';
import 'musteri_sec_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  final String firmaId;

  const HomePage({
    super.key,
    required this.firmaId,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String personelAdi = "";
  File? logoFile;
  String firmaAdi = "";

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    await personelYukle();
    await logoYukle();
    await firmaYukle();
  }

  /// 👤 PERSONEL
  Future<void> personelYukle() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final query = await FirebaseFirestore.instance
          .collection("firmalar")
          .doc(widget.firmaId)
          .collection("kullanicilar")
          .where("mail", isEqualTo: user.email)
          .get();

      if (query.docs.isNotEmpty) {
        personelAdi = query.docs.first.data()["ad"] ?? "";
      } else {
        personelAdi = user.email!.split("@")[0];
      }
    } catch (e) {
      personelAdi = user.email!.split("@")[0];
    }

    if (mounted) setState(() {});
  }

  /// 🖼 LOGO
  Future<void> logoYukle() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = "${dir.path}/logo_${widget.firmaId}.png";
    final file = File(path);

    if (await file.exists()) {
      if (mounted) {
        setState(() {
          logoFile = file;
        });
      }
    }
  }

  /// 🏢 FİRMA ADI
  Future<void> firmaYukle() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("firmalar")
          .doc(widget.firmaId)
          .collection("ayarlar")
          .doc("firma")
          .get();

      if (doc.exists) {
        firmaAdi = doc.data()?["firmaAdi"] ?? "";
        if (mounted) setState(() {});
      }
    } catch (_) {}
  }

  /// 📊 DASHBOARD CARD
  Widget buildCountCard({
    required String title,
    required Color color,
    required Stream<int> stream,
  }) {
    return Expanded(
      child: Card(
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              StreamBuilder<int>(
                stream: stream,
                builder: (context, snapshot) {
  if (snapshot.connectionState == ConnectionState.waiting) {
    return const SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }

  final count = snapshot.data ?? 0;

  return Text(
    count.toString(),
    style: const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
  );
}
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🗑 MÜŞTERİ SİL
  void _musteriSilDialog(BuildContext context, Musteri musteri) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Müşteri Sil"),
        content: const Text(
          "Bu müşteriyi silmek istediğinize emin misiniz?\n\nTüm cihazlar ve servisler silinir!",
        ),
        actions: [
          TextButton(
            child: const Text("İptal"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Sil", style: TextStyle(color: Colors.red)),
            onPressed: () async {
              await FirestoreService.musteriTamSil(
                widget.firmaId,
                musteri.id,
              );

              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Müşteri silindi")),
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
    final firmaId = widget.firmaId;

    return Scaffold(
      appBar: AppBar(
        title: Text(firmaAdi.isEmpty ? "Teknik Servis" : firmaAdi),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => YeniMusteriPage(firmaId: firmaId),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AyarlarPage(firmaId: firmaId),
                ),
              );
              logoYukle();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginPage(),
                  ),
                );
              }
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.build),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MusteriSecPage(firmaId: firmaId),
            ),
          );
        },
      ),

      body: Column(
        children: [
          const SizedBox(height: 10),

          if (logoFile != null) Image.file(logoFile!, height: 70),

          const SizedBox(height: 5),

          Text(
            "Servis Personeli: $personelAdi",
            style: const TextStyle(color: Colors.grey),
          ),

          const Divider(),

          /// 📊 DASHBOARD
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                buildCountCard(
                  title: "Açık Servis",
                  color: Colors.orange.shade100,
                  stream: FirestoreService.acikServisSayisi(firmaId),
                ),
                buildCountCard(
                  title: "Kapalı Servis",
                  color: Colors.blue.shade100,
                  stream: FirestoreService.kapaliServisSayisi(firmaId),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// 👥 MÜŞTERİLER
          Expanded(
            child: StreamBuilder<List<Musteri>>(
              stream: FirestoreService.musterileriDinle(firmaId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final musteriler = snapshot.data!;

                if (musteriler.isEmpty) {
                  return const Center(child: Text("Müşteri yok"));
                }

                return ListView.builder(
                  itemCount: musteriler.length,
                  itemBuilder: (context, index) {
                    final m = musteriler[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        title: Text(m.firmaAdi),
                        subtitle: Text(
                          "Yetkili: ${m.yetkili}\nTel: ${m.telefon}",
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.arrow_forward_ios, size: 16),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  _musteriSilDialog(context, m),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CihazListPage(
                                firmaId: firmaId,
                                musteri: m,
                              ),
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
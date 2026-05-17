import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/musteri.dart';
import 'cihaz_list_page.dart';
import 'yeni_musteri_page.dart';

class MusteriSecPage extends StatelessWidget {
  final String firmaId;

  const MusteriSecPage({
    super.key,
    required this.firmaId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Müşteri Seç"),
        actions: [
          /// YENİ MÜŞTERİ
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => YeniMusteriPage(
                    firmaId: firmaId,
                  ),
                ),
              );
            },
          )
        ],
      ),
      body: StreamBuilder<List<Musteri>>(
        stream: FirestoreService.musterileriDinle(firmaId),
        builder: (context, snapshot) {
          /// LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          /// HATA
          if (snapshot.hasError) {
            return const Center(
              child: Text("Müşteriler yüklenemedi"),
            );
          }

          /// BOŞ
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("Müşteri yok"),
            );
          }

          final musteriler = snapshot.data!;

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
                  subtitle: Text(m.yetkili),
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
    );
  }
}

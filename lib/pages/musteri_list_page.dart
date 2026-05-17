import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/musteri.dart';
import 'cihaz_list_page.dart';
import 'yeni_musteri_page.dart';

class MusteriListPage extends StatelessWidget {
  final String firmaId;

  const MusteriListPage({
    super.key,
    required this.firmaId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Müşteriler"),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => YeniMusteriPage(
                firmaId: firmaId,
              ),
            ),
          );
        },
      ),
      body: StreamBuilder<List<Musteri>>(
        stream: FirestoreService.musterileriDinle(firmaId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

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
                  subtitle: Text(
                    "Yetkili: ${m.yetkili}\nTel: ${m.telefon}",
                  ),
                  isThreeLine: true,
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

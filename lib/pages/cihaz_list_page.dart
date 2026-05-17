import 'package:flutter/material.dart';
import '../models/musteri.dart';
import '../models/cihaz.dart';
import '../services/firestore_service.dart';
import 'yeni_cihaz_page.dart';
import 'servis_list_page.dart';

class CihazListPage extends StatelessWidget {
  final String firmaId;
  final Musteri musteri;

  const CihazListPage({
    super.key,
    required this.firmaId,
    required this.musteri,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(musteri.firmaAdi),
      ),

      /// YENİ CİHAZ
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => YeniCihazPage(
                firmaId: firmaId,
                musteri: musteri,
              ),
            ),
          );
        },
      ),

      body: StreamBuilder<List<Cihaz>>(
        stream: FirestoreService.cihazlariDinle(
          firmaId,
          musteri.id,
        ),
        builder: (context, snapshot) {
          /// LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          /// HATA
          if (snapshot.hasError) {
            return const Center(child: Text("Cihazlar yüklenemedi"));
          }

          /// BOŞ
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Cihaz yok"));
          }

          final cihazlar = snapshot.data!;

          return ListView.builder(
            itemCount: cihazlar.length,
            itemBuilder: (context, index) {
              final cihaz = cihazlar[index];

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: ListTile(
                  title: Text(cihaz.cihazAdi),

                  subtitle: Text(
                    "Model: ${cihaz.model}\nSeri No: ${cihaz.seriNo}",
                  ),

                  isThreeLine: true,

                  /// CİHAZ SİL
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Cihaz Sil"),
                          content: const Text(
                            "Bu cihaz ve tüm servis kayıtları silinecek. Emin misiniz?",
                          ),
                          actions: [
                            TextButton(
                              child: const Text("İptal"),
                              onPressed: () => Navigator.pop(context),
                            ),
                            TextButton(
                              child: const Text("Sil"),
                              onPressed: () async {
                                Navigator.pop(context);

                                await FirestoreService.cihazSil(
                                  firmaId,
                                  musteri.id,
                                  cihaz.id,
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  /// SERVİS LİSTESİNE GİT
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ServisListPage(
                          firmaId: firmaId,
                          musteri: musteri,
                          cihaz: cihaz,
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

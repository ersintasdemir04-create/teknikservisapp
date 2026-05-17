import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../models/kullanici.dart';
import 'kullanici_ekle_page.dart';
import '../data/app_security.dart';

class KullaniciListPage extends StatefulWidget {
  const KullaniciListPage({super.key});

  @override
  State<KullaniciListPage> createState() => _KullaniciListPageState();
}

class _KullaniciListPageState extends State<KullaniciListPage> {
  void sil(Kullanici k) {
    AppData.kullanicilar.removeWhere((e) => e.id == k.id);
    AppData.saveAll();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!AppSecurity.oemUnlocked) {
      return const Scaffold(
        body: Center(
          child: Text('Yetkisiz erişim'),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kullanıcı Yönetimi"),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const KullaniciEklePage(),
            ),
          );

          setState(() {});
        },
      ),
      body: ListView.builder(
        itemCount: AppData.kullanicilar.length,
        itemBuilder: (context, index) {
          final k = AppData.kullanicilar[index];

          return ListTile(
            leading: const Icon(Icons.person),
            title: Text(k.adSoyad),
            subtitle: Text(
              "${k.kullaniciAdi}  •  ${k.rol}",
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => sil(k),
            ),
          );
        },
      ),
    );
  }
}

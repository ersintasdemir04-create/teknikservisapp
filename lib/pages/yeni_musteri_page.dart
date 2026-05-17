import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/musteri.dart';

class YeniMusteriPage extends StatefulWidget {
  final String firmaId;

  const YeniMusteriPage({
    super.key,
    required this.firmaId,
  });

  @override
  State<YeniMusteriPage> createState() => _YeniMusteriPageState();
}

class _YeniMusteriPageState extends State<YeniMusteriPage> {
  final _firmaAdiController = TextEditingController();
  final _yetkiliController = TextEditingController();
  final _telefonController = TextEditingController();

  bool loading = false;

  /// KAYDET
  void kaydet() async {
    if (_firmaAdiController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Firma adı giriniz")),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    final musteri = Musteri(
      id: "",
      firmaId: widget.firmaId,
      firmaAdi: _firmaAdiController.text,
      yetkili: _yetkiliController.text,
      telefon: _telefonController.text,
    );

    await FirestoreService.musteriEkle(
      widget.firmaId,
      musteri,
    );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _firmaAdiController.dispose();
    _yetkiliController.dispose();
    _telefonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yeni Müşteri"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _firmaAdiController,
              decoration: const InputDecoration(
                labelText: "Firma Adı",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _yetkiliController,
              decoration: const InputDecoration(
                labelText: "Yetkili",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _telefonController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Telefon",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: loading ? null : kaydet,
                child: loading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text("Kaydet"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

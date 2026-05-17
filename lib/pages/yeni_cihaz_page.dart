import 'package:flutter/material.dart';
import '../models/musteri.dart';
import '../models/cihaz.dart';
import '../services/firestore_service.dart';

class YeniCihazPage extends StatefulWidget {
  final String firmaId;
  final Musteri musteri;

  const YeniCihazPage({
    super.key,
    required this.firmaId,
    required this.musteri,
  });

  @override
  State<YeniCihazPage> createState() => _YeniCihazPageState();
}

class _YeniCihazPageState extends State<YeniCihazPage> {
  final _adiController = TextEditingController();
  final _modelController = TextEditingController();
  final _seriController = TextEditingController();

  @override
  void dispose() {
    _adiController.dispose();
    _modelController.dispose();
    _seriController.dispose();
    super.dispose();
  }

  void kaydet() async {
    if (_adiController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cihaz adı giriniz"),
        ),
      );
      return;
    }

    final cihaz = Cihaz(
      id: "",
      firmaId: widget.firmaId,
      musteriId: widget.musteri.id,
      cihazAdi: _adiController.text,
      model: _modelController.text,
      seriNo: _seriController.text,
    );

    await FirestoreService.cihazEkle(
      widget.firmaId,
      widget.musteri.id,
      cihaz,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yeni Cihaz"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _adiController,
              decoration: const InputDecoration(
                labelText: "Cihaz Adı",
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _modelController,
              decoration: const InputDecoration(
                labelText: "Model",
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _seriController,
              decoration: const InputDecoration(
                labelText: "Seri No",
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

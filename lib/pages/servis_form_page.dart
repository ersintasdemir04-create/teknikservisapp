import 'package:flutter/material.dart';
import '../models/servis.dart';
import '../models/cihaz.dart';
import '../services/firestore_service.dart';
import 'musteri_imza_page.dart';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_painter/image_painter.dart';

import 'dart:io';
import 'dart:typed_data';

class ServisFormPage extends StatefulWidget {
  final String firmaId;
  final String musteriId;
  final Cihaz cihaz;

  const ServisFormPage({
    super.key,
    required this.firmaId,
    required this.musteriId,
    required this.cihaz,
  });

  @override
  State<ServisFormPage> createState() => _ServisFormPageState();
}

class _ServisFormPageState extends State<ServisFormPage> {
  final ImagePicker picker = ImagePicker();

  List<Map<String, dynamic>> fotograflar = [];

  final arizaController = TextEditingController();
  final islemController = TextEditingController();
  final aciklamaController = TextEditingController();
  final imzaAdController = TextEditingController();

  String musteriImza = "";
  String? servisId;

  @override
  void initState() {
    super.initState();
    initServis();
  }

  Future<void> initServis() async {
    final mevcut = await FirestoreService.acikServisGetir(
      widget.firmaId,
      widget.musteriId,
      widget.cihaz.id,
    );

    if (mevcut != null) {
      servisId = mevcut.id;

      arizaController.text = mevcut.ariza;
      islemController.text = mevcut.yapilanIslem;
      aciklamaController.text = mevcut.aciklama;
      musteriImza = mevcut.musteriImza;
      imzaAdController.text = mevcut.musteriImzaAd;

      fotograflar = mevcut.fotograflar.map((e) {
        if (e is Map) {
          return Map<String, dynamic>.from(e);
        } else {
          return {"path": e.toString(), "aciklama": ""};
        }
      }).toList();
    } else {
      final id = DateTime.now().millisecondsSinceEpoch.toString();

      final yeni = Servis(
        id: id,
        firmaId: widget.firmaId,
        musteriId: widget.musteriId,
        cihazId: widget.cihaz.id,
        servisNo: "SRV-$id",
        ariza: "",
        yapilanIslem: "",
        aciklama: "",
        musteriImza: "",
        personelImza: "",
        musteriImzaAd: "",
        fotograflar: [],
        tarih: DateTime.now(),
        durum: "acik",
        analizler: [],
      );

      await FirestoreService.servisEkle(
        widget.firmaId,
        widget.musteriId,
        widget.cihaz.id,
        yeni,
      );

      servisId = id;
    }

    setState(() {});
  }

  Future<void> autoSave() async {
    if (servisId == null) return;

    final servis = Servis(
      id: servisId!,
      firmaId: widget.firmaId,
      musteriId: widget.musteriId,
      cihazId: widget.cihaz.id,
      servisNo: "SRV-$servisId",
      ariza: arizaController.text,
      yapilanIslem: islemController.text,
      aciklama: aciklamaController.text,
      musteriImzaAd: imzaAdController.text,
      musteriImza: musteriImza,
      personelImza: "",
      fotograflar: fotograflar,
      tarih: DateTime.now(),
      durum: "acik",
      analizler: [],
    );

    await FirestoreService.servisEkle(
      widget.firmaId,
      widget.musteriId,
      widget.cihaz.id,
      servis,
    );
  }

  Future<void> fotoEkle(ImageSource source) async {
    final XFile? foto = await picker.pickImage(source: source);

    if (foto == null) return;

    final dir = await getApplicationDocumentsDirectory();

    final path =
        "${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";

    final file = await File(foto.path).copy(path);

    setState(() {
      fotograflar.add({
        "path": file.path,
        "aciklama": "",
      });
    });

    await autoSave();
  }

  void fotoSil(int i) async {
    setState(() {
      fotograflar.removeAt(i);
    });

    await autoSave();
  }

  Future<void> fotoDuzenle(int i) async {
    final path = fotograflar[i]["path"];

    final bytes = await File(path).readAsBytes();

    final key = GlobalKey<ImagePainterState>();

    final edited = await Navigator.push<Uint8List>(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: const Text("Foto Düzenle"),
            actions: [
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: () async {
                  final img = await key.currentState?.exportImage();

                  Navigator.pop(context, img);
                },
              ),
            ],
          ),
          body: ImagePainter.memory(
            bytes,
            key: key,
          ),
        ),
      ),
    );

    if (edited != null) {
      await File(path).writeAsBytes(edited);

      setState(() {});

      await autoSave();
    }
  }

  Future<void> imzaAl() async {
    final imza = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MusteriImzaPage(),
      ),
    );

    if (imza != null) {
      setState(() {
        musteriImza = imza;
      });

      await autoSave();
    }
  }

  Future<void> kaydet() async {
    final servis = Servis(
      id: servisId!,
      firmaId: widget.firmaId,
      musteriId: widget.musteriId,
      cihazId: widget.cihaz.id,
      servisNo: "SRV-$servisId",
      ariza: arizaController.text,
      yapilanIslem: islemController.text,
      aciklama: aciklamaController.text,
      musteriImzaAd: imzaAdController.text,
      musteriImza: musteriImza,
      personelImza: "",
      fotograflar: fotograflar,
      tarih: DateTime.now(),
      durum: "kapali",
      analizler: [],
    );

    await FirestoreService.servisEkle(
      widget.firmaId,
      widget.musteriId,
      widget.cihaz.id,
      servis,
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Servis Formu"),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: ElevatedButton(
            onPressed: kaydet,
            child: const Text("Servisi Kapat"),
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// ARIZA
          TextField(
            controller: arizaController,
            onChanged: (_) => autoSave(),
            minLines: 3,
            maxLines: null,
            decoration: const InputDecoration(
              labelText: "Arıza",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 10),

          /// YAPILAN İŞLEM
          TextField(
            controller: islemController,
            onChanged: (_) => autoSave(),
            minLines: 3,
            maxLines: null,
            decoration: const InputDecoration(
              labelText: "Yapılan İşlem",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 10),

          /// AÇIKLAMA
          TextField(
            controller: aciklamaController,
            onChanged: (_) => autoSave(),
            minLines: 3,
            maxLines: null,
            decoration: const InputDecoration(
              labelText: "Açıklama",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 10),

          /// YETKİLİ
          TextField(
            controller: imzaAdController,
            onChanged: (_) => autoSave(),
            decoration: const InputDecoration(
              labelText: "Yetkili Ad Soyad",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 10),

          /// İMZA
          ElevatedButton(
            onPressed: imzaAl,
            child: const Text("İmza Al"),
          ),

          const SizedBox(height: 10),

          /// FOTO BUTONLARI
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Kamera"),
                  onPressed: () => fotoEkle(ImageSource.camera),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library),
                  label: const Text("Galeri"),
                  onPressed: () => fotoEkle(ImageSource.gallery),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// FOTOĞRAFLAR
          if (fotograflar.isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: fotograflar.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
              ),
              itemBuilder: (context, i) {
                final foto = fotograflar[i];

                final path = foto["path"];

                return Column(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => Dialog(
                              child: Image.file(File(path)),
                            ),
                          );
                        },

                        onLongPress: () => fotoDuzenle(i),

                        child: Stack(
                          children: [
                            Image.file(
                              File(path),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),

                            Positioned(
                              right: 0,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ),
                                onPressed: () => fotoSil(i),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    TextField(
                      controller: TextEditingController(
                        text: foto["aciklama"],
                      ),
                      onChanged: (val) {
                        fotograflar[i]["aciklama"] = val;

                        autoSave();
                      },
                      decoration: const InputDecoration(
                        hintText: "Açıklama",
                        isDense: true,
                      ),
                    ),
                  ],
                );
              },
            ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
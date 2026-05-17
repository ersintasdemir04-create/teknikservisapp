import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart';

import '../models/servis.dart';
import '../models/musteri.dart';
import '../models/cihaz.dart';

class PdfService {
  static Future<void> servisPdfOlustur(
    String firmaId,
    Servis servis,
    Musteri musteri,
    Cihaz cihaz,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final personelImzaYolu = prefs.getString("personelImzaYolu");

    /// FONT
    final fontRegular =
        pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Regular.ttf"));
    final fontBold =
        pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Bold.ttf"));

    /// FİRMA VERİ
    final ayar = await FirebaseFirestore.instance
        .collection("firmalar")
        .doc(firmaId)
        .collection("ayarlar")
        .doc("firma")
        .get();

    final firma = ayar.data();

    final firmaAdi = firma?["firmaAdi"] ?? "";
    final adres = firma?["adres"] ?? "";
    final telefon = firma?["telefon"] ?? "";
    final email = firma?["email"] ?? "";
    final personel = firma?["personelAdi"] ?? "";
    final logoBase64 = firma?["logo"] ?? "";

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(base: fontRegular, bold: fontBold),
    );

    Uint8List? musteriImza;
    Uint8List? logo;
    Uint8List? personelImza;

    /// MÜŞTERİ İMZA
    if (servis.musteriImza.isNotEmpty) {
      musteriImza = base64Decode(servis.musteriImza);
    }

    /// LOGO (ÖNCE TELEFON SONRA FIRESTORE)
    final dirApp = await getApplicationDocumentsDirectory();
    final logoFile = File("${dirApp.path}/logo_$firmaId.png");

    if (await logoFile.exists()) {
      logo = await logoFile.readAsBytes();
    } else if (logoBase64 != null && logoBase64.toString().isNotEmpty) {
      logo = base64Decode(logoBase64);
    }

    /// PERSONEL İMZA
    if (personelImzaYolu != null &&
        File(personelImzaYolu).existsSync()) {
      personelImza = File(personelImzaYolu).readAsBytesSync();
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,

        /// FOOTER
        footer: (context) => pw.Column(
          children: [
            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(firmaAdi,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(telefon),
              ],
            ),
          ],
        ),

        build: (context) => [
          /// HEADER
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (logo != null)
                pw.Image(pw.MemoryImage(logo),
                    width: 70, height: 70),

              pw.BarcodeWidget(
                barcode: pw.Barcode.qrCode(),
                data: "$firmaAdi\n$telefon",
                width: 70,
                height: 70,
              ),

              pw.Container(
                width: 200,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(firmaAdi,
                        style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 3),
                    pw.Text(adres, softWrap: true),
                    pw.Text(telefon),
                    pw.Text(email),
                  ],
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 10),
          pw.Divider(),

          /// BAŞLIK
          pw.Center(
            child: pw.Text("SERVİS FORMU",
                style: pw.TextStyle(
                    fontSize: 22, fontWeight: pw.FontWeight.bold)),
          ),

          pw.SizedBox(height: 10),

          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text("Servis No: ${servis.servisNo}"),
              pw.Text(
                  "Tarih: ${servis.tarih.day}.${servis.tarih.month}.${servis.tarih.year}"),
            ],
          ),

          pw.SizedBox(height: 10),
          pw.Divider(),

          /// MÜŞTERİ + CİHAZ
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("MÜŞTERİ BİLGİLERİ"),
                  pw.Text("Firma: ${musteri.firmaAdi}"),
                  pw.Text("Yetkili: ${musteri.yetkili}"),
                  pw.Text("Telefon: ${musteri.telefon}"),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text("CİHAZ BİLGİLERİ"),
                  pw.Text("Cihaz: ${cihaz.cihazAdi}"),
                  pw.Text("Model: ${cihaz.model}"),
                  pw.Text("Seri No: ${cihaz.seriNo}"),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 10),
          pw.Divider(),

          pw.Text("Arıza"),
          pw.Text(servis.ariza),

          pw.SizedBox(height: 10),
          pw.Divider(),

          pw.Text("Yapılan İşlem"),
          pw.Text(servis.yapilanIslem),

          pw.SizedBox(height: 10),
          pw.Divider(),

          pw.Text("Açıklama"),
          pw.Text(servis.aciklama),

          pw.SizedBox(height: 20),
          pw.Divider(),

          /// İMZA
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                children: [
                  pw.Text(servis.musteriImzaAd),
                  if (musteriImza != null)
                    pw.Image(pw.MemoryImage(musteriImza),
                        width: 120, height: 60),
                  pw.Text("Müşteri"),
                ],
              ),
              pw.Column(
                children: [
                  pw.Text(personel),
                  if (personelImza != null)
                    pw.Image(pw.MemoryImage(personelImza),
                        width: 120, height: 60),
                  pw.Text("Servis Personeli"),
                ],
              ),
            ],
          ),

          pw.NewPage(),

          /// FOTOĞRAFLAR (FIXED)
          if (servis.fotograflar.isNotEmpty) ...[
            pw.Text("Servis Fotoğrafları",
                style: pw.TextStyle(fontSize: 16)),
            pw.SizedBox(height: 10),

            pw.Wrap(
              spacing: 10,
              runSpacing: 10,
              children: servis.fotograflar.map((foto) {
  final dynamic f = foto;

  String? path;
  String aciklama = "";

  if (f is Map) {
    path = f["path"];
    aciklama = f["aciklama"] ?? "";
  } else if (f is String) {
    path = f;
  }

  if (path == null || path.isEmpty || !File(path).existsSync()) {
    return pw.SizedBox();
  }

  final img = File(path).readAsBytesSync();

  return pw.Container(
    width: 150,
    child: pw.Column(
      children: [
        pw.Image(pw.MemoryImage(img), width: 150, height: 150),
        if (aciklama.isNotEmpty)
          pw.Text(aciklama, style: pw.TextStyle(fontSize: 10)),
      ],
    ),
  );
}).toList(),
            ),
          ],
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/servis_${servis.servisNo}.pdf");

    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles(
      [XFile(file.path)],
      text: "Servis formu",
    );
  }
}
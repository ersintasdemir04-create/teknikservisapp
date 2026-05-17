import 'package:share_plus/share_plus.dart';

class WhatsappService {
  static Future<void> pdfGonder(String path) async {
    await Share.shareXFiles(
      [XFile(path)],
      text: "Servis formu gönderildi",
    );
  }
}

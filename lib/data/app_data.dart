import '../models/musteri.dart';
import '../models/cihaz.dart';
import '../models/servis.dart';
import '../models/servis_foto.dart';
import '../models/servis_imza.dart';
import '../models/kullanici.dart';

class AppData {
  /// ================= FIREBASE =================
  static String? firmaId;
  static String? aktifKullaniciAdi;
  static String? rol;

  static bool get adminMi => rol == "admin";

  /// ================= LOCAL DATA =================
  /// (eski sistem bozulmasın diye duruyor)

  static List<Musteri> musteriler = [];
  static List<Cihaz> cihazlar = [];
  static List<Servis> servisler = [];
  static List<ServisFoto> servisFotolari = [];
  static List<ServisImza> servisImzalari = [];
  static List<Kullanici> kullanicilar = [];

  static Kullanici? aktifKullanici;

  /// Şimdilik boş — eski kodlar hata vermesin diye
  static void saveAll() {}
}

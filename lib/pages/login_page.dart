import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool beniHatirla = false;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    bilgileriYukle();
  }

  Future<void> bilgileriYukle() async {
    final prefs = await SharedPreferences.getInstance();

    final mail = prefs.getString("loginMail");
    final sifre = prefs.getString("loginSifre");
    final hatirla = prefs.getBool("beniHatirla") ?? false;

    if (hatirla) {
      emailController.text = mail ?? "";
      passwordController.text = sifre ?? "";
    }

    setState(() {
      beniHatirla = hatirla;
    });
  }

  /// 🔥 MAİLDEN FİRMA ÇIKAR
  String firmaBul(String email) {
    try {
      return email.split("@")[1].split(".")[0];
    } catch (e) {
      return "";
    }
  }

  Future<void> login() async {
    setState(() => loading = true);

    try {
      final result = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = result.user!;

      /// 🔥 FİRMA ID BUL
      final firmaId = firmaBul(user.email!);

      if (firmaId.isEmpty) {
        hata("Firma tespit edilemedi");
        return;
      }

      /// 🔥 FİRMA VAR MI KONTROL
      final firmaDoc = await FirebaseFirestore.instance
          .collection("firmalar")
          .doc(firmaId)
          .get();

      if (!firmaDoc.exists) {
        hata("Bu firmaya ait kayıt yok");
        return;
      }

      /// 🔥 BENİ HATIRLA
      final prefs = await SharedPreferences.getInstance();

      if (beniHatirla) {
        await prefs.setString("loginMail", emailController.text.trim());
        await prefs.setString("loginSifre", passwordController.text.trim());
        await prefs.setBool("beniHatirla", true);
      } else {
        await prefs.clear();
      }

      /// 🔥 GİRİŞ
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(firmaId: firmaId),
        ),
      );
    } on FirebaseAuthException catch (e) {
      hata(e.message ?? "Giriş hatası");
    } catch (e) {
      hata("Bağlantı hatası");
    }

    setState(() => loading = false);
  }

  void hata(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Giriş")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Şifre"),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Checkbox(
                  value: beniHatirla,
                  onChanged: (v) {
                    setState(() {
                      beniHatirla = v!;
                    });
                  },
                ),
                const Text("Beni Hatırla")
              ],
            ),
            const SizedBox(height: 20),
            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: login,
                    child: const Text("Giriş Yap"),
                  ),
          ],
        ),
      ),
    );
  }
}
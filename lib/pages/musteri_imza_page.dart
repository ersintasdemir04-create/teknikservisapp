import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class MusteriImzaPage extends StatefulWidget {
  const MusteriImzaPage({super.key});

  @override
  State<MusteriImzaPage> createState() => _MusteriImzaPageState();
}

class _MusteriImzaPageState extends State<MusteriImzaPage> {
  final SignatureController controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  void kaydet() async {
    if (controller.isEmpty) return;

    Uint8List? data = await controller.toPngBytes();

    String base64 = base64Encode(data!);

    Navigator.pop(context, base64);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Müşteri İmza"),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 200,
            child: Signature(
              controller: controller,
              backgroundColor: Colors.grey[200]!,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  controller.clear();
                },
                child: const Text("Temizle"),
              ),
              ElevatedButton(
                onPressed: kaydet,
                child: const Text("Kaydet"),
              ),
            ],
          ),
          const SizedBox(height: 20)
        ],
      ),
    );
  }
}

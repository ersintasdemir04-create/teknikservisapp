import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/musteri.dart';
import 'cihaz_list_page.dart';

class GlobalSearchPage extends StatefulWidget {
  final String firmaId;

  const GlobalSearchPage({
    super.key,
    required this.firmaId,
  });

  @override
  State<GlobalSearchPage> createState() => _GlobalSearchPageState();
}

class _GlobalSearchPageState extends State<GlobalSearchPage> {
  final searchController = TextEditingController();

  String search = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Global Arama"),
      ),
      body: Column(
        children: [
          /// ARAMA KUTUSU
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: "Müşteri / Cihaz / Servis ara",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  search = value.toLowerCase();
                });
              },
            ),
          ),

          /// ARAMA SONUÇLARI
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("firmalar")
                  .doc(widget.firmaId)
                  .collection("musteriler")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                final results = docs.where((doc) {
                  final data = doc.data();

                  final firma = (data["firmaAdi"] ?? "").toLowerCase();
                  final yetkili = (data["yetkili"] ?? "").toLowerCase();

                  return firma.contains(search) || yetkili.contains(search);
                }).toList();

                if (results.isEmpty) {
                  return const Center(
                    child: Text("Sonuç bulunamadı"),
                  );
                }

                return ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final doc = results[index];
                    final data = doc.data();

                    /// MUSTERI MODELİ
                    final musteri = Musteri.fromMap(
                      doc.id,
                      data,
                    );

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.business),

                        title: Text(data["firmaAdi"] ?? ""),

                        subtitle: Text(
                          data["yetkili"] ?? "",
                        ),

                        /// TIKLANCA CIHAZ LISTESI
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CihazListPage(
                                firmaId: widget.firmaId,
                                musteri: musteri,
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
          ),
        ],
      ),
    );
  }
}

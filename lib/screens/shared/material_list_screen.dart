import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../models/material_model.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MaterialListScreen extends StatelessWidget {
  const MaterialListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final materialsRef = FirebaseDatabase.instance.ref().child('materials');

    return Scaffold(
      appBar: AppBar(title: const Text("المواد العلمية والدروس")),
      body: StreamBuilder(
        stream: materialsRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            Map<dynamic, dynamic> data = snapshot.data!.snapshot.value as Map;
            List<MaterialModel> materials = data.entries
                .map((e) => MaterialModel.fromMap(e.value, e.key))
                .toList();

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: materials.length,
              itemBuilder: (context, index) {
                final material = materials[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(material.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(material.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: const Icon(Icons.menu_book, color: Colors.indigo),
                    onTap: () => _showMaterialDetail(context, material),
                  ),
                ).animate().fadeIn().slideX();
              },
            );
          }
          return const Center(child: Text("لا توجد مواد علمية متاحة حالياً"));
        },
      ),
    );
  }

  void _showMaterialDetail(BuildContext context, MaterialModel material) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(material.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Divider(),
              Text(material.content, textAlign: TextAlign.right, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}

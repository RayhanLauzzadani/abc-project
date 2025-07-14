import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VarietyProductsPage extends StatefulWidget {
  final List<String> varieties;

  const VarietyProductsPage({super.key, this.varieties = const []});

  @override
  State<VarietyProductsPage> createState() => _VarietyProductsPageState();
}

class _VarietyProductsPageState extends State<VarietyProductsPage> {
  List<TextEditingController> controllers = [];

  @override
  void initState() {
    super.initState();
    controllers = List.generate(
      widget.varieties.isNotEmpty ? widget.varieties.length : 1,
      (i) => TextEditingController(
        text: widget.varieties.isNotEmpty ? widget.varieties[i] : '',
      ),
    );
  }

  void _addVariety() {
    if (controllers.length >= 5) return;
    setState(() {
      controllers.add(TextEditingController());
    });
  }

  void _removeVariety(int idx) {
    setState(() {
      controllers.removeAt(idx);
    });
  }

  void _saveVarieties() {
    final names = controllers.map((c) => c.text.trim()).where((v) => v.isNotEmpty).toList();

    // Validasi: Tidak boleh ada yang kosong
    if (names.isEmpty || names.length != controllers.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama variasi tidak boleh kosong!')),
      );
      return;
    }

    // Validasi: Tidak boleh ada yang duplikat (case insensitive)
    final lowerSet = <String>{};
    for (final v in names) {
      final vLower = v.toLowerCase();
      if (lowerSet.contains(vLower)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nama variasi tidak boleh sama!')),
        );
        return;
      }
      lowerSet.add(vLower);
    }

    Navigator.pop(context, names);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Variasi"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  for (int i = 0; i < controllers.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: controllers[i],
                              maxLength: 30,
                              decoration: InputDecoration(
                                hintText: "Ketik nama variasi...",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                counterText: "",
                              ),
                            ),
                          ),
                          if (controllers.length > 1)
                            IconButton(
                              icon: const Icon(Icons.close_rounded, color: Colors.redAccent),
                              onPressed: () => _removeVariety(i),
                            ),
                        ],
                      ),
                    ),
                  if (controllers.length < 5)
                    Center(
                      child: TextButton.icon(
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        label: const Text("Tambah Variasi"),
                        onPressed: _addVariety,
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF2563EB),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveVarieties,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  "Simpan",
                  style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

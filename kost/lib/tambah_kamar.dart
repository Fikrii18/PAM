import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'admin_page.dart';

class TambahKamarPage extends StatefulWidget {
  @override
  _TambahKamarPageState createState() => _TambahKamarPageState();
}

class _TambahKamarPageState extends State<TambahKamarPage> {
  final _noKamarController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _hargaController = TextEditingController();
  bool isAvailable = true; // Menambahkan status ketersediaan

  // Function to save the room data to Firestore
  Future<void> _saveKamar() async {
    String noKamar = _noKamarController.text;
    String deskripsi = _deskripsiController.text;
    String harga = _hargaController.text;

    if (noKamar.isNotEmpty && deskripsi.isNotEmpty && harga.isNotEmpty) {
      try {
        // Save the room data to Firestore
        await FirebaseFirestore.instance.collection('kamar').add({
          'noKamar': noKamar,
          'deskripsi': deskripsi,
          'harga': harga,
          'isAvailable': isAvailable, // Menyimpan status ketersediaan
        });

        // Display success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kamar berhasil disimpan')),
        );

        // Navigate back to Admin page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminPage()),
        );
      } catch (e) {
        // If there's an error, display it
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Semua field harus diisi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Kamar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _noKamarController,
              decoration: InputDecoration(labelText: 'No. Kamar'),
            ),
            TextField(
              controller: _deskripsiController,
              decoration: InputDecoration(labelText: 'Deskripsi'),
              maxLines: 3,
            ),
            TextField(
              controller: _hargaController,
              decoration: InputDecoration(labelText: 'Harga'),
              keyboardType: TextInputType.number,
            ),
            Row(
              children: [
                Text('Tersedia:'),
                Switch(
                  value: isAvailable,
                  onChanged: (value) {
                    setState(() {
                      isAvailable = value;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveKamar,
              child: Text('Simpan Kamar'),
            ),
          ],
        ),
      ),
    );
  }
}

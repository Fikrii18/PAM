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
  bool isAvailable = true; // Status of availability

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
          'isAvailable': isAvailable,
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
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _noKamarController,
                decoration: InputDecoration(
                  labelText: 'No. Kamar',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.hotel),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _deskripsiController,
                decoration: InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _hargaController,
                decoration: InputDecoration(
                  labelText: 'Harga',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.money),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tersedia:', style: TextStyle(fontSize: 16)),
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
              Center(
                child: ElevatedButton(
                  onPressed: _saveKamar,
                  child: Text('Simpan Kamar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent, // Updated here
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
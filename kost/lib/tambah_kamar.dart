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
  bool _isAvailable = true;  // Default to available

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
          'isAvailable': _isAvailable,  // Save availability status
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
        // If there's an error, show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mohon lengkapi semua informasi')),
      );
    }
  }

  // Function to cancel and clear form fields
  void _cancel() {
    setState(() {
      _noKamarController.clear();
      _deskripsiController.clear();
      _hargaController.clear();
    });

    // Go back to Admin page without saving
    Navigator.pop(context);
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
            // Input for Room Number
            TextField(
              controller: _noKamarController,
              decoration: InputDecoration(labelText: 'No. Kamar'),
            ),
            SizedBox(height: 10),

            // Input for Room Description
            TextField(
              controller: _deskripsiController,
              decoration: InputDecoration(labelText: 'Deskripsi'),
              maxLines: 3,
            ),
            SizedBox(height: 10),

            // Input for Room Price
            TextField(
              controller: _hargaController,
              decoration: InputDecoration(labelText: 'Harga'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),

            // Checkbox to indicate room availability
            Row(
              children: [
                Checkbox(
                  value: _isAvailable,
                  onChanged: (bool? value) {
                    setState(() {
                      _isAvailable = value ?? true;
                    });
                  },
                ),
                Text('Kamar Tersedia'),
              ],
            ),

            // Buttons for Save and Cancel actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _cancel,
                  child: Text('Batal'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                ),
                ElevatedButton(
                  onPressed: _saveKamar,
                  child: Text('Simpan'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

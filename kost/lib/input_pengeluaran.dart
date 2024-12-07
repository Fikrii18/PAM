import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InputPengeluaranPage extends StatefulWidget {
  @override
  _InputPengeluaranPageState createState() => _InputPengeluaranPageState();
}

class _InputPengeluaranPageState extends State<InputPengeluaranPage> {
  final TextEditingController _airController = TextEditingController();
  final TextEditingController _listrikController = TextEditingController();
  final TextEditingController _wifiController = TextEditingController();
  final TextEditingController _lainController = TextEditingController();

  // Fungsi untuk membersihkan input dan menghilangkan koma jika ada
  double _parseInput(String input) {
    // Hapus semua karakter selain angka dan titik desimal
    input = input.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(input) ?? 0.0;
  }

  // Fungsi untuk menyimpan data ke Firebase
  Future<void> _saveData() async {
    final pengeluaran = {
      'air': _parseInput(_airController.text),
      'listrik': _parseInput(_listrikController.text),
      'wifi': _parseInput(_wifiController.text),
      'lain': _parseInput(_lainController.text),
      'tanggal': DateTime.now(),
    };

    try {
      await FirebaseFirestore.instance.collection('pengeluaran').add(pengeluaran);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data berhasil disimpan')));
      Navigator.pop(context); // Kembali ke halaman sebelumnya
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan data: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Input Pengeluaran'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _airController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Pengeluaran Air (Rp)'),
            ),
            TextField(
              controller: _listrikController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Pengeluaran Listrik (Rp)'),
            ),
            TextField(
              controller: _wifiController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Pengeluaran Wifi (Rp)'),
            ),
            TextField(
              controller: _lainController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Pengeluaran Lainnya (Rp)'),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _saveData,
                child: Text('Simpan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

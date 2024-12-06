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

  // Fungsi untuk menyimpan data ke Firebase
  Future<void> _saveData() async {
    final pengeluaran = {
      'air': double.tryParse(_airController.text) ?? 0.0,
      'listrik': double.tryParse(_listrikController.text) ?? 0.0,
      'wifi': double.tryParse(_wifiController.text) ?? 0.0,
      'lain': double.tryParse(_lainController.text) ?? 0.0,
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
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Pengeluaran Air (Rp)'),
            ),
            TextField(
              controller: _listrikController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Pengeluaran Listrik (Rp)'),
            ),
            TextField(
              controller: _wifiController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Pengeluaran Wifi (Rp)'),
            ),
            TextField(
              controller: _lainController,
              keyboardType: TextInputType.number,
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

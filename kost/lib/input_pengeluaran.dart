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
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: _airController,
                label: 'Pengeluaran Air (Rp)',
                icon: Icons.water_drop,
              ),
              _buildTextField(
                controller: _listrikController,
                label: 'Pengeluaran Listrik (Rp)',
                icon: Icons.bolt,
              ),
              _buildTextField(
                controller: _wifiController,
                label: 'Pengeluaran Wifi (Rp)',
                icon: Icons.wifi,
              ),
              _buildTextField(
                controller: _lainController,
                label: 'Pengeluaran Lainnya (Rp)',
                icon: Icons.miscellaneous_services,
              ),
              SizedBox(height: 20),
              Center(
  child: ElevatedButton(
    onPressed: _saveData,
    child: Text('Simpan'),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blueAccent, // Use backgroundColor instead of primary
      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    ),
  ),
),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blueAccent, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blueAccent, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blueAccent, width: 1),
          ),
        ),
      ),
    );
  }
}

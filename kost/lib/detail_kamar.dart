import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kost/model/mode_kamar.dart';

class DetailPage extends StatefulWidget {
  final Kamar kamar;

  DetailPage({required this.kamar});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _durasiController = TextEditingController();
  int _durasi = 1; // Default durasi sewa
  String? _namaPenyewa; // Menyimpan nama penyewa

  @override
  void initState() {
    super.initState();
    _getNamaPenyewa();
  }

  void _getNamaPenyewa() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _namaPenyewa = userDoc['name'];
        });
      } else {
        setState(() {
          _namaPenyewa = 'Penyewa Tanpa Nama';
        });
      }
    } catch (e) {
      print('Error mengambil data pengguna: $e');
      setState(() {
        _namaPenyewa = 'Penyewa Tanpa Nama';
      });
    }
  }

  void _pesanKamar() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final Kamar kamar = widget.kamar;
    String hargaString = kamar.harga.replaceAll(',', '').replaceAll('.', '');
    final double harga = double.tryParse(hargaString) ?? 0.0;

    if (harga == 0.0) return;

    final double totalHarga = harga * _durasi;
    final String namaPenyewa = _namaPenyewa ?? 'Penyewa Tanpa Nama';

    try {
      await _firestore.collection('pemesanan').add({
        'noKamar': kamar.noKamar,
        'deskripsi': kamar.deskripsi,
        'durasi': _durasi,
        'totalHarga': totalHarga,
        'namaPenyewa': namaPenyewa,
        'userId': user.uid,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kamar ${kamar.noKamar} berhasil dipesan!'),
          backgroundColor: Colors.blueAccent,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan saat memesan kamar.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final kamar = widget.kamar;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Kamar ${kamar.noKamar}', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue, // Blue app bar
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Room Image Section
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/${kamar.noKamar}.jpg',
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 16.0),
                // Room Description Section
                Text(
                  'Deskripsi: ${kamar.deskripsi}',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                SizedBox(height: 16.0),
                // Price Section
                Text(
                  'Harga: Rp ${kamar.harga} / bulan',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
                SizedBox(height: 16.0),
                // Duration Input Field
                TextField(
                  controller: _durasiController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Durasi Sewa (Bulan)',
                    labelStyle: TextStyle(color: Colors.blueAccent),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _durasi = int.tryParse(value) ?? 1;
                    });
                  },
                ),
                SizedBox(height: 16.0),
                // Tenant Name Section
                _namaPenyewa != null
                    ? Text('Nama Penyewa: $_namaPenyewa', style: TextStyle(fontSize: 16, color: Colors.blueAccent))
                    : CircularProgressIndicator(),
                SizedBox(height: 24.0),
                // Booking Button Section
                ElevatedButton(
                  onPressed: _pesanKamar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent, // Use backgroundColor instead of primary
                    padding: EdgeInsets.symmetric(vertical: 16),
                    textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: Size(double.infinity, 48),
                  ),
                  child: Text('Pesan Kamar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

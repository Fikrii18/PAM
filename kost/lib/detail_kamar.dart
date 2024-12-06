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
    if (user == null) {
      // Handle jika user tidak login
      print('Tidak ada pengguna yang login');
      return;
    }

    // Ambil nama penyewa dari Firestore menggunakan user ID
    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        // Debugging: Print hasil dari Firestore
        print('Dokumen ditemukan: ${userDoc.data()}');
        setState(() {
          _namaPenyewa = userDoc[
              'name']; // Ambil nama dari field 'name' yang ada di Firestore
        });
      } else {
        print('Dokumen tidak ditemukan di Firestore');
        setState(() {
          _namaPenyewa =
              'Penyewa Tanpa Nama'; // Default jika tidak ada nama di Firestore
        });
      }
    } catch (e) {
      print('Error mengambil data pengguna: $e');
      setState(() {
        _namaPenyewa = 'Penyewa Tanpa Nama'; // Default error handling
      });
    }
  }

  void _pesanKamar() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle jika user tidak login
      return;
    }

    // Ambil data kamar dan durasi sewa
    final Kamar kamar = widget.kamar;

    // Debugging: Print harga yang diambil dari Firebase
    print('Harga kamar di Firebase: ${kamar.harga}');

    // Mengganti titik dan koma di harga menjadi format yang valid untuk double
    String hargaString = kamar.harga.replaceAll(',', '').replaceAll('.', '');
    final double harga =
        double.tryParse(hargaString) ?? 0.0; // Jika gagal, set harga ke 0.0

    // Debugging: Print hasil konversi harga
    print('Harga setelah konversi: $harga');

    // Pastikan harga sudah benar sebelum melanjutkan
    if (harga == 0.0) {
      print('Harga kamar tidak valid!');
      return; // Jangan lanjutkan jika harga invalid
    }

    final int durasi = _durasi; // Durasi sewa dalam hari
    final double totalHarga = harga * durasi;

    // Debug: Print nilai total harga
    print('Durasi: $durasi');
    print('Total Harga: $totalHarga');

    // Ambil nama penyewa yang login dari Firebase (dapatkan nama dari user)
    final String namaPenyewa = _namaPenyewa ??
        'Penyewa Tanpa Nama'; // Gunakan nama yang diambil dari Firestore

    // Debugging: Print nama penyewa yang akan disimpan
    print('Nama Penyewa: $namaPenyewa');

    try {
      // Simpan pemesanan ke Firestore dengan status default
      await _firestore.collection('pemesanan').add({
        'noKamar': kamar.noKamar,
        'deskripsi': kamar.deskripsi,
        'durasi': durasi,
        'totalHarga': totalHarga,
        'namaPenyewa': namaPenyewa,
        'userId': user.uid, // ID user yang melakukan pemesanan
        'status': 'pending', // Status default untuk pemesanan
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Tampilkan Snackbar setelah berhasil memesan
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kamar ${kamar.noKamar} berhasil dipesan!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // Kembali ke halaman utama setelah pemesanan berhasil
      Navigator.pop(context);
    } catch (e) {
      // Tampilkan Snackbar jika terjadi error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan saat memesan kamar.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final kamar = widget.kamar;

    return Scaffold(
      appBar: AppBar(title: Text('Detail Kamar ${kamar.noKamar}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Deskripsi: ${kamar.deskripsi}'),
            Text('Harga per hari: ${kamar.harga}'),
            TextField(
              controller: _durasiController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Durasi Sewa (hari)'),
              onChanged: (value) {
                setState(() {
                  _durasi = int.tryParse(value) ?? 1;
                });
              },
            ),
            SizedBox(height: 16.0),
            // Menampilkan nama penyewa jika sudah berhasil diambil dari Firestore
            _namaPenyewa != null
                ? Text('Nama Penyewa: $_namaPenyewa')
                : CircularProgressIndicator(),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _pesanKamar,
              child: Text('Pesan Kamar'),
            ),
          ],
        ),
      ),
    );
  }
}

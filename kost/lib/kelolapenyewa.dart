import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kost/admin_page.dart';
import 'package:kost/laporan.dart';

class PemesananPage extends StatefulWidget {
  @override
  _PemesananPageState createState() => _PemesananPageState();
}

class _PemesananPageState extends State<PemesananPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _selectedIndex = 0;

  // Mengambil daftar pesanan yang belum dikonfirmasi
  Future<List<Map<String, dynamic>>> _getPemesanan() async {
    final QuerySnapshot snapshot = await _firestore.collection('pemesanan')
        .where('status', isEqualTo: 'pending') // hanya pesanan yang belum dikonfirmasi
        .get();

    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  // Fungsi untuk navigasi berdasarkan index
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Tindakan sesuai dengan pilihan
    if (index == 0) {
      // Navigate to AdminPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminPage()),
      );
    } else if (index == 1) {
      // Navigate to LaporanPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LaporanPage()),
      );
    } else if (index == 2) {
      // Navigate to PemesananPage (current page)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PemesananPage()),
      );
    } else if (index == 3) {
      // Handle logout
      _showLogoutDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pemesanan Kamar'),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>( 
        future: _getPemesanan(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Tidak ada pemesanan baru'));
          }

          final pemesananList = snapshot.data!;

          return ListView.builder(
            itemCount: pemesananList.length,
            itemBuilder: (context, index) {
              final pemesanan = pemesananList[index];
              final kamarId = pemesanan['kamarId'];
              final namaPenyewa = pemesanan['namaPenyewa'];
              final durasi = pemesanan['durasi'];
              final totalHarga = pemesanan['totalHarga'];

              return ListTile(
                title: Text('Kamar: $kamarId'),
                subtitle: Text('Nama Penyewa: $namaPenyewa\nDurasi: $durasi\nTotal Harga: $totalHarga'),
                trailing: IconButton(
                  icon: Icon(Icons.check_circle, color: Colors.green),
                  onPressed: () async {
                    // Konfirmasi pemesanan
                    await _konfirmasiPesanan(pemesanan);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pesanan dikonfirmasi')));
                  },
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Laporan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Pemesanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.exit_to_app),
            label: 'Keluar',
          ),
        ],
      ),
    );
  }

  Future<void> _konfirmasiPesanan(Map<String, dynamic> pemesanan) async {
    // 1. Pindahkan data pesanan ke koleksi pemasukan
    final kamarId = pemesanan['kamarId'];
    final namaPenyewa = pemesanan['namaPenyewa'];
    final totalHarga = pemesanan['totalHarga'];
    final tanggalPesan = Timestamp.now();

    await FirebaseFirestore.instance.collection('pemasukan').add({
      'kamarId': kamarId,
      'namaPenyewa': namaPenyewa,
      'totalHarga': totalHarga,
      'tanggalTerima': tanggalPesan,
    });

    // 2. Perbarui status kamar menjadi tidak tersedia
    final kamarRef = FirebaseFirestore.instance.collection('kamar').doc(kamarId);
    await kamarRef.update({'isAvailable': false});

    // 3. Perbarui status pemesanan menjadi 'confirmed'
    final pemesananRef = FirebaseFirestore.instance.collection('pemesanan').doc(pemesanan['id']);
    await pemesananRef.update({'status': 'confirmed'});
  }

  // Menampilkan dialog logout
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Keluar'),
          content: Text('Apakah Anda yakin ingin keluar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                // Logika logout disini
                await FirebaseAuth.instance.signOut(); // Logout Firebase
                Navigator.pushReplacementNamed(context, '/login'); // Navigasi ke halaman login
              },
              child: Text('Keluar'),
            ),
          ],
        );
      },
    );
  }
}

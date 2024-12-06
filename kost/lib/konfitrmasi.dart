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

  Future<List<Map<String, dynamic>>> _getPemesanan() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('pemesanan')
        .where('status', isEqualTo: 'pending')
        .get();

    print('Jumlah pesanan dengan status pending: ${snapshot.docs.length}');

    if (snapshot.docs.isEmpty) {
      print("Tidak ada pesanan dengan status pending!");
    }

    List<Map<String, dynamic>> pesananList = [];

    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;

      if (data.containsKey('noKamar')) {
        String noKamar = data['noKamar'];
        print('Mencari kamar dengan noKamar: $noKamar');
        // Mengambil data kamar berdasarkan noKamar
        DocumentSnapshot kamarDoc = await FirebaseFirestore.instance
            .collection('kamar')
            .doc(noKamar) // Pastikan noKamar yang dipakai adalah ID yang tepat di koleksi kamar
            .get();

        if (kamarDoc.exists) {
          print('Kamar ditemukan: ${kamarDoc.data()}');
          data['kamar'] = kamarDoc.data();
        } else {
          print('Kamar dengan noKamar $noKamar tidak ditemukan');
          data['kamar'] = 'Kamar tidak ditemukan';
        }
      }

      pesananList.add(data);
    }

    return pesananList;
  }

  // Fungsi navigasi berdasarkan index
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminPage()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LaporanPage()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PemesananPage()),
      );
    } else if (index == 3) {
      _showLogoutDialog(context);
    }
  }

Future<void> _updateStatusPesanan(String id, Map<String, dynamic> pesanan, String statusBaru) async {
  try {
    // Update status pesanan sesuai dengan statusBaru
    await _firestore.collection('pemesanan').doc(id).update({
      'status': statusBaru,
    });

    // Jika statusnya "Dikonfirmasi", lakukan tambahan data ke koleksi lain
    if (statusBaru == 'Dikonfirmasi') {
      // Tambahkan data ke koleksi pemasukan
      await _firestore.collection('pemasukan').add({
        'noKamar': pesanan['noKamar'],
        'namaPenyewa': pesanan['namaPenyewa'],
        'durasi': pesanan['durasi'],
        'totalHarga': pesanan['totalHarga'],
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Tambahkan data ke koleksi penyewa
      await _firestore.collection('penyewa').add({
        'noKamar': pesanan['noKamar'],
        'namaPenyewa': pesanan['namaPenyewa'],
        'durasi': pesanan['durasi'],
        'status': 'Aktif',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Mencari kamar berdasarkan noKamar
      String noKamar = pesanan['noKamar'];
      QuerySnapshot kamarQuery = await _firestore
          .collection('kamar')
          .where('noKamar', isEqualTo: noKamar)
          .get();

      if (kamarQuery.docs.isNotEmpty) {
        // Jika kamar ditemukan, update isAvailable menjadi false
        await _firestore.collection('kamar').doc(kamarQuery.docs.first.id).update({
          'isAvailable': false,
        });

        print('Pesanan berhasil dikonfirmasi dan kamar $noKamar diupdate menjadi tidak tersedia.');
      } else {
        print('Kamar dengan noKamar $noKamar tidak ditemukan di koleksi kamar.');
      }
    }

    // Kembali ke halaman Pemesanan setelah update
    setState(() {});
  } catch (e) {
    print('Terjadi kesalahan saat mengubah status pesanan: $e');
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pemesanan Kamar'),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(  // Menampilkan daftar pesanan kamar
        future: _getPemesanan(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Tidak ada pesanan kamar dengan status Pending'));
          }

          final pemesananList = snapshot.data!;

          return ListView.builder(
            itemCount: pemesananList.length,
            itemBuilder: (context, index) {
              final kamar = pemesananList[index];
              final kamarId = kamar['noKamar'] ?? 'Tidak tersedia';
              final harga = kamar['totalHarga'] ?? 'Tidak tersedia';
              final namaPenyewa = kamar['namaPenyewa'] ?? 'Belum ada';
              final durasi = kamar['durasi'] ?? '1 bulan';
              final status = kamar['status'] ?? 'Pending'; // Pastikan status diambil dari data kamar

              return ListTile(
                title: Text('Kamar: $kamarId'),
                subtitle: Text(
                  'Harga: $harga\nNama Penyewa: $namaPenyewa\nDurasi: $durasi\nStatus: $status',
                ),
                trailing: status == 'Dikonfirmasi' 
                    ? Icon(Icons.check_circle, color: Colors.green)
                    : Icon(Icons.hourglass_empty, color: Colors.orange),
                // Menambahkan tombol konfirmasi atau tolak
                onTap: () {
                  if (status == 'pending') {
                    // Pilihan untuk mengubah status pesanan
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Pilih Status'),
                          content: Text('Apakah Anda ingin mengonfirmasi atau menolak pesanan ini?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                _updateStatusPesanan(kamar['id'], kamar, 'Dikonfirmasi');
                                Navigator.pop(context);
                              },
                              child: Text('Konfirmasi'),
                            ),
                            TextButton(
                              onPressed: () {
                                _updateStatusPesanan(kamar['id'], kamar, 'Ditolak');
                                Navigator.pop(context);
                              },
                              child: Text('Tolak'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
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
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text('Keluar'),
            ),
          ],
        );
      },
    );
  }
}

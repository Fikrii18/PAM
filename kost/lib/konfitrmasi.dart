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
  int _selectedIndex = 2;

  Future<List<Map<String, dynamic>>> _getPemesanan() async {
    final QuerySnapshot snapshot = await _firestore
        .collection('pemesanan')
        .where('status', isEqualTo: 'pending')
        .get();

    List<Map<String, dynamic>> pesananList = [];

    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;

      if (data.containsKey('noKamar')) {
        DocumentSnapshot kamarDoc = await _firestore
            .collection('kamar')
            .doc(data['noKamar'])
            .get();

        if (kamarDoc.exists) {
          data['kamar'] = kamarDoc.data();
        } else {
          data['kamar'] = 'Kamar tidak ditemukan';
        }
      }

      pesananList.add(data);
    }

    return pesananList;
  }

  void _onItemTapped(int index) {
    // Update selected index
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to the respective page based on the selected index
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdminPage()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LaporanPage()),
        );
        break;
      case 3:
        _showLogoutDialog(context);
        break;
    }
  }

  Future<void> _updateStatusPesanan(String id, Map<String, dynamic> pesanan, String statusBaru) async {
    try {
      await _firestore.collection('pemesanan').doc(id).update({
        'status': statusBaru,
      });

      if (statusBaru == 'Dikonfirmasi') {
        await _firestore.collection('pemasukan').add({
          'noKamar': pesanan['noKamar'],
          'namaPenyewa': pesanan['namaPenyewa'],
          'durasi': pesanan['durasi'],
          'totalHarga': pesanan['totalHarga'],
          'timestamp': FieldValue.serverTimestamp(),
        });

        await _firestore.collection('penyewa').add({
          'noKamar': pesanan['noKamar'],
          'namaPenyewa': pesanan['namaPenyewa'],
          'durasi': pesanan['durasi'],
          'status': 'Aktif',
          'timestamp': FieldValue.serverTimestamp(),
        });

        String noKamar = pesanan['noKamar'];
        QuerySnapshot kamarQuery = await _firestore
            .collection('kamar')
            .where('noKamar', isEqualTo: noKamar)
            .get();

        if (kamarQuery.docs.isNotEmpty) {
          await _firestore.collection('kamar').doc(kamarQuery.docs.first.id).update({
            'isAvailable': false,
          });
        }
      }

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
      body: FutureBuilder<List<Map<String, dynamic>>>(
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
            padding: EdgeInsets.all(16),
            itemCount: pemesananList.length,
            itemBuilder: (context, index) {
              final kamar = pemesananList[index];
              final kamarId = kamar['noKamar'] ?? 'Tidak tersedia';
              final harga = kamar['totalHarga'] ?? 'Tidak tersedia';
              final namaPenyewa = kamar['namaPenyewa'] ?? 'Belum ada';
              final durasi = kamar['durasi'] ?? '1 bulan';
              final status = kamar['status'] ?? 'Pending';

              return Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text('Kamar: $kamarId', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Harga: $harga'),
                      Text('Nama Penyewa: $namaPenyewa'),
                      Text('Durasi: $durasi'),
                      Text('Status: $status', style: TextStyle(color: status == 'Dikonfirmasi' ? Colors.green : Colors.orange)),
                    ],
                  ),
                  trailing: status == 'Dikonfirmasi' 
                      ? Icon(Icons.check_circle, color: Colors.green)
                      : Icon(Icons.hourglass_empty, color: Colors.orange),
                  onTap: () {
                    if (status == 'pending') {
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
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
    );
  }

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
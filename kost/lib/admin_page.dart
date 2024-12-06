import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kost/konfitrmasi.dart';
import 'package:kost/tambah_kamar.dart';
import 'package:kost/laporan.dart';
import 'package:kost/login.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _selectedIndex = 0;

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


  // Ambil koleksi kamar dari Firestore
  Stream<QuerySnapshot> _getKamarList() {
    return FirebaseFirestore.instance.collection('kamar').snapshots();
  }

  // Menampilkan halaman tambah kamar
  void _navigateToTambahKamarPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TambahKamarPage()),
    );
  }

  // Menghapus kamar dari Firestore
  void _deleteKamar(String id) async {
    try {
      await FirebaseFirestore.instance.collection('kamar').doc(id).delete();
      print("Kamar dengan ID $id berhasil dihapus.");
    } catch (e) {
      print("Gagal menghapus kamar: $e");
    }
  }

  // Menampilkan dialog edit kamar
  void _showEditDialog(BuildContext context, String id, String currentNoKamar, String currentDeskripsi, String currentHarga, bool isAvailable) {
    final noKamarController = TextEditingController(text: currentNoKamar);
    final deskripsiController = TextEditingController(text: currentDeskripsi);
    final hargaController = TextEditingController(text: currentHarga);
    bool isKamarAvailable = isAvailable;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Kamar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: noKamarController,
                decoration: InputDecoration(labelText: 'No. Kamar'),
              ),
              TextField(
                controller: deskripsiController,
                decoration: InputDecoration(labelText: 'Deskripsi'),
                maxLines: 3,
              ),
              TextField(
                controller: hargaController,
                decoration: InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
              ),
              Row(
                children: [
                  Text('Tersedia:'),
                  Switch(
                    value: isKamarAvailable,
                    onChanged: (value) {
                      setState(() {
                        isKamarAvailable = value;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance.collection('kamar').doc(id).update({
                    'noKamar': noKamarController.text,
                    'deskripsi': deskripsiController.text,
                    'harga': hargaController.text,
                    'isAvailable': isKamarAvailable, // Pembaruan status isAvailable
                  });
                  Navigator.pop(context);
                  print("Kamar berhasil diperbarui.");
                } catch (e) {
                  print("Gagal memperbarui kamar: $e");
                }
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
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
                Navigator.pop(context); // Menutup dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
                print('Berhasil logout');
              },
              child: Text('Keluar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hallo Admin'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getKamarList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Tidak ada kamar tersedia.'));
          }

          var kamarList = snapshot.data!.docs;
          return ListView.builder(
            itemCount: kamarList.length,
            itemBuilder: (context, index) {
              var kamar = kamarList[index];
              var id = kamar.id;
              var noKamar = kamar['noKamar'];
              var deskripsi = kamar['deskripsi'];
              var harga = kamar['harga'];
              var isAvailable = kamar['isAvailable'];

              return ListTile(
                title: Text(noKamar),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Harga: $harga'),
                    Text('Deskripsi: $deskripsi'),
                    Text('Tersedia: ${isAvailable ? 'Ya' : 'Tidak'}'),
                  ],
                ),
                onLongPress: () {
                  _deleteKamar(id);
                },
                onTap: () {
                  _showEditDialog(context, id, noKamar, deskripsi, harga, isAvailable);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToTambahKamarPage(context); // Navigasi ke halaman tambah kamar
        },
        child: Icon(Icons.add),
        tooltip: 'Tambah Kamar',
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
}

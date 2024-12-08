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

  final Map<String, String> imageMap = {
    'room1': 'assets/images/1.jpg',
    'room2': 'assets/images/2.jpg',
    'room3': 'assets/images/3.jpg',
    'room4': 'assets/images/4.jpg',
    'room5': 'assets/images/5.jpg',
  };

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

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
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PemesananPage()),
        );
        break;
      case 3:
        _showLogoutDialog(context);
        break;
    }
  }

  Stream<QuerySnapshot> _getKamarList() {
    return FirebaseFirestore.instance.collection('kamar').snapshots();
  }

  void _navigateToTambahKamarPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TambahKamarPage()),
    );
  }

  void _deleteKamar(String id) async {
    try {
      await FirebaseFirestore.instance.collection('kamar').doc(id).delete();
      print("Kamar dengan ID $id berhasil dihapus.");
    } catch (e) {
      print("Gagal menghapus kamar: $e");
    }
  }

  void _showEditDialog(BuildContext context, String id, String currentNoKamar, String currentDeskripsi, String currentHarga, bool isAvailable) {
    final noKamarController = TextEditingController(text: currentNoKamar);
    final deskripsiController = TextEditingController(text: currentDeskripsi);
    final hargaController = TextEditingController(text: currentHarga);
    bool isKamarAvailable = isAvailable;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Kamar', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: noKamarController,
                decoration: InputDecoration(labelText: 'No. Kamar', border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextField(
                controller: deskripsiController,
                decoration: InputDecoration(labelText: 'Deskripsi', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              SizedBox(height: 10),
              TextField(
                controller: hargaController,
                decoration: InputDecoration(labelText: 'Harga', border: OutlineInputBorder()),
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
                    'isAvailable': isKamarAvailable,
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Keluar', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Apakah Anda yakin ingin keluar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pop(context);
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
        title: Text('Hallo Admin', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
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
    var id = kamar.id; // Get the room ID from Firestore
    var noKamar = kamar['noKamar'];
    var deskripsi = kamar['deskripsi'];
    var harga = kamar['harga'];
    var isAvailable = kamar['isAvailable'];

    // Ganti bagian ini dengan Image.asset yang menggunakan 'noKamar'
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      elevation: 4,
      child: ListTile(
        contentPadding: EdgeInsets.all(10),
        leading: Image.asset(
          'assets/${kamar['noKamar']}.jpg', // Menggunakan noKamar sebagai nama file
          width: 50,
          height: 50,
          fit: BoxFit.cover, // Menjamin gambar menutupi area yang tersedia
        ),
        title: Text(noKamar, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text('Harga: $harga', style: TextStyle(color: Colors.green)),
            Text('Deskripsi: $deskripsi', style: TextStyle(color: Colors.black54)),
            Text('Tersedia: ${isAvailable ? 'Ya' : 'Tidak'}', style: TextStyle(color: isAvailable ? Colors.green : Colors.red)),
          ],
        ),
        onLongPress: () {
          _deleteKamar(id);
        },
        onTap: () {
          _showEditDialog(context, id, noKamar, deskripsi, harga, isAvailable);
        },
      ),
    );
  },
);

        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToTambahKamarPage(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
        tooltip: 'Tambah Kamar',
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 30),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report, size: 30),
            label: 'Laporan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list, size: 30),
            label: 'Pemesanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.exit_to_app, size: 30),
            label: 'Keluar',
          ),
        ],
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

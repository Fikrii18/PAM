import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kost/detail_kamar.dart';
import 'package:kost/login.dart';
import 'package:kost/model/mode_kamar.dart';

class HomePage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Kamar>> _getKamar() async {
    final QuerySnapshot snapshot = await _firestore.collection('kamar').get();
    return snapshot.docs.map((doc) => Kamar.fromFirestore(doc.data() as Map<String, dynamic>)).toList();
  }

  // Logout function
  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      print('Error while logging out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to logout, please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Daftar Kamar"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _logout(context);
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Kamar>>(
        future: _getKamar(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('An error occurred'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No available rooms'));
          }

          final kamarList = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: GridView.builder(
                shrinkWrap: true, // Membuat GridView lebih fleksibel
                physics: NeverScrollableScrollPhysics(), // Menonaktifkan scroll pada GridView agar SingleChildScrollView yang mengontrol
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.7,  // Mengubah aspect ratio untuk memperkecil ukuran grid item
                ),
                itemCount: kamarList.length,
                itemBuilder: (context, index) {
                  final kamar = kamarList[index];
                  return GestureDetector(
                    onTap: () {
                      if (kamar.isAvailable) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailPage(kamar: kamar),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Kamar ini sudah dipesan')),
                        );
                      }
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          // Gambar kamar dengan ukuran yang pas
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                            child: AspectRatio(
                              aspectRatio: 1.0,  // Membuat gambar menjadi persegi
                              child: Image.asset(
                                'assets/${kamar.noKamar}.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  kamar.noKamar,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Harga: Rp ${kamar.harga} / bulan',
                                  style: TextStyle(color: Colors.grey[600]),
                                  maxLines: 1, // Membatasi jumlah baris teks harga
                                  overflow: TextOverflow.ellipsis, // Teks lebih panjang akan diberi elipsis
                                ),
                              ],
                            ),
                          ),
                          // Gunakan Expanded atau Flexible untuk bagian status
                          if (!kamar.isAvailable)
                            Flexible(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  color: Colors.red.withOpacity(0.7),
                                  child: Text(
                                    'Terhuni',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

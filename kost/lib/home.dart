import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
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
      await FirebaseAuth.instance.signOut(); // Sign out from Firebase
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()), // Navigate to login page after logout
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
        actions: [
          IconButton(
            icon: Icon(Icons.logout), // Logout icon
            onPressed: () {
              _logout(context); // Call logout function when pressed
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
          return ListView.builder(
            itemCount: kamarList.length,
            itemBuilder: (context, index) {
              final kamar = kamarList[index];
              // Cek status isAvailable
              if (!kamar.isAvailable) {
                return ListTile(
                  title: Text(kamar.noKamar),
                  subtitle: Text(kamar.deskripsi),
                  trailing: Icon(Icons.lock, color: Colors.red), // Indikator kamar terkunci
                  onTap: () {
                    // Tampilkan pesan bahwa kamar sudah dipesan
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Kamar ini sudah dipesan')),
                    );
                  },
                );
              } else {
                return ListTile(
                  title: Text(kamar.noKamar),
                  subtitle: Text(kamar.deskripsi),
                  onTap: () {
                    // Navigate to DetailPage for room details
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(kamar: kamar),
                      ),
                    );
                  },
                );
              }
            },
          );
        },
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class Kamar {
  final String id;
  final String noKamar;
  final String deskripsi;
  final double harga;
  final bool isAvailable; // Status ketersediaan kamar

  Kamar({
    required this.id,
    required this.noKamar,
    required this.deskripsi,
    required this.harga,
    required this.isAvailable,
  });

  // Membaca data dari Firestore dan mengonversinya menjadi objek Kamar
  factory Kamar.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Kamar(
      id: documentId, // Mendapatkan ID dari dokumen
      noKamar: data['noKamar'],
      deskripsi: data['deskripsi'],
      harga: data['harga'].toDouble(),
      isAvailable: data['isAvailable'] ?? true, // Default true jika tidak ada
    );
  }

  // Mengupdate status ketersediaan kamar
  Future<void> updateAvailability(bool availability) async {
    await FirebaseFirestore.instance.collection('kamar').doc(id).update({
      'isAvailable': availability,
    });
  }

  // Mengambil data kamar dari Firestore
  static Future<List<Kamar>> fetchAllKamar() async {
    final snapshot = await FirebaseFirestore.instance.collection('kamar').get();
    return snapshot.docs.map((doc) => Kamar.fromFirestore(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }
}

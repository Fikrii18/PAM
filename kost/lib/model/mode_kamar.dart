class Kamar {
  final String noKamar;
  final String deskripsi;
  final String harga;
  final bool isAvailable;  // Menambahkan status isAvailable

  Kamar({
    required this.noKamar,
    required this.deskripsi,
    required this.harga,
    required this.isAvailable,
  });

  factory Kamar.fromFirestore(Map<String, dynamic> doc) {
    return Kamar(
      noKamar: doc['noKamar'] ?? '',
      deskripsi: doc['deskripsi'] ?? '',
      harga: doc['harga'] ?? '0',
      isAvailable: doc['isAvailable'] ?? true,  // Menambahkan pengecekan isAvailable
    );
  }
}

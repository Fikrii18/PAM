class Kamar {
  final String noKamar;
  final String deskripsi;
  final String harga;

  Kamar({required this.noKamar, required this.deskripsi, required this.harga});

  factory Kamar.fromFirestore(Map<String, dynamic> doc) {
    return Kamar(
      noKamar: doc['noKamar'] ?? '',
      deskripsi: doc['deskripsi'] ?? '',
      harga: doc['harga'] ?? '0',
    );
  }
}

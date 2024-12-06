import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kost/admin_page.dart';
import 'package:kost/input_pengeluaran.dart';
import 'package:kost/konfitrmasi.dart';
import 'package:kost/login.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class LaporanPage extends StatefulWidget {
  @override
  _LaporanPageState createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  int _selectedIndex = 1;

  // Fungsi untuk mencetak laporan PDF
  Future<void> _printLaporan() async {
    try {
      final pdf = pw.Document();

      // Mengambil data pengeluaran dari Firestore
      final pengeluaranSnapshot =
          await FirebaseFirestore.instance.collection('pengeluaran').get();
      List<List<String>> pengeluaranData = pengeluaranSnapshot.docs.map((doc) {
        // Mengonversi Timestamp ke DateTime dan memformatnya
        Timestamp timestamp = doc['tanggal'] as Timestamp;
        DateTime date = timestamp.toDate();
        String formattedDate =
            DateFormat('yyyy-MM-dd').format(date); // Format tanggal

        return [
          formattedDate, // Tanggal
          'Rp. ${doc['air']}',
          'Rp. ${doc['listrik']}',
          'Rp. ${doc['wifi']}',
          'Rp. ${doc['lain']}',
        ];
      }).toList();

      // Menambahkan halaman dan tabel ke PDF
      pdf.addPage(pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('Laporan Penyewa',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Data Penyewa:'),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ['Nama Penyewa', 'No Kamar', 'Durasi'],
                data: pemasukanData, // Data yang ingin ditampilkan
              ),
              pw.SizedBox(height: 20),
              pw.Text('Data Pengeluaran:'),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ['Tanggal', 'Air', 'Listrik', 'WiFi', 'Lain-lain'],
                data: pengeluaranData, // Data pengeluaran
              ),
            ],
          );
        },
      ));

      // Mencetak PDF
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      // Menampilkan error jika gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan saat mencetak laporan: $e')),
      );
    }
  }

  // Mengambil data pemasukan dan menyimpannya dalam list
  List<List<String>> pemasukanData = [];

  @override
  void initState() {
    super.initState();

    // Mengambil data pemasukan dari Firestore
    FirebaseFirestore.instance.collection('pemasukan').get().then((snapshot) {
      setState(() {
        pemasukanData = snapshot.docs.map((doc) {
          return [
            doc['namaPenyewa'] as String,
            doc['noKamar'] as String,
            doc['totalHarga'] as String,
          ];
        }).toList();
      });
    });
  }

  // Fungsi untuk menangani tap pada BottomNavigationBar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Tindakan sesuai pilihan
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

  // Dialog untuk Logout
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Logout"),
          content: Text("Apakah Anda yakin ingin logout?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text("Logout"),
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
        title: Text('Laporan'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _printLaporan,
              child: Text('Cetak Laporan'),
            ),
                        ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InputPengeluaranPage()),
                );
              },
              child: Text('Tambah Pengeluaran'),
            ),
            // Menampilkan Data Penyewa dari Firestore
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(
                      'penyewa') // Ganti dengan nama koleksi penyewa Anda
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("Tidak ada data penyewa."));
                }

                final penyewaData = snapshot.data!.docs;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data Penyewa',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: penyewaData.length,
                      itemBuilder: (context, index) {
                        var penyewa = penyewaData[index];
                        return ListTile(
                          title:
                              Text('Nama Penyewa: ${penyewa['namaPenyewa']}'),
                          subtitle: Text('No Kamar: ${penyewa['noKamar']}'),
                          trailing: Text('Durasi: ${penyewa['durasi']}'),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
            // Menampilkan Data Pemasukan dari Firestore
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('pemasukan')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("Tidak ada data pemasukan."));
                }

                final pemasukanData = snapshot.data!.docs;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data Pemasukan',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: pemasukanData.length,
                      itemBuilder: (context, index) {
                        var pemasukan = pemasukanData[index];
                        return ListTile(
                          title:
                              Text('Nama Penyewa: ${pemasukan['namaPenyewa']}'),
                          subtitle: Text('No Kamar: ${pemasukan['noKamar']}'),
                          trailing: Text('Total: ${pemasukan['totalHarga']}'),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('pengeluaran')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("Tidak ada data pengeluaran."));
                }

                final pengeluaranData = snapshot.data!.docs;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data Pengeluaran',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: pengeluaranData.length,
                      itemBuilder: (context, index) {
                        var pengeluaran = pengeluaranData[index];
                        // Mengonversi Timestamp ke DateTime dan memformatnya
                        Timestamp timestamp =
                            pengeluaran['tanggal'] as Timestamp;
                        DateTime date = timestamp.toDate();
                        String formattedDate =
                            DateFormat('yyyy-MM-dd').format(date);

                        return ListTile(
                          title: Text('Tanggal: $formattedDate'),
                          subtitle: Text(
                            'Air: ${pengeluaran['air']}, Listrik: ${pengeluaran['listrik']}, Wifi: ${pengeluaran['wifi']}, Lain: ${pengeluaran['lain']}',
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Laporan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Pemesanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.exit_to_app),
            label: 'Logout',
          ),
        ],
      ),
    );
  }
}

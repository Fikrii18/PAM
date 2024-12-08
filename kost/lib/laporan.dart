import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kost/admin_page.dart';
import 'package:kost/input_pengeluaran.dart';
import 'package:kost/login.dart';
import 'konfitrmasi.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class LaporanPage extends StatefulWidget {
  @override
  _LaporanPageState createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  int _selectedIndex = 1;
  List<List<String>> pemasukanData = [];

  @override
  void initState() {
    super.initState();
    _fetchPemasukanData();
  }

  Future<void> _fetchPemasukanData() async {
    final snapshot = await FirebaseFirestore.instance.collection('pemasukan').get();
    setState(() {
      pemasukanData = snapshot.docs.map((doc) {
        return [
          doc['namaPenyewa'] as String,
          doc['noKamar'] as String,
          doc['totalHarga'] as String,
        ];
      }).toList();
    });
  }

  Future<void> _printLaporan() async {
    try {
      final pdf = pw.Document();
      final pengeluaranSnapshot = await FirebaseFirestore.instance.collection('pengeluaran').get();

      List<List<String>> pengeluaranData = pengeluaranSnapshot.docs.map((doc) {
        Timestamp timestamp = doc['tanggal'] as Timestamp;
        DateTime date = timestamp.toDate();
        String formattedDate = DateFormat('yyyy-MM-dd').format(date);

        return [
          formattedDate,
          'Rp. ${doc['air']}',
          'Rp. ${doc['listrik']}',
          'Rp. ${doc['wifi']}',
          'Rp. ${doc['lain']}',
        ];
      }).toList();

      pdf.addPage(pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('Laporan Penyewa', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Data Penyewa:'),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(headers: ['Nama Penyewa', 'No Kamar', 'Durasi'], data: pemasukanData),
              pw.SizedBox(height: 20),
              pw.Text('Data Pengeluaran:'),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(headers: ['Tanggal', 'Air', 'Listrik', 'WiFi', 'Lain-lain'], data: pengeluaranData),
            ],
          );
        },
      ));

      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Terjadi kesalahan saat mencetak laporan: $e')));
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(context, MaterialPageRoute(builder: (context) => AdminPage()));
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (context) => LaporanPage()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (context) => PemesananPage()));
        break;
      case 3:
        _showLogoutDialog(context);
        break;
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Logout"),
          content: Text("Apakah Anda yakin ingin logout?"),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text("Batal")),
            TextButton(onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
            }, child: Text("Logout")),
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
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _printLaporan,
              child: Text('Cetak Laporan'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => InputPengeluaranPage()));
              },
              child: Text('Tambah Pengeluaran'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDataSection('Data Penyewa', 'penyewa'),
                    _buildDataSection('Data Pemasukan', 'pemasukan'),
                    _buildDataSection('Data Pengeluaran', 'pengeluaran'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home, size: 30), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.report, size: 30), label: 'Laporan'),
          BottomNavigationBarItem(icon: Icon(Icons.book, size: 30), label: 'Pemesanan'),
          BottomNavigationBarItem(icon: Icon(Icons.exit_to_app, size: 30), label: 'Logout'),
        ],
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
    );
  }

  Widget _buildDataSection(String title, String collectionName) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collectionName).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text("Tidak ada data $title.", style: TextStyle(fontSize: 16)),
          );
        }

        final data = snapshot.data!.docs;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: data.length,
              itemBuilder: (context, index) {
                var item = data[index];
                if (collectionName == 'penyewa') {
                  return ListTile(
                    title: Text('Nama Penyewa: ${item['namaPenyewa']}'),
                    subtitle: Text('No Kamar: ${item['noKamar']}'),
                    trailing: Text('Durasi: ${item['durasi']}'),
                  );
                } else if (collectionName == 'pemasukan') {
                  // Calculate total
                  double totalHarga = double.tryParse(item['totalHarga'].toString()) ?? 0.0;
                  int durasi = int.tryParse(item['durasi'].toString()) ?? 1; // Default to 1
                  double total = totalHarga * durasi;

                  // Format the total without decimal places
                  String formattedTotal = NumberFormat('#,##0', 'id_ID').format(total);

                  return ListTile(
                    title: Text('Nama Penyewa: ${item['namaPenyewa']}'),
                    subtitle: Text('No Kamar: ${item['noKamar']}'),
                    trailing: Text('Total: Rp. $formattedTotal'), // Format total without decimal places
                  );
                } else { // Data pengeluaran
                  Timestamp timestamp = item['tanggal'] as Timestamp;
                  DateTime date = timestamp.toDate();
                  String formattedDate = DateFormat('yyyy-MM-dd').format(date);

                  return ListTile(
                    title: Text('Tanggal: $formattedDate'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Air:'),
                            Text('Rp. ${item['air']}'),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Listrik:'),
                            Text('Rp. ${item['listrik']}'),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('WiFi:'),
                            Text('Rp. ${item['wifi']}'),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Lain:'),
                            Text('Rp. ${item['lain']}'),
                          ],
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
            SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

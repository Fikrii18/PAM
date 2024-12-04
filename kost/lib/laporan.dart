import 'package:flutter/material.dart';
import 'package:kost/admin_page.dart';
import 'package:kost/kelolapenyewa.dart';
import 'package:kost/login.dart';

class LaporanPage extends StatefulWidget {
  @override
  _LaporanPageState createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  int _selectedIndex = 1; // Indeks untuk 'Laporan'

  // Fungsi untuk menangani tap pada BottomNavigationBar
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
                // Logika logout: mengarahkan pengguna ke halaman login
                // Misalnya, Anda bisa menggunakan Navigator.pushReplacement untuk mengganti halaman login
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()), // Arahkan ke halaman LoginPage
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
        child: ListView(
          children: [
            // Contoh laporan: Laporan Penghuni Kamar
            Card(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text('Laporan Penghuni Kamar'),
                subtitle: Text('Laporan lengkap mengenai penghuni kamar bulan ini'),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  // Navigasi ke halaman detail laporan penghuni kamar
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => ReportDetailPage()));
                },
              ),
            ),
            // Contoh laporan: Laporan Pendapatan
            Card(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text('Laporan Pendapatan'),
                subtitle: Text('Laporan pendapatan sewa kamar bulan ini'),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  // Navigasi ke halaman detail laporan pendapatan
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => IncomeReportPage()));
                },
              ),
            ),
            // Tambahkan lebih banyak kartu untuk laporan lainnya di sini
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.blueAccent, // Set background color here
        selectedItemColor: Colors.white,     // Color of the selected item
        unselectedItemColor: Colors.grey,   // Color of the unselected items
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Admin Page',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Laporan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Kelola Penyewa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Logout',
          ),
        ],
      ),
    );
  }
}

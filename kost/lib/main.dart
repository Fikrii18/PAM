import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kost/admin_page.dart';
import 'package:kost/firebase_options.dart';
import 'package:kost/home.dart';
import 'package:kost/login.dart';
import 'package:kost/register.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Auth',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(), 
      routes: {
        '/register': (context) => RegisterPage(),
        '/home': (context) => HomePage(),
      },
    );
  }
}

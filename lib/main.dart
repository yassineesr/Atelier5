import 'package:atelier4_y_esslassi_iir5g2/login_ecran.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'firebase_options.dart';

Future<void> main() async{
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FirebaseUIAuth.configureProviders([
      EmailAuthProvider( ) ,
      ]);
        runApp(const MainApp());
    
  }


class MainApp extends StatelessWidget {
  const MainApp({super.key});


  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: login_ecran()
    );
  }
}

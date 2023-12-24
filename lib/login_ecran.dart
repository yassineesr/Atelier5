import 'package:atelier4_y_esslassi_iir5g2/listeProduits.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

class login_ecran extends StatelessWidget {
  const login_ecran({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),

      builder: (context, snapshot) {
           if ( ! snapshot.hasData) {
            return const SignInScreen();
        
      }
          return const ListeProduits();
      // return Container(color: Colors.white,

      //       child: Column(
      //         mainAxisAlignment: MainAxisAlignment.center,
      //         children: [
      //           Text(
      //             style: TextStyle(
      //             fontSize: 25.0,
      //             color: Colors.black, 
      //           ),'Email: ${snapshot.data?.email }'),
      //           ElevatedButton(
      //             onPressed: () async {
      //               await FirebaseAuth.instance.signOut();
      //             },
      //             child: Text('Se déconnecter'),
      //           ),
      //           ElevatedButton(
      //             onPressed: () async {
      //               ListeProduits();
      //             },
      //             child: Text('liste'),
      //           ),
      //         ],
              
      //       ),
      //     );
        
      },

      
      
      );
  }
  
}


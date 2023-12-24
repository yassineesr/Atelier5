import 'package:atelier4_y_esslassi_iir5g2/login_ecran.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlaceholderScreen extends StatefulWidget {
  const PlaceholderScreen({Key? key}) : super(key: key);

  @override
  State<PlaceholderScreen> createState() => _ListeProduitsState();
}

class _ListeProduitsState extends State<PlaceholderScreen> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  FavorisManager favorisManager = FavorisManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des produits'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Drawer Header',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Panier'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PanierScreen(favorisManager: favorisManager),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Se déconnecter'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          login_ecran()), 
                );
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: db.collection('produits').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Une erreur est survenue'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List<Produit> produits = snapshot.data!.docs.map((doc) {
            return Produit.fromFirestore(doc);
          }).toList();

          return ListView.builder(
            itemCount: produits.length,
            itemBuilder: (context, index) => Slidable(
              child: ProduitCard(
                produit: produits[index],
                favorisManager: favorisManager,
              ),
            ),
          );
        },
      ),
    );
  }
}

class Produit {
  String id;
  String marque;
  String designation;
  String categorie;
  double prix;
  String photo;
  int quantite;

  Produit({
    required this.id,
    required this.marque,
    required this.designation,
    required this.categorie,
    required this.prix,
    required this.photo,
    required this.quantite,
  });

  factory Produit.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Produit(
      id: doc.id,
      marque: data['marque'] ?? '',
      designation: data['designation'] ?? '',
      categorie: data['categorie'] ?? '',
      prix: (data['prix'] ?? 0.0).toDouble(),
      photo: data['photo'] ?? '',
      quantite: data['quantite'] ?? 0,
    );
  }
}

class ProduitCard extends StatelessWidget {
  const ProduitCard(
      {Key? key, required this.produit, required this.favorisManager})
      : super(key: key);
  final Produit produit;
  final FavorisManager favorisManager;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(8),
      color: Color.fromARGB(
        255,
        132,
        209,
        245,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailProduitScreen(
                  produit: produit, favorisManager: favorisManager),
            ),
          );
        },
        child: ListTile(
          contentPadding: const EdgeInsets.all(8),
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            backgroundImage: NetworkImage(produit.photo),
          ),
          title: Text(
            produit.designation,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          subtitle: Text(
            produit.marque,
            style: TextStyle(
              color: Color.fromARGB(255, 0, 255, 17),
            ),
          ),
          trailing: Text(
            '${produit.prix} €',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color.fromARGB(255, 255, 0, 0),
            ),
          ),
        ),
      ),
    );
  }
}

class FavorisManager {
  List<Produit> favoris = [];

  void addToFavorites(Produit produit) {
    favoris.add(produit);
  }
}

class DetailProduitScreen extends StatelessWidget {
  final Produit produit;
  final FavorisManager favorisManager;

  DetailProduitScreen({required this.produit, required this.favorisManager});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails du Produit'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 200,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(produit.photo),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      produit.designation,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      produit.marque,
                      style: TextStyle(
                        fontSize: 18,
                        color: Color.fromARGB(255, 0, 255, 17),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${produit.prix} €',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 255, 0, 0),
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        favorisManager.addToFavorites(produit);
                        Navigator.of(context).pop(); // Ferme l'écran de détail
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Produit ajouté aux favoris'),
                          ),
                        );
                      },
                      child: Text('Ajouter aux favoris'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Ajoutez cette classe à votre code
class PanierProduitCard extends StatelessWidget {
  final Produit produit;
  final FavorisManager favorisManager;

  PanierProduitCard(
      {Key? key, required this.produit, required this.favorisManager})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProduitCard(produit: produit, favorisManager: favorisManager);
  }
}

// Modifiez votre classe PanierScreen pour utiliser PanierProduitCard
class PanierScreen extends StatelessWidget {
  final FavorisManager favorisManager;

  PanierScreen({required this.favorisManager});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panier'),
      ),
      body: ListView.builder(
        itemCount: favorisManager.favoris.length,
        itemBuilder: (context, index) {
          return PanierProduitCard(
            produit: favorisManager.favoris[index],
            favorisManager: favorisManager,
          );
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: PlaceholderScreen(),
  ));
}

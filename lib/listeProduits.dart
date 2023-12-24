import 'dart:io';


import 'package:atelier4_y_esslassi_iir5g2/login_ecran.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ListeProduits extends StatefulWidget {
  const ListeProduits({Key? key}) : super(key: key);

  @override
  State<ListeProduits> createState() => _ListeProduitsState();
}

class _ListeProduitsState extends State<ListeProduits> {
  FirebaseFirestore db = FirebaseFirestore.instance;

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
              title: Text('Se déconnecter'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          login_ecran()), // Assurez-vous d'ajuster le nom de votre écran de connexion
                );
              },
            ),
          ],

          // Add more ListTiles for additional options
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
              endActionPane: ActionPane(
                motion: StretchMotion(),
                children: [
                  SlidableAction(
                    onPressed: (context) {
                      _supprimerProduit(produits[index].id);
                    },
                    icon: Icons.delete,
                    backgroundColor: Colors.black,
                  ),
                  SlidableAction(
                    onPressed: (context) {
                      _modifierProduit(context, produits[index]);
                    },
                    icon: Icons.edit,
                    backgroundColor: Colors.grey,
                  ),
                ],
              ),
              child: ProduitCard(
                produit: produits[index],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _ajouterProduit(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _supprimerProduit(String produitId) async {
    bool confirmation = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Voulez-vous vraiment supprimer ce produit ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Annuler
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Confirmer
              child: Text('Confirmer'),
            ),
          ],
        );
      },
    );

    // Si l'utilisateur a confirmé, supprime le produit
    if (confirmation == true) {
      try {
        await db.collection('produits').doc(produitId).delete();
      } catch (e) {
        print('Erreur lors de la suppression du produit : $e');
      }
    }
  }

  Future<void> _modifierProduit(BuildContext context, Produit produit) async {
    TextEditingController categorieController =
        TextEditingController(text: produit.categorie);
    TextEditingController designationController =
        TextEditingController(text: produit.designation);
    TextEditingController marqueController =
        TextEditingController(text: produit.marque);
    TextEditingController photoController =
        TextEditingController(text: produit.photo);
    TextEditingController prixController =
        TextEditingController(text: produit.prix.toString());
    TextEditingController quantiteController =
        TextEditingController(text: produit.quantite.toString());

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modifier le produit'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: categorieController,
                  decoration: InputDecoration(labelText: 'Catégorie'),
                ),
                TextField(
                  controller: designationController,
                  decoration: InputDecoration(labelText: 'Désignation'),
                ),
                TextField(
                  controller: marqueController,
                  decoration: InputDecoration(labelText: 'Marque'),
                ),
                TextField(
                  controller: photoController,
                  decoration: InputDecoration(labelText: 'URL de la photo'),
                ),
                TextField(
                  controller: prixController,
                  decoration: InputDecoration(labelText: 'Prix'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: quantiteController,
                  decoration: InputDecoration(labelText: 'Quantité'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                _modifierProduitFirebase(
                  produit.id,
                  categorieController.text,
                  designationController.text,
                  marqueController.text,
                  photoController.text,
                  prixController.text,
                  quantiteController.text,
                );
                Navigator.of(context).pop();
              },
              child: Text('Modifier'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _modifierProduitFirebase(
    String produitId,
    String categorie,
    String designation,
    String marque,
    String photo,
    String prix,
    String quantite,
  ) async {
    try {
      double prixValue = double.parse(prix);
      int quantiteValue = int.parse(quantite);

      await db.collection('produits').doc(produitId).update({
        'categorie': categorie,
        'designation': designation,
        'marque': marque,
        'photo': photo,
        'prix': prixValue,
        'quantite': quantiteValue,
      });
    } catch (e) {
      print('Erreur lors de la modification du produit : $e');
    }
  }

  XFile? pickedFile;
  String? imageUrl;

  Future<void> _selectImage() async {
    pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageUrl = pickedFile!.path; // Utilisez le chemin de l'image sélectionnée
      // Rafraîchit l'interface pour afficher le chemin de l'image sélectionnée
      setState(
          () {}); // Assurez-vous que l'interface utilisateur est mise à jour
    }
  }

  Future<void> _ajouterProduit(BuildContext context) async {
    TextEditingController categorieController = TextEditingController();
    TextEditingController designationController = TextEditingController();
    TextEditingController marqueController = TextEditingController();
    TextEditingController prixController = TextEditingController();
    TextEditingController quantiteController = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ajouter un produit'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: categorieController,
                  decoration: InputDecoration(labelText: 'Catégorie'),
                ),
                TextField(
                  controller: designationController,
                  decoration: InputDecoration(labelText: 'Désignation'),
                ),
                TextField(
                  controller: marqueController,
                  decoration: InputDecoration(labelText: 'Marque'),
                ),
                GestureDetector(
                  onTap: _selectImage,
                  child: AbsorbPointer(
                    child: TextField(
                      // Utilisez l'URL de l'image sélectionnée
                      readOnly: true,
                      controller: TextEditingController(text: imageUrl ?? ''),
                      decoration: InputDecoration(labelText: 'Image'),
                    ),
                  ),
                ),
                TextField(
                  controller: prixController,
                  decoration: InputDecoration(labelText: 'Prix'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: quantiteController,
                  decoration: InputDecoration(labelText: 'Quantité'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                _ajouterProduitFirebase(
                  categorieController.text,
                  designationController.text,
                  marqueController.text,
                  pickedFile?.path ?? '',
                  prixController.text,
                  quantiteController.text,
                );
                Navigator.of(context).pop();
                categorieController.clear();
                designationController.clear();
                marqueController.clear();
                prixController.clear();
                quantiteController.clear();
              },
              child: Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _ajouterProduitFirebase(
    String categorie,
    String designation,
    String marque,
    String imagePath, // Mettez à jour le type du paramètre
    String prix,
    String quantite,
  ) async {
    try {
      double prixValue = double.parse(prix);
      int quantiteValue = int.parse(quantite);
      // Téléchargez l'image vers Firebase Storage avec l'extension .jpg
      final storage = FirebaseStorage.instance;
      final imageRef = storage.ref().child('images/${Uuid().v4()}.jpg');
      await imageRef.putFile(File(imagePath));

      String imageUrl = await imageRef.getDownloadURL();

      // Enregistrez le produit dans Firestore avec l'URL de l'image
      await db.collection('produits').add({
        'categorie': categorie,
        'designation': designation,
        'marque': marque,
        'photo': imageUrl,
        'prix': prixValue,
        'quantite': quantiteValue,
      });
    } catch (e) {
      print('Erreur lors de l\'ajout du produit : $e');
    }
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
  const ProduitCard({Key? key, required this.produit}) : super(key: key);
  final Produit produit;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(8),
      color: Color.fromARGB(255, 200, 229, 242), // Set your desired background color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
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
            color: Color.fromARGB(255, 3, 22, 190),
          ),
        ),
        trailing: Text(
          '${produit.prix} €',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color.fromARGB(255, 21, 21, 21),
          ),
        ),
      ),
    );
  }
}

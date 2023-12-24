import 'package:cloud_firestore/cloud_firestore.dart';

class Produit{
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
  Map data = doc.data() as Map<String, dynamic>;
  return Produit(
    id: doc.id,
    categorie: data['categorie'],
    designation: data['designation'],
    marque: data['marque'],
    photo: data['photo'],
    prix: data['prix'],
    quantite: data['quantite'],
  );
}
}
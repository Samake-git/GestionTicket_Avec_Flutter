// AddTicketPage.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AddTicketPage extends StatefulWidget {
  @override
  _AddTicketPageState createState() => _AddTicketPageState();
}

class _AddTicketPageState extends State<AddTicketPage> {
  final TextEditingController _titleController = TextEditingController();
  String _selectedCategory = 'Pratique';
  String _selectedPriority = 'Élevée';
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _saveTicket() async {
    String titre = _titleController.text.trim();
    String categorie = _selectedCategory;
    String priorite = _selectedPriority;
    String description = _descriptionController.text.trim();

    if (titre.isNotEmpty && description.isNotEmpty) {
      try {
        // Récupérer l'utilisateur connecté
        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          try {
            // Vérifier le rôle de l'utilisateur dans Firestore
            DocumentSnapshot userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser.uid)
                .get();

            if (userDoc.exists && userDoc.get('role') == 'Apprenant') {
              try {
                // L'utilisateur a le rôle "Apprenant", créer le ticket
                CollectionReference ticketRef = FirebaseFirestore.instance.collection('tickets');

                await ticketRef.add({
                  'titre': titre,
                  'categorie': categorie,
                  'priorite': priorite,
                  'description': description,
                  'dateSoumission': FieldValue.serverTimestamp(),
                  'apprenantId': currentUser.uid,
                  'statut': 'En Attente',
                });

                // Réinitialiser les champs
                _titleController.clear();
                _descriptionController.clear();
                Navigator.of(context).pop();

              } catch (e) {
                print('Erreur lors de l\'ajout du ticket : $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Une erreur est survenue lors de l\'ajout du ticket.'),
                  ),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Vous n\'avez pas les autorisations requises pour créer un ticket.'),
                ),
              );
            }
          } catch (e) {
            print('Erreur lors de la vérification du rôle utilisateur : $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Une erreur est survenue lors de la vérification du rôle.'),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Vous devez être connecté pour créer un ticket.'),
            ),
          );
        }
      } catch (e) {
        print('Erreur générale : $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Une erreur générale est survenue.'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez remplir tous les champs obligatoires.'),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Ajouter un Ticket', style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'Titre du ticket',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Catégorie'),
                            SizedBox(height: 8.0),
                            DropdownButton<String>(
                              value: _selectedCategory,
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value!;
                                });
                              },
                              items: ['Pratique', 'Théorique', 'Technique']
                                  .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              style: TextStyle(color: Colors.black),
                              underline: Container(
                                height: 2,
                                color: Colors.teal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Priorité'),
                            SizedBox(height: 8.0),
                            DropdownButton<String>(
                              value: _selectedPriority,
                              onChanged: (value) {
                                setState(() {
                                  _selectedPriority = value!;
                                });
                              },
                              items: ['Élevée', 'Moyenne', 'Faible']
                                  .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              style: TextStyle(color: Colors.black),
                              underline: Container(
                                height: 2,
                                color: Colors.teal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      hintText: 'Décrivez le problème',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    maxLines: 4,
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 19.0),
            child: ElevatedButton(
              onPressed: _saveTicket,
              child: Text('Soumettre'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.teal,
                minimumSize: Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ticketiong/pages/ListeUtilisateurs.dart';

class AjouterUtilisateurPage extends StatefulWidget {
  @override
  _AjouterUtilisateurPageState createState() => _AjouterUtilisateurPageState();
}

class _AjouterUtilisateurPageState extends State<AjouterUtilisateurPage> {
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _role = 'Apprenant'; // Rôle par défaut
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  void _ajouterUtilisateur() async {
    final nom = _nomController.text.trim();
    final prenom = _prenomController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final dateAjout = DateTime.now();

    if (nom.isNotEmpty && prenom.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      try {
        // Créer un utilisateur avec Firebase Authentication
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Stocker les informations supplémentaires dans Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'nom': nom,
          'prenom': prenom,
          'email': email,
          'password': password,
          'role': _role,
          'dateajout': dateAjout,
        });

        _nomController.clear();
        _prenomController.clear();
        _emailController.clear();
        _passwordController.clear();
        setState(() {
          _role = 'Apprenant'; // Réinitialiser le rôle par défaut après l'ajout
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Utilisateur ajouté avec succès')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'ajout de l\'utilisateur : $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 140.0,
        title: Text('Ajouter un Utilisateur'),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontFamily: 'Poppins'
        ),
        backgroundColor: Colors.blue,
      ),

      body: Padding(

        padding: EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nomController,
                    decoration: InputDecoration(
                      labelText: 'Nom',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: TextField(
                    controller: _prenomController,
                    decoration: InputDecoration(
                      labelText: 'Prénom',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _role,
              onChanged: (String? newValue) {
                setState(() {
                  _role = newValue!;
                });
              },
              items: ['Apprenant', 'Formateur', 'Admin']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Rôle',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 30.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _ajouterUtilisateur,
                  child: Text('Ajouter Utilisateur'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    textStyle: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ListeUtilisateursPage()),
                    );
                  },
                  child: Text('Voir les Utilisateurs'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    textStyle: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
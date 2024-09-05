import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ListeUtilisateursPage extends StatelessWidget {
  final _firestore = FirebaseFirestore.instance;

  void _modifierUtilisateur(BuildContext context, String id, Map<String, dynamic> utilisateur) {
    final _nomController = TextEditingController(text: utilisateur['nom']);
    final _prenomController = TextEditingController(text: utilisateur['prenom']);
    final _emailController = TextEditingController(text: utilisateur['email']);
    final _passwordController = TextEditingController(text: utilisateur['password']);
    String _role = utilisateur['role'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modifier Utilisateur'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _nomController,
                  decoration: InputDecoration(labelText: 'Nom'),
                ),
                TextField(
                  controller: _prenomController,
                  decoration: InputDecoration(labelText: 'Prénom'),
                ),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Mot de passe'),
                ),
                DropdownButtonFormField<String>(
                  value: _role,
                  onChanged: (String? newValue) {
                    _role = newValue!;
                  },
                  items: ['Apprenant', 'Formateur', 'Admin']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: 'Rôle'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _firestore.collection('users').doc(id).update({
                  'nom': _nomController.text,
                  'prenom': _prenomController.text,
                  'email': _emailController.text,
                  'password': _passwordController.text,
                  'role': _role,
                });
                Navigator.of(context).pop();
              },
              child: Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  void _supprimerUtilisateur(String id) async {
    await _firestore.collection('users').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Utilisateurs'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                final utilisateur = doc.data() as Map<String, dynamic>;

                return Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9.0),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(13.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${utilisateur['nom']} ${utilisateur['prenom']}',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text('Email: ${utilisateur['email']}'),
                        SizedBox(height: 4.0),
                        Text('Mot de passe: ${utilisateur['password']}'),
                        SizedBox(height: 4.0),
                        Text('Rôle: ${utilisateur['role']}'),
                        SizedBox(height: 16.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit,color: Colors.blue,),
                              onPressed: () => _modifierUtilisateur(context, doc.id, utilisateur),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red,),
                              onPressed: () => _supprimerUtilisateur(doc.id),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
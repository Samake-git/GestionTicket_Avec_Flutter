import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TermesUtilisationPage extends StatefulWidget {
  @override
  _TermesUtilisationPageState createState() => _TermesUtilisationPageState();
}

class _TermesUtilisationPageState extends State<TermesUtilisationPage> {
  final _termesController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  String? _currentDocId; // ID du document actuellement modifié

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Termes d\'utilisation'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Scrollbar(
                child: SingleChildScrollView(
                  child: TextFormField(
                    controller: _termesController,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Saisissez les termes d\'utilisation',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.0), // Réduction de l'espace
            ElevatedButton(
              onPressed: _saveTermes,
              child: Text('Enregistrer'),
            ),
            SizedBox(height: 8.0), // Réduction de l'espace
            Expanded(
              flex: 2,
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('termesUtilisation').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return Scrollbar(
                    child: ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final doc = snapshot.data!.docs[index];
                        return ListTile(
                          title: Text(doc['contenu']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => _editTermes(doc.id, doc['contenu']),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _deleteTermes(doc.id),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveTermes() async {
    final contenu = _termesController.text.trim();
    if (contenu.isNotEmpty) {
      if (_currentDocId == null) {
        // Ajouter un nouveau document si aucun document n'est actuellement modifié
        await _firestore.collection('termesUtilisation').add({'contenu': contenu});
      } else {
        // Mettre à jour le document existant
        await _firestore.collection('termesUtilisation').doc(_currentDocId).update({'contenu': contenu});
        _currentDocId = null; // Réinitialiser après mise à jour
      }
      _termesController.clear();
    }
  }

  void _editTermes(String id, String contenu) {
    setState(() {
      _currentDocId = id; // Stocker l'ID du document pour modification
      _termesController.text = contenu;
    });
  }

  void _deleteTermes(String id) async {
    await _firestore.collection('termesUtilisation').doc(id).delete();
    if (id == _currentDocId) {
      _currentDocId = null;
      _termesController.clear();
    }
  }
}

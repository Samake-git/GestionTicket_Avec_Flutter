import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditTicketPage extends StatefulWidget {
  static const routeName = '/edit-ticket';
  final String ticketId;

  EditTicketPage({required this.ticketId});

  @override
  _EditTicketPageState createState() => _EditTicketPageState();
}

class _EditTicketPageState extends State<EditTicketPage> {
  final TextEditingController _titleController = TextEditingController();
  String _selectedCategory = 'Pratique';
  String _selectedPriority = 'Élevée';
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTicketData();
  }

  Future<void> _loadTicketData() async {
    DocumentSnapshot ticketSnapshot = await FirebaseFirestore.instance
        .collection('tickets')
        .doc(widget.ticketId)
        .get();

    setState(() {
      _titleController.text = ticketSnapshot['titre'];
      _selectedCategory = ticketSnapshot['categorie'];
      _selectedPriority = ticketSnapshot['priorite'];
      _descriptionController.text = ticketSnapshot['description'];
      _isLoading = false;
    });
  }

  Future<void> _updateTicket() async {
    String titre = _titleController.text.trim();
    String categorie = _selectedCategory;
    String priorite = _selectedPriority;
    String description = _descriptionController.text.trim();

    if (titre.isNotEmpty && description.isNotEmpty) {
      try {
        DocumentReference ticketDoc = FirebaseFirestore.instance.collection('tickets').doc(widget.ticketId);
        await ticketDoc.update({
          'titre': titre,
          'categorie': categorie,
          'priorite': priorite,
          'description': description,
          'dateModification': FieldValue.serverTimestamp(),
        });

        Navigator.of(context).pop();
      } catch (e) {
        print('Erreur lors de la modification du ticket : $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Une erreur est survenue lors de la modification du ticket.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs obligatoires.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text('Modifier le ticket', style: TextStyle(color: Theme.of(context).textTheme.titleLarge!.color)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
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
                      hintStyle: TextStyle(color: Theme.of(context).hintColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Catégorie', style: Theme.of(context).textTheme.titleMedium),
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
                              style: Theme.of(context).textTheme.bodyLarge,
                              underline: Container(
                                height: 2,
                                color: Theme.of(context).colorScheme.primary,
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
                            Text('Priorité', style: Theme.of(context).textTheme.titleMedium),
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
                              style: Theme.of(context).textTheme.bodyLarge,
                              underline: Container(
                                height: 2,
                                color: Theme.of(context).colorScheme.primary,
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
                      hintStyle: TextStyle(color: Theme.of(context).hintColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    style: Theme.of(context).textTheme.bodyLarge,
                    maxLines: 4,
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: Theme.of(context).bottomAppBarColor,
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 19.0),
            child: ElevatedButton(
              onPressed: _updateTicket,
              child: Text('Modifier'),
              style: ElevatedButton.styleFrom(
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

extension on ThemeData {
  get bottomAppBarColor => null;
}

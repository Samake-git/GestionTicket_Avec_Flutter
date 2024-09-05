import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ticketiong/pages/DiscussionPage.dart';


class TicketRepondrePage extends StatefulWidget {
  final String ticketId;
  final String dateCreation;
  final String titre;
  final String status;
  final String description;
  final String? reponseTicket;
  final String creatorTicketUserId;

  TicketRepondrePage({
    required this.ticketId,
    required this.dateCreation,
    required this.titre,
    required this.status,
    required this.description,
    this.reponseTicket,
    required this.creatorTicketUserId,
  });

  @override
  _TicketRepondrePageState createState() => _TicketRepondrePageState();
}

class _TicketRepondrePageState extends State<TicketRepondrePage> {
  final _formKey = GlobalKey<FormState>();
  final _reponseController = TextEditingController();
  String? _userId;
  bool _isTicketTaken = false;
  bool _isTicketResolved = false;

  @override
  void initState() {
    super.initState();
    _getUserId();
    _checkTicketStatus();
  }

  Future<void> _getUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
    }
    print(_userId);
  }


  Future<void> _checkTicketStatus() async {
    final snapshot = await FirebaseFirestore.instance.collection('tickets').doc(widget.ticketId).get();
    final data = snapshot.data();
    if (data != null && data['statut'] == 'résolu') {
      setState(() {
        _isTicketResolved = true;
      });
    }
  }

  Future<void> _sendReponse() async {
    final reponse = _reponseController.text.trim();
    if (_userId != null && reponse.isNotEmpty && _isTicketTaken) {
      try {
        await FirebaseFirestore.instance.collection('reponsetickets').add({
          'ticketId': widget.ticketId,
          'userId': _userId,
          'reponse': reponse,
          'createdAt': FieldValue.serverTimestamp(),
        });
        _reponseController.clear();
        _updateTicketStatus();  // Mettre à jour le statut après la réponse
        Navigator.of(context).pop();
      } catch (e) {
        print('Erreur lors de l\'enregistrement de la réponse : $e');
      }
    }
  }


  Future<void> _prendre_enChargeTicketStatus() async {
    if (!_isTicketTaken && !_isTicketResolved) {
      bool shouldTakeCharge = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Prendre en charge le ticket ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Non'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Oui'),
            ),
          ],
        ),
      ) ?? false;

      if (shouldTakeCharge) {
        await FirebaseFirestore.instance.collection('tickets').doc(widget.ticketId).update({
          'statut': 'En cours',
          'assignedUserId': _userId,  // Assignation du ticket au formateur
        });
        setState(() {
          _isTicketTaken = true;
        });
      }
    }
  }



  Future<void> _updateTicketStatus() async {
    await FirebaseFirestore.instance.collection('tickets').doc(widget.ticketId).update({
      'statut': 'résolu',
    });
    setState(() {
      _isTicketResolved = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.titre,
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 150.0,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: widget.status == 'en-attente' ? Colors.green : Colors.red,
                      width: 2.0,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: Image.asset(
                            'image/infotockets.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8.0,
                        right: 8.0,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          decoration: BoxDecoration(
                            color: widget.status == 'en-attente' ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: Text(
                            widget.status,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Text(
              widget.dateCreation,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Description',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  widget.description,
                  style: TextStyle(
                    fontSize: 11.0,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            if (widget.reponseTicket != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.0),
                  Text(
                    'Réponse du ticket:',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    widget.reponseTicket!,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            SizedBox(height: 16.0),
            if (!_isTicketTaken && !_isTicketResolved)
              ElevatedButton(
                onPressed: () {
                  _prendre_enChargeTicketStatus();
                },
                child: Text('Prendre en charge le ticket'),
              ),
            if (_isTicketTaken && !_isTicketResolved)
              Text(
                'Ticket pris en charge',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            SizedBox(height: 16.0),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _reponseController,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Entrez votre réponse',
                  border: OutlineInputBorder(),
                ),
                enabled: _isTicketTaken && !_isTicketResolved,  // Désactivation selon l'état du ticket
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une réponse.';
                  }
                  return null;
                },
              ),
            ),

            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _sendReponse();
                    }
                  },
                  child: Text('Envoyer'),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                if (_userId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DiscussionPage(
                        creatorTicketUserId: widget.creatorTicketUserId,
                        formateurId: "",
                        ticketId: widget.ticketId,
                      ),
                    ),
                  );
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat),
                  SizedBox(width: 8.0),
                  Text('Discuter avec l\'apprenant'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
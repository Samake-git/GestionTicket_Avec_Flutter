import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ticketiong/pages/DiscussionPage.dart';

class TicketDetailsPage extends StatefulWidget {
  final String ticketId;
  final String dateCreation;
  final String titre;
  final String status;
  final String description;
  final String? reponseTicket;
  final String formateurId;
  String creatorTicketUserId;

  TicketDetailsPage({
    required this.ticketId,
    required this.dateCreation,
    required this.titre,
    required this.status,
    required this.description,
    this.reponseTicket,
    required this.formateurId,
    required this.creatorTicketUserId,
  });

  @override
  _TicketDetailsPageState createState() => _TicketDetailsPageState();
}

class _TicketDetailsPageState extends State<TicketDetailsPage> {
  String? _reponseTicket;

  Future<void> _getTicketCreatorId() async {
    try {
      final ticketDoc = await FirebaseFirestore.instance
          .collection('tickets')
          .doc(widget.ticketId)
          .get();

      if (ticketDoc.exists) {
        final creatorId = ticketDoc.data()?['apprenantId'] as String?;
        if (creatorId != null) {
          setState(() {
            widget.creatorTicketUserId = creatorId;
          });
        }
      }
    } catch (e) {
      print('Erreur lors de la récupération de l\'ID du créateur du ticket : $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _getTicketCreatorId();
    _getReponseTicket();
  }


  Future<void> _getReponseTicket() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('reponsetickets')
          .where('ticketId', isEqualTo: widget.ticketId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final reponseDocument = querySnapshot.docs.first;
        setState(() {
          _reponseTicket = reponseDocument.data()['reponse'] as String;
        });
      }
    } catch (e) {
      print('Erreur lors de la récupération de la réponse du ticket : $e');
    }
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
                  ),
                  child: Center(
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: Image.asset(
                        'image/infotockets.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8.0,
                  right: 8.0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: widget.status == 'en-cours' ? Colors.green : Colors.red,
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
            if (_reponseTicket != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Réponse du ticket'),
                          content: Text(_reponseTicket!),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text('Fermer'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.message),
                        SizedBox(width: 10.0),
                        Text('Réponse du ticket'),
                      ],
                    ),
                  ),
                ],
              ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DiscussionPage(
                      ticketId: widget.ticketId ?? "NULL",
                      formateurId: widget.formateurId ?? "NULL",
                      creatorTicketUserId: widget.creatorTicketUserId ?? "NULL",
                    ),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat),
                  SizedBox(width: 8.0),
                  Text('Discuter avec un formateur'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


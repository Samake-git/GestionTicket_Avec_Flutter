import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import du package intl
import 'package:ticketiong/pages/DiscussionPage.dart';

class TicketDiscussionsOverviewPage extends StatefulWidget {
  @override
  _TicketDiscussionsOverviewPageState createState() => _TicketDiscussionsOverviewPageState();
}

class _TicketDiscussionsOverviewPageState extends State<TicketDiscussionsOverviewPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<QueryDocumentSnapshot> _tickets = [];
  List<QueryDocumentSnapshot> _unreadNotifications = [];

  @override
  void initState() {
    super.initState();
    _loadTicketData();
    _listenForNewNotifications();
  }

  Future<void> _loadTicketData() async {
    final currentUserId = _auth.currentUser?.uid;

    if (currentUserId != null) {
      // Récupérer les tickets où l'utilisateur est soit apprenant, soit formateur
      final ticketsSnapshot = await _firestore
          .collection('tickets')
          .where('apprenantId', isEqualTo: currentUserId)
          .get();

      final formateurTicketsSnapshot = await _firestore
          .collection('tickets')
          .where('assignedUserId', isEqualTo: currentUserId)
          .get();

      // Concaténer les listes de tickets
      List<QueryDocumentSnapshot> allTickets = [
        ...ticketsSnapshot.docs,
        ...formateurTicketsSnapshot.docs,
      ];

      // Supprimer les doublons
      allTickets = allTickets.toSet().toList();

      // Filtrer les tickets pour ne garder que ceux qui ont à la fois un apprenant et un formateur
      final filteredTickets = allTickets.where((ticket) {
        final data = ticket.data() as Map<String, dynamic>;
        return data['apprenantId'] != null && data['assignedUserId'] != null;
      }).toList();

      setState(() {
        _tickets = filteredTickets;
      });
    }
  }


  Future<void> _listenForNewNotifications() async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId != null) {
      _firestore
          .collection('notifications')
          .where('receiverId', isEqualTo: currentUserId)
          .where('read', isEqualTo: false)
          .snapshots()
          .listen((snapshot) {
        setState(() {
          _unreadNotifications = snapshot.docs;
        });
      });
    }
  }

  bool _hasUnreadNotifications(String ticketId) {
    return _unreadNotifications.any((notification) => notification['ticketId'] == ticketId);
  }

  String _formatDate(Timestamp timestamp) {
    final DateTime date = timestamp.toDate();
    final DateFormat formatter = DateFormat('dd/MM/yyyy à HH:mm');
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tickets.isEmpty
          ? Center(
        child: Text(
          'Aucune discussion disponible.',
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: _tickets.length,
        itemBuilder: (context, index) {
          final ticket = _tickets[index];
          final lastMessage = ticket['description'] ?? 'Pas de message';
          final hasUnreadNotifications = _hasUnreadNotifications(ticket.id);
          final Timestamp dateSoumission = ticket['dateSoumission'];

          return GestureDetector(
            onTap: () {
              // Naviguer vers la page de discussion
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DiscussionPage(
                    creatorTicketUserId: ticket['apprenantId'],
                    formateurId: ticket['assignedUserId'],
                    ticketId: ticket.id,
                  ),
                ),
              );
            },
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                ticket['titre'] ?? 'Titre indisponible',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              if (hasUnreadNotifications)
                                Icon(
                                  Icons.notifications,
                                  color: Colors.red,
                                  size: 20,
                                ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                              SizedBox(width: 4),
                              Text(
                                'Soumis le : ${_formatDate(dateSoumission)}',
                                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Priorité: ${ticket['priorite']}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: ticket['priorite'] == 'Élevée' ? Colors.red : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[400],
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

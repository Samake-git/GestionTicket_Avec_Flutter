import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ticketiong/model/TicketModel.dart';
import 'package:ticketiong/pages/AddTicketPage.dart';
import 'package:ticketiong/pages/ModifierTicketPage.dart';
import 'package:ticketiong/pages/PageTicketDiscussion.dart';
import 'package:ticketiong/pages/Parametre.dart';
import 'package:ticketiong/pages/TicketDetailsPage.dart';

class ApprenaantDashboard extends StatefulWidget {
  @override
  _ApprenaantDashboardState createState() => _ApprenaantDashboardState();
}

class _ApprenaantDashboardState extends State<ApprenaantDashboard> {
  int _selectedIndex = 0;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _getUserId();
  }

  void _deleteTicket(Ticket ticket) async {
    try {
      await FirebaseFirestore.instance
          .collection('tickets')
          .doc(ticket.id)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ticket supprimé avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression du ticket')),
      );
    }
  }

  Future<void> _checkTicketStatusAndNavigate(BuildContext context, String ticketId) async {
    try {
      DocumentSnapshot ticketSnapshot = await FirebaseFirestore.instance
          .collection('tickets')
          .doc(ticketId)
          .get();

      if (!ticketSnapshot.exists) {
        throw Exception('Le ticket avec cet ID n\'existe pas.');
      }

      String ticketStatus = ticketSnapshot['statut'];

      if (ticketStatus == 'résolu') {
        // Affichez un message si le ticket est résolu
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Modification impossible'),
              content: Text('Ce ticket a été résolu et ne peut pas être modifié.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        // Si le ticket n'est pas résolu, naviguez vers la page de modification
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => EditTicketPage(ticketId: ticketId),
        ));
      }
    } catch (e) {
      print('Erreur lors de la vérification du statut du ticket : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la vérification du statut du ticket.')),
      );
    }
  }

  Future<void> _getUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _selectedIndex != 2 ? AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        leading: SizedBox(),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Theme.of(context).iconTheme.color),
            onPressed: () {
              // Logique de notification
            },
          ),
        ],
      ) : null,
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: _buildBody(),
            ),
          ),
          if (_selectedIndex == 0) // Afficher le bouton flottant uniquement sur la page d'accueil
            Padding(
              padding: EdgeInsets.only(right: 16.0, bottom: 16.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  onPressed: () {
                    _navigateToAddTicketPage();
                  },
                  child: Icon(Icons.add),
                  backgroundColor: Theme.of(context).floatingActionButtonTheme.backgroundColor,
                  shape: CircleBorder(),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Discussion',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        selectedItemColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return _buildTicketsPage();
      case 2:
        return _buildProfilePage();
      default:
        return SizedBox.shrink();
    }
  }

  void _navigateToAddTicketPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddTicketPage()),
    );
  }

  Widget _buildHomePage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 32.0,
              backgroundImage: AssetImage('assets/image/samake.png'),
            ),
            SizedBox(width: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour, Bienvenue',
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.0),
                Text(
                  'Nous sommes ravis de vous accueillir !',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 20.0),
        TextField(
          decoration: InputDecoration(
            hintText: 'Que recherchez-vous ?',
            prefixIcon: Icon(Icons.search, color: Theme.of(context).iconTheme.color),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        SizedBox(height: 20.0),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _userId != null
                ? FirebaseFirestore.instance
                .collection('tickets')
                .where('apprenantId', isEqualTo: _userId)
                .snapshots()
                : Stream.empty(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Erreur: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('Aucun ticket trouvé.'));
              }

              final tickets = snapshot.data!.docs
                  .map((doc) => Ticket.fromDocument(doc))
                  .toList();

              return ListView.builder(
                itemCount: tickets.length,
                itemBuilder: (context, index) {
                  final ticket = tickets[index];
                  return _buildTicketItem(
                    ticket: ticket,
                    context: context,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTicketsPage() {
    return TicketDiscussionsOverviewPage();
  }

  Widget _buildProfilePage() {
    return SettingsPage();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildTicketItem({
    required Ticket ticket,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: () {
        // Naviguer vers la page de détails du ticket
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TicketDetailsPage(
              ticketId: ticket.id,
              titre: ticket.titre,
              description: ticket.description,
              status: ticket.statut,
              dateCreation: ticket.dateSoumission,
              formateurId: "",
              creatorTicketUserId: ticket.apprenantId,
            ),
          ),
        );
      },
      child: Card(
        color: Theme.of(context).cardColor,
        elevation: 2.0,
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.titre,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Row(
                      children: [
                        Text(
                          'Statut: ${ticket.statut}',
                          style: TextStyle(
                            color: ticket.statut == 'résolu'
                                ? Theme.of(context).colorScheme.secondary
                                : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        SizedBox(width: 16.0),
                        Text(
                          'Créé le: ${ticket.dateSoumission}',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium!.color?.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Theme.of(context).iconTheme.color),
                    onPressed: () {
                      _checkTicketStatusAndNavigate(context, ticket.id);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                    onPressed: () {
                      _deleteTicket(ticket);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

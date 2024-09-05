import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ticketiong/Widget/OptionTicketItem.dart';
import 'package:ticketiong/model/TicketModel.dart';
import 'package:ticketiong/pages/AddTicketPage.dart';
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
      backgroundColor: Colors.white,
      appBar:  _selectedIndex != 2 ? AppBar(
        backgroundColor: Colors.white,
        leading: SizedBox(),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.black),
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
          if (_selectedIndex ==
              0) // Afficher le bouton flottant uniquement sur la page d'accueil
            Padding(
              padding: EdgeInsets.only(right: 16.0, bottom: 16.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  onPressed: () {
                    _navigateToAddTicketPage();
                  },
                  child: Icon(Icons.add),
                  backgroundColor: Colors.blue,
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
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.0),
                Text(
                  'Nous sommes ravis de vous accueillir !',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 20.0),
        TextField(
          decoration: InputDecoration(
            hintText: 'Que recherchez-vous ?',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        SizedBox(height: 20.0),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _userId != null
                ? FirebaseFirestore.instance
                .collection('tickets')
                .where('apprenantId',
                isEqualTo: _userId) // Filtrage par ID utilisateur
                .snapshots()
                : Stream.empty(),
            // Flux vide si l'ID utilisateur n'est pas encore disponible
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
                    ticket: ticket,  // Passer l'objet Ticket complet ici
                    context: context, // Passer le contexte
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
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Row(
                      children: [
                        Text(
                          'Statut: ${ticket.statut}',
                          style: TextStyle(
                            color: ticket.statut == 'résolu' ? Colors.green : Colors.orange,
                          ),
                        ),
                        SizedBox(width: 16.0),
                        Text(
                          'Créé le: ${ticket.dateSoumission}',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              TicketItemOptions(
                ticket: ticket,
                onDelete: () async {
                  try {
                    // Supprimer le ticket de Firebase Firestore
                    await FirebaseFirestore.instance
                        .collection('tickets')
                        .doc(ticket.id)
                        .delete();

                    // Mettre à jour l'interface utilisateur après la suppression
                    setState(() {});
                  } catch (e) {
                    // Gérer l'erreur de suppression et afficher un message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur lors de la suppression du ticket: $e')),
                    );
                  }
                },
                onEdit: () {
                 //
                },
              ),
            ],
          ),
        ),
      ),
    );
  }



}
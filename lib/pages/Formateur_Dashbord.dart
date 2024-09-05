import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ticketiong/model/TicketModel.dart';
import 'package:ticketiong/pages/PageTicketDiscussion.dart';
import 'package:ticketiong/pages/Parametre.dart';
import 'package:ticketiong/pages/TicketRepondrePage.dart';


class FormateurDashbord extends StatefulWidget {
  @override
  _FormateurDashbord createState() => _FormateurDashbord();
}

class _FormateurDashbord extends State<FormateurDashbord> {
  int _selectedIndex = 0;
  String? _userId;
  String _selectedCategory = 'Tous';

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
      appBar: _selectedIndex != 2 ? AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: SizedBox(),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              // Logique de notification
            },
          ),
        ],
      ): null,
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: _buildBody(),
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
        // Boutons de filtrage
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: () => _filterTickets('Tous'),
              child: Text('Tous'),
            ),
            ElevatedButton(
              onPressed: () => _filterTickets('Théorique'),
              child: Text('Théorique'),
            ),
            ElevatedButton(
              onPressed: () => _filterTickets('Pratique'),
              child: Text('Pratique'),
            ),
            ElevatedButton(
              onPressed: () => _filterTickets('Technique'),
              child: Text('Technique'),
            ),
          ],
        ),
        SizedBox(height: 20.0),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('tickets')
                .snapshots(),
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

              // Filtrer les tickets en fonction de la catégorie sélectionnée
              final tickets = snapshot.data!.docs
                  .map((doc) => Ticket.fromDocument(doc))
                  .where((ticket) => _selectedCategory == 'Tous' || ticket.categorie == _selectedCategory)
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
        )


      ],
    );
  }

  Widget _buildTicketsPage() {
    return TicketDiscussionsOverviewPage();
  }

  Widget _buildProfilePage() {
    return SettingsPage();
  }

  void _filterTickets(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildTicketItem({
    required Ticket ticket, // Passer l'objet Ticket complet ici
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: () {
        // Naviguer vers la page de détails du ticket en passant l'ID
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TicketRepondrePage(
              ticketId: ticket.id, // Passer l'identifiant du document
              titre: ticket.titre,
              description: ticket.description,
              status: ticket.statut,
              dateCreation: ticket.dateSoumission,
              creatorTicketUserId: ticket.apprenantId,
            ),
          ),
        );
      },
      child: Card(
        elevation: 2.0,
        child: Padding(
          padding: EdgeInsets.all(10.0),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Statut: ${ticket.statut}',
                    style: TextStyle(
                      color: ticket.statut == 'résolu' ? Colors.green : Colors.orange,
                    ),
                  ),
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
      ),
    );
  }


}
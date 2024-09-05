import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ticketiong/model/TicketModel.dart';
import 'package:ticketiong/pages/ParametreAdmin.dart';
import 'package:ticketiong/pages/TicketRepondrePage.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _totalTickets = 0;
  int _openTickets = 0;
  int _resolvedTickets = 0;
  int _urgentTickets = 0;
  int _ordinaryTickets = 0;
  int _selectedIndex = 0;
  String _selectedCategory = 'Tous';

  @override
  void initState() {
    super.initState();
    _fetchTicketData();
  }

  Future<void> _fetchTicketData() async {
    final ticketsSnapshot = await FirebaseFirestore.instance.collection('tickets').get();

    setState(() {
      _totalTickets = ticketsSnapshot.docs.length;
      _openTickets = ticketsSnapshot.docs.where((doc) => doc['statut'] == 'En cours').length;
      _resolvedTickets = ticketsSnapshot.docs.where((doc) => doc['statut'] == 'résolu').length;
      _urgentTickets = ticketsSnapshot.docs.where((doc) => doc['priorite'] == 'Élevée').length;
      _ordinaryTickets = ticketsSnapshot.docs.where((doc) => doc['priorite'] == 'Faible').length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex != 2 ? AppBar(
        backgroundColor: Colors.blue,
        toolbarHeight: 140.0,
        elevation: 0,
        leading: SizedBox(),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              _onItemTapped(2);
            },
          ),
        ],
      ): null,
      body: _buildContent(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Tickets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Paramètres',
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return TicketsPage();
      case 2:
        return SettingsPage();
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildDashboardContent() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoCard('Tickets soumis', _totalTickets, Colors.blue),
              _buildInfoCard('Tickets en-cours', _openTickets, Colors.orange),
            ],
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoCard('Tickets résolus', _resolvedTickets, Colors.green),
              _buildInfoCard('Tickets urgents', _urgentTickets, Colors.red),
            ],
          ),
          SizedBox(height: 16.0),
          _buildInfoCard('Tickets ordinaires', _ordinaryTickets, Colors.grey),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, int value, Color color) {
    return Expanded(
      child: Card(
        elevation: 4.0,
        color: color,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

class TicketsPage extends StatefulWidget {
  @override
  _TicketsPageState createState() => _TicketsPageState();
}


class _TicketsPageState extends State<TicketsPage> {
  List<Ticket> _tickets = [];
  List<Ticket> _filteredTickets = [];
  String _selectedCategory = 'Tous';

  @override
  void initState() {
    super.initState();
    _fetchAndFilterTickets();
  }

  Future<void> _fetchAndFilterTickets() async {
    final ticketsSnapshot = await FirebaseFirestore.instance.collection('tickets').get();
    _tickets = ticketsSnapshot.docs.map((doc) => Ticket.fromDocument(doc)).toList();
    _filterTickets(_selectedCategory);
  }

  void _filterTickets(String category) {
    setState(() {
      _selectedCategory = category;
      _filteredTickets = _selectedCategory == 'Tous'
          ? _tickets
          : _tickets.where((ticket) => ticket.categorie == _selectedCategory).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          child: ListView.builder(
            itemCount: _filteredTickets.length,
            itemBuilder: (context, index) {
              final ticket = _filteredTickets[index];
              return _buildTicketItem(
                ticket: ticket,
                context: context,
              );
            },
          ),
        )
      ],
    );
  }
}

Widget _buildTicketItem({
  required Ticket ticket,
  required BuildContext context,
}) {
  return GestureDetector(
    onTap: () {
      // Naviguer vers la page de détails du ticket en passant l'ID
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TicketRepondrePage(
            ticketId: ticket.id,
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

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {


  @override
  Widget build(BuildContext context) {
    return SettingsPageAdmin ();
  }
}
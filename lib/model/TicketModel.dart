import 'package:cloud_firestore/cloud_firestore.dart';

class Ticket {
  final String id;
  final String apprenantId;
  final String categorie;
  final String dateSoumission;
  final String description;
  final String priorite;
  final String titre;
  final String statut;

  Ticket({
    required this.id,
    required this.apprenantId,
    required this.categorie,
    required this.dateSoumission,
    required this.description,
    required this.priorite,
    required this.titre,
    required this.statut,
  });

  factory Ticket.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Ticket(
      id: doc.id,
      apprenantId: data['apprenantId'] ?? '',
      categorie: data['categorie'] ?? '',
      dateSoumission: _formatDate(data['dateSoumission']),
      description: data['description'] ?? '',
      priorite: data['priorite'] ?? '',
      titre: data['titre'] ?? '',
      statut: data['statut'],

    );
  }

  static String _formatDate(Timestamp timestamp) {
    // Convert Timestamp to DateTime
    DateTime date = timestamp.toDate();
    // Format DateTime to string (e.g., '12 avril 2023')
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  static String _getMonthName(int month) {
    const monthNames = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return monthNames[month - 1];
  }
}

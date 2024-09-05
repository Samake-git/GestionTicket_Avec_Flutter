
import 'package:flutter/material.dart';
import 'package:ticketiong/model/TicketModel.dart';

class TicketItemOptions extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  TicketItemOptions({
    required this.ticket,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: Icon(Icons.more_vert),
      itemBuilder: (context) => [
        PopupMenuItem(
          child: Text('Supprimer'),
          onTap: () {
            // Fermer le menu déroulant
            Navigator.of(context).pop();
            onDelete();
          },
        ),
        PopupMenuItem(
          child: Text('Modifier'),
          onTap: () {
            // Fermer le menu déroulant
            Navigator.of(context).pop();
            onEdit();
          },
        ),
      ],
    );
  }
}
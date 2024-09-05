import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DiscussionPage extends StatefulWidget {
  final String creatorTicketUserId; // ID de l'apprenant qui a créé le ticket
  final String formateurId; // ID du formateur
  final String ticketId; // ID du ticket

  DiscussionPage({
    required this.creatorTicketUserId,
    required this.formateurId,
    required this.ticketId,
  });

  @override
  _DiscussionPageState createState() => _DiscussionPageState();
}

class _DiscussionPageState extends State<DiscussionPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
  }

  Future<void> _getCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUserId = user.uid;
      });
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isNotEmpty && _currentUserId != null) {
      try {
        await FirebaseFirestore.instance.collection('discussions').add({
          'creatorUserId': widget.creatorTicketUserId,
          'formateurUserId': _currentUserId,
          'message': message,
          'ticketId': widget.ticketId,
          'timestamp': FieldValue.serverTimestamp(),
          'read': false, // Initialiser le champ 'read' à false
        });

        // Envoyer une notification
        await _sendNotification(
          receiverId: widget.creatorTicketUserId == _currentUserId
              ? widget.formateurId
              : widget.creatorTicketUserId,
          senderId: _currentUserId!,
          message: 'Vous avez un nouveau message pour le ticket #${widget.ticketId}',
          ticketId: widget.ticketId,
        );

        _messageController.clear();
        _scrollToBottom();
      } catch (e) {
        print('Erreur lors de l\'envoi du message : $e');
      }
    }
  }

  Future<void> _sendNotification({
    required String receiverId,
    required String senderId,
    required String message,
    required String ticketId,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'receiverId': receiverId,
        'senderId': senderId,
        'message': message,
        'ticketId': ticketId,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });
    } catch (e) {
      print('Erreur lors de l\'envoi de la notification : $e');
    }
  }

  Future<void> _markMessageAsRead(String messageId) async {
    try {
      await FirebaseFirestore.instance.collection('discussions').doc(messageId).update({
        'read': true,
      });
    } catch (e) {
      print('Erreur lors de la mise à jour du statut de lecture : $e');
    }
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Discussion avec l\'apprenant'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('discussions')
                  .where('ticketId', isEqualTo: widget.ticketId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur : ${snapshot.error}'));
                }

                final messages = snapshot.data?.docs ?? [];
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isCurrentUserSender = message['formateurUserId'] == _currentUserId;
                    final isMessageFromCreator = message['creatorUserId'] == _currentUserId;
                    final isMessageRead = message['read'] ?? false;

                    return GestureDetector(
                      onTap: () {
                        // Marquer le message comme lu
                        _markMessageAsRead(message.id);
                      },
                      child: ListTile(
                        title: Align(
                          alignment: isCurrentUserSender
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: isCurrentUserSender
                                  ? Colors.blue
                                  : isMessageRead
                                  ? Colors.grey[300]
                                  : Colors.yellow[100],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!isCurrentUserSender)
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.blue,
                                    ),
                                    child: Center(
                                      child: Text(
                                        message['creatorUserId'][0].toUpperCase(),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                SizedBox(width: 8.0),
                                Flexible(
                                  child: Text(
                                    message['message'],
                                    style: TextStyle(
                                      color: isCurrentUserSender
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Entrez votre message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ticketiong/pages/Admin_Dashboard.dart';
import 'package:ticketiong/pages/Apprenant_Dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ticketiong/pages/Formateur_Dashbord.dart';


class ConnexionPage extends StatefulWidget {
  @override
  _ConnexionPageState createState() => _ConnexionPageState();
}

class _ConnexionPageState extends State<ConnexionPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Text(
              'Hi, Bienvenue!',
              style: TextStyle(
                fontSize: 40.0,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 100)),
            Row(
              children: [
                Icon(Icons.email, color: Colors.grey),
                SizedBox(width: 8.0),
                Text('Email'),
              ],
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                hintText: 'Entrer votre email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Icon(Icons.lock, color: Colors.grey),
                SizedBox(width: 8.0),
                Text('Mot de passe'),
              ],
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: _passwordController,
              obscureText: _isObscured,
              decoration: InputDecoration(
                hintText: 'Entrer votre mot de passe',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Padding(padding: EdgeInsets.only(top: 30)),
            ElevatedButton(
              style: const ButtonStyle(
                  padding: MaterialStatePropertyAll(EdgeInsets.all(20)),
                  backgroundColor: MaterialStatePropertyAll(Colors.blueAccent)
              ),
              onPressed: _handleLogin,
              child: Text('Connexion'),
            ),
            SizedBox(height: 40.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Ou'),
                SizedBox(width: 8.0),
                GestureDetector(
                  onTap: () {
                    // Logique pour la connexion avec Google
                  },
                  child: Text(
                    'Connexion avec Google',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            GestureDetector(
              onTap: () {
                // Logique pour le mot de passe oublié
              },
              child: Text(
                'Mot de passe oublié',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      // Connexion de l'utilisateur avec Firebase
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Récupérer le rôle de l'utilisateur dans Firestore
      String userId = userCredential.user?.uid ?? '';
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        String role = userDoc.get('role');
        if (role == 'Apprenant') {
          // Rediriger l'utilisateur vers le Dashbord_apprenant
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ApprenaantDashboard()),
          );
        } else if ((role == 'Formateur')){
          // Rediriger l'utilisateur vers un autre dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => FormateurDashbord()),
          );
        } else {
          // Rediriger l'utilisateur vers un autre dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminDashboard()),
          );
        }

      } else {
        // Gestion du cas où l'utilisateur n'existe pas dans Firestore
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Erreur lors de la récupération des informations utilisateur.'),
          ),
        );
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        // Gestion des erreurs Firebase spécifiques
        print('Erreur de connexion Firebase: ${e.code}');
        String errorMessage = 'Une erreur est survenue lors de la connexion. Veuillez réessayer.';
        switch (e.code) {
          case 'invalid-email':
            errorMessage = 'L\'adresse email est invalide.';
            break;
          case 'wrong-password':
            errorMessage = 'Le mot de passe est incorrect.';
            break;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
          ),
        );
      } else {
        // Gestion des autres types d'erreurs
        print('Erreur de connexion: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Une erreur est survenue lors de la connexion. Merci de réessayer.'),
          ),
        );
      }
    }
  }
}
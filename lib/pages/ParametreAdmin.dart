import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ticketiong/pages/Admin_Dashboard.dart';
import 'package:ticketiong/pages/PageAjoutUtilisateurs.dart';
import 'package:ticketiong/pages/PageInfoUtilisateurs.dart';
import 'package:ticketiong/pages/TermesUtilisationPage.dart';
import 'package:ticketiong/pages/connexion.dart';



class SettingsPageAdmin extends StatefulWidget {
  @override
  _SettingsPageAdminState createState() => _SettingsPageAdminState();
}

class _SettingsPageAdminState extends State<SettingsPageAdmin> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 140.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white,),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AdminDashboard(),
              ),
            );
          },
        ),
        backgroundColor: Colors.blue,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/image/samake.png'),
              radius: 50.0,
            ),
            SizedBox(width: 20.0),
            Text('Boakry SAMAKA'),
          ],
        ),

      ),

      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.person, color: Colors.blue,),
              title: Text('Mon Compte'),
              onTap: () {
                // Naviguer vers la page du compte utilisateur
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserInfoPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person_2_outlined, color: Colors.blue,),
              title: Text('Utilisateurs'),
              onTap: () {
                // Naviguer vers la page des termes d'utilisation
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AjouterUtilisateurPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications, color: Colors.blue,),
              title: Text('Notifications'),
              onTap: () {
                // Naviguer vers la page des notifications
                Navigator.pushNamed(context, '/notifications');
              },
            ),
            ListTile(
              leading: Icon(Icons.description, color: Colors.blue,),
              title: Text('Termes d\'utilisation'),
              onTap: () {
                // Naviguer vers la page des termes d'utilisation
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TermesUtilisationPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.blue,),
              title: Text('Déconnexion'),
              onTap: () {
                // Déconnecter l'utilisateur de l'application
                _logout();
              },
            ),
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Mode Sombre'),
                  Switch(
                    value: _isDarkMode,
                    onChanged: (value) {
                      setState(() {
                        _isDarkMode = value;
                      });
                      _updateTheme();
                    },
                  ),
                ],
              ),
              leading: Icon(Icons.brightness_4, color: Colors.blue,),
            ),
          ],
        ),
      ),
    );
  }

  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ConnexionPage(),
        ),
      );
      print('Déconnexion réussie');
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la déconnexion. Veuillez réessayer.'),
        ),
      );
    }
  }



  void _updateTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });

    // Mettre à jour le thème de l'application
    _applyTheme();
  }

  void _applyTheme() {
    if (_isDarkMode) {
      // Définir le thème sombre
      ThemeData darkTheme = ThemeData.dark();
      // Appliquer le thème sombre à l'application
      _updateAppTheme(darkTheme);
    } else {
      // Définir le thème clair
      ThemeData lightTheme = ThemeData.light();
      // Appliquer le thème clair à l'application
      _updateAppTheme(lightTheme);
    }
  }

  void _updateAppTheme(ThemeData newTheme) {
    // Mettre à jour le thème de l'application ici
    // Par exemple, en utilisant la méthode `Theme.of(context).copyWith()`
    Theme.of(context).copyWith(
      brightness: newTheme.brightness,
      primaryColor: newTheme.primaryColor,
      // Autres propriétés du thème à mettre à jour
    );
  }
}
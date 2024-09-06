import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ticketiong/pages/AfficherTermeUtilisation.dart';
import 'package:ticketiong/pages/Formateur_Dashbord.dart';
import 'package:ticketiong/pages/PageInfoUtilisateurs.dart';
import 'package:ticketiong/pages/connexion.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool darkmode = false;

  @override
  void initState() {
    super.initState();
    getCurrentTheme();
  }

  Future getCurrentTheme() async {
    final themeMode = await AdaptiveTheme.getThemeMode();
    setState(() {
      darkmode = themeMode == AdaptiveThemeMode.dark;
    });
  }

  void toggleTheme(bool value) {
    setState(() {
      darkmode = value;
      if (darkmode) {
        AdaptiveTheme.of(context).setDark();
      } else {
        AdaptiveTheme.of(context).setLight();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 140.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => FormateurDashbord(),
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
              leading: Icon(Icons.person, color: Colors.blue),
              title: Text('Mon Compte'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserInfoPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications, color: Colors.blue),
              title: Text('Notifications'),
              onTap: () {
                Navigator.pushNamed(context, '/notifications');
              },
            ),
            ListTile(
              leading: Icon(Icons.description, color: Colors.blue),
              title: Text('Termes d\'utilisation'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VisualiserTermesPage(),
                  ),
                );

              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.blue),
              title: Text('Déconnexion'),
              onTap: () {
                _logout();
              },
            ),
            SwitchListTile(
              title: Text('Mode sombre'),
              activeColor: Colors.orange,
              secondary: Icon(darkmode ? Icons.dark_mode : Icons.light_mode),
              value: darkmode,
              onChanged: toggleTheme,
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
}

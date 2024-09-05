import 'package:flutter/material.dart';
import 'connexion.dart';



class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Coaching",
              style: TextStyle(
                  fontSize: 60,
                  fontFamily: 'Poppins',
                  color: Colors.white
              ),
            ),
            const Text("Ticketing est une application qui permet aux apprenants de soumettre des tickets pour obtenir de l'aide ou résoudre des problèmes liés à leur formation, avec une gestion centralisée des réponses par les formateurs.",
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.white
              ),
              textAlign: TextAlign.center,),
            Padding(padding: EdgeInsets.only(top: 50)),
            ElevatedButton.icon(
              style: const ButtonStyle(
                  padding: MaterialStatePropertyAll(EdgeInsets.all(20)),
                  backgroundColor: MaterialStatePropertyAll(Colors.blueAccent)
              ),
              onPressed: (){
                Navigator.push(
                    context,
                    PageRouteBuilder(pageBuilder: (_, __, ___) => ConnexionPage())

                );

              },
              label: const Text("Suivant",
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white
                ),
              ),
              icon: Icon(Icons.skip_next, color: Colors.white),

            )
          ],
        ),

      ),

    );
  }
}

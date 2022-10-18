import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  const About({super.key});
  static const String repoUrl = "github.com/naytzap/gipfelbuch";

  Future<void> _launchUrl() async {
    if (!await launchUrl(Uri.parse("https://$repoUrl"),mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $repoUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:  <Widget>[
            const Card(
                child: ListTile(
                  leading: Icon(Icons.people),
                  title: Text("Authors"),
                  subtitle: Text("Inspired by Stevie\nCoded by Jonas"),
                )
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.code),
                title: const Text("Source"),
                subtitle: const Text("$repoUrl\nLicense: GNU General Public License v3.0"),
                onTap: _launchUrl,
              )
            ),
            const Expanded(
              child: Center(
              child: Text("Du, Berg, bist gut. Auf deinen Matten ruht\nDas Auge gern und gern auf deinem Wald;\nDu bist nicht hoch und stattlich von Gestalt,\nDoch macht dein sanfter Reiz dem Träumer Mut.\nDie Sonne liegt auf deiner breiten Brust\nDen langen Tag; du gibst sie uns zurück;\nUnd über deinem gütevollen Glück\nEntlässt das Herz die letzte böse Lust.\n(Christian Morgenstern)",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontStyle: FontStyle.italic, height: 1.4, fontSize: 16)
                    ),
            ),
            ),
            const Image(image: AssetImage('assets/11_Langkofel_group_Dolomites_Italy.jpg')),
          ],
        ),
      ),
    );
  }
}
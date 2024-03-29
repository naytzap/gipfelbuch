import 'package:flutter/material.dart';

class NavDrawer extends StatelessWidget {

  static const msgNotImplemented = SnackBar(
    content: Text('Feature not implemented :/'),
  );
  final Function parentFunc;
  const NavDrawer({super.key, required this.parentFunc});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
                color: Colors.lightGreen,
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('assets/11_Langkofel_group_Dolomites_Italy.jpg'))),
            child: Container(/*Text(
                  'Menu',
                  style: TextStyle(color: Colors.white, fontSize: 35, backgroundColor: Colors.black12),*/
                ), //AssetImage('assets/11_Langkofel_group_Dolomites_Italy.jpg'))),
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Statistics'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/stats');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () async {
              Navigator.of(context).pop();
              //ScaffoldMessenger.of(context).showSnackBar(msgNotImplemented);
              var refresh = await Navigator.pushNamed(context, '/settings');
              if(refresh != null && refresh==true) {
                parentFunc();
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              //Navigator.of(context).pop();
              Navigator.pop(context);
              Navigator.pushNamed(context, '/about');
            },
          ),
        ],
      ),
    );
  }
}

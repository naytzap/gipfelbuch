import 'package:flutter/material.dart';

class NavDrawer extends StatelessWidget {
  static const msgNotImplemented = SnackBar(
    content: Text('Feature not implemented :/'),
  );

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Container(/*Text(
                  'Menu',
                  style: TextStyle(color: Colors.white, fontSize: 35, backgroundColor: Colors.black12),*/
                ),
            decoration: BoxDecoration(
                color: Colors.lightGreen,
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('assets/11_Langkofel_group_Dolomites_Italy.jpg'))), //AssetImage('assets/11_Langkofel_group_Dolomites_Italy.jpg'))),
          ),
          ListTile(
            leading: Icon(Icons.bar_chart),
            title: Text('Statistics'),
            onTap: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(msgNotImplemented);
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(msgNotImplemented);
              Navigator.pushNamed(context, '/map');
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
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

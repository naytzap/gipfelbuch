import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:testapp/models/mountain_activity.dart';
import 'package:testapp/screens/settings.dart';
import 'package:testapp/widgets/activity_search_delegate.dart';
import 'screens/add_activity.dart';
import 'screens/about.dart';
import 'screens/osmmap.dart';
import 'widgets/activity_list.dart';
import 'widgets/bottom_navbar.dart';
import 'widgets/navdrawer.dart';
import 'package:intl/intl.dart';

void main() =>  runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gipfelbuch',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      //home: const MyHomePage(title: 'GipfelBuch'),
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(title: 'Gipfelbuch',),
        '/settings': (context) => const Settings(),
        '/about': (context) => const About(),
        '/map': (context) =>  OsmMap(),
        '/add': (context) => AddActivityForm(null)
      },
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('en', 'GB'),
        Locale('de', 'DE'),
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //int _counter = 0;
  int currentIndex = 0;

  final screens = [
    ActivityList(),
    OsmMap(),
  ];

  refresh(int index) {
    setState(() {
      debugPrint("Changed main index: $index");
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                  context: context,
                  delegate: ActivitySearchDelegate()
              );
            },
            icon: const Icon(Icons.search),
          )
        ],
      ),
      drawer: const NavDrawer(),
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavBar(notifyParent: refresh,),
      );
  }
}
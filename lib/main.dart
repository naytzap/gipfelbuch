import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gipfelbuch/screens/fmap.dart';
import 'package:gipfelbuch/screens/settings.dart';
import 'package:gipfelbuch/screens/statistics.dart';
import 'package:gipfelbuch/widgets/activity_search_delegate.dart';
import 'package:gipfelbuch/widgets/search_widget.dart';
import 'screens/add_activity.dart';
import 'screens/about.dart';
//import 'screens/osmmap.dart';
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
        '/stats': (context) => const Statistics(),
        '/map': (context) =>  FMap(),
        '/add': (context) => AddActivityForm()
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
  bool searchActive = false;
  String query = "";
  int currentIndex = 0;
  var screens = [
    ActivityList(query: "",),
    FMap(),
  ];

  changeScreen(int index) {
    setState(() {
      if(currentIndex!=index) {
        debugPrint("Changed main index: $index");
        currentIndex = index;
      }
    });
  }

  refresh() {
    setState((){
      screens=[ActivityList(query: query),FMap()];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: searchActive ? SearchWidget(text: query, onChanged: searchActivities ,onClosed: setSearch, hintText: "Activity or Person Name") : Text(widget.title),
        actions: [
         searchActive ? Container() : IconButton(onPressed: (){setState(() {
            searchActive = !searchActive;
          });}, icon: const Icon(Icons.search))
        ],
      ),
      drawer: NavDrawer(parentFunc: refresh,),
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavBar(notifyParent: changeScreen,),
      );
  }

  void setSearch(bool newState) {
    setState(() {
      searchActive = newState;
    });
  }

  void searchActivities(String query) {
    /*final activities = allActivities.where((act) {
      final nameLower = act.name.toLowerCase();
      final participantsLower = act.participants.toLowerCase();
      final searchLower = query.toLowerCase();

      return nameLower.contains(searchLower) ||
          participantsLower.contains(searchLower);
    }).toList();*/

    setState(() {
      this.query = query;
      //this.activities = activities;
    });
    refresh();
  }
}
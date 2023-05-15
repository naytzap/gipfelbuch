import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gipfelbuch/screens/fmap.dart';
import 'package:gipfelbuch/screens/settings.dart';
import 'package:gipfelbuch/screens/statistics.dart';
import 'package:gipfelbuch/widgets/activity_search_delegate.dart';
import 'package:gipfelbuch/widgets/search_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme)
    {
      final _defaultLightColorScheme =
      ColorScheme.fromSwatch(primarySwatch: Colors.green);

      final _defaultDarkColorScheme = ColorScheme.fromSwatch(
          primarySwatch: Colors.green, brightness: Brightness.dark);

      return FutureBuilder(future: getThemeSettings(), builder: (context, snapshot) {
        if(!snapshot.hasData) {
          return Container();
        }
        else {
          return MaterialApp(
            title: 'Gipfelbuch',
            theme: ThemeData(
              colorScheme: lightColorScheme ?? _defaultLightColorScheme,
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: darkColorScheme ?? _defaultDarkColorScheme,
              useMaterial3: true,
            ),
            themeMode: snapshot.data == "system" ? ThemeMode.system : (snapshot.data == "dark" ? ThemeMode.dark : ThemeMode.light),
            initialRoute: '/',
            routes: {
              '/': (context) => const MyHomePage(title: 'Gipfelbuch',),
              '/settings': (context) => const Settings(),
              '/about': (context) => const About(),
              '/stats': (context) => const Statistics(),
              '/map': (context) => FMap(),
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
      });

    });
  }

  getThemeSettings() async {
    String defaultValue = "light";
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("theme") ?? defaultValue;
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
        actions:searchActive ? null : [
           IconButton(onPressed: (){setState(() {
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
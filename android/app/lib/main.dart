import 'package:flutter/material.dart';
import 'models/MountainActivity.dart';
import 'screens/AddActivity.dart';
import 'screens/about.dart';
import 'screens/osmmap.dart';
import 'widgets/ActivityList.dart';
import 'widgets/bottomnavbar.dart';
import 'widgets/navdrawer.dart';

void main() =>  runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      //home: const MyHomePage(title: 'GipfelBuch'),
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(title: 'GipfelBuch',),
        '/about': (context) => About(),
        '/map': (context) => OsmMap()
      },
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

  List<MountainActivity> db = [ MountainActivity("Säuling", "Stefan, Jonas", DateTime(2021,9,30), 19.65, 6.25, 2047),
                                MountainActivity("Schellschlicht", "Stefan, Franzi, Jonas", DateTime(2020,9,30), 13.8, 6, 2049),
                                MountainActivity("Schneibstein", "Stefan, Franzi,  Jonas", DateTime(2020,6,1), 19.78, 6.2, 2276),
                                MountainActivity("Kammerlingshorn", "Stefan, Franzi, Jonas", DateTime(2019,9,30), 9, 6.5, 999),
                                MountainActivity("Arber", "Jonas, Franzi", DateTime(2018,8,8), 11, 5.5, 999),
                                MountainActivity("Lusen", "Jonas", DateTime(2020,7,15), 11, 5.5, 999)
                                ];

  @override
  Widget build(BuildContext context) {
    BottomNavBar bnb = BottomNavBar();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      drawer: NavDrawer(),
      bottomNavigationBar: bnb,
      body: ActivityList(db),
      floatingActionButton: FloatingActionButton(
        onPressed: () {debugPrint('Tapped add activity');
          Navigator.push(context,MaterialPageRoute(builder: (context) => AddActivityForm()));},
        tooltip: 'Add Activity',
        child: const Icon(Icons.add),
      ),
    );
  }
}
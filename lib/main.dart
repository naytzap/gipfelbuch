import 'package:flutter/material.dart';
import 'screens/AddActivity.dart';
import 'screens/about.dart';
import 'screens/osmmap.dart';
import 'widgets/ActivityList.dart';
import 'widgets/bottomnavbar.dart';
import 'widgets/navdrawer.dart';

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
        '/about': (context) => const About(),
        '/map': (context) => const OsmMap(),
        '/add': (context) => const AddActivityForm()
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
  int currentIndex = 0;

  final screens = [
    const ActivityList(),
    const OsmMap()
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
      ),
      drawer: const NavDrawer(),
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavBar(notifyParent: refresh,),
      floatingActionButton: currentIndex==0? FloatingActionButton(
        onPressed: () async {
          debugPrint('Tapped add activity');
          //Navigator.push(context,MaterialPageRoute(builder: (context) => const AddActivityForm())).then((_) => setState(() {}));
          await Navigator.pushNamed(context, '/add').then((_) => setState(() {}));
        },
        tooltip: 'Add Activity',
        child: const Icon(Icons.add),
      ):null,
    );
  }
}
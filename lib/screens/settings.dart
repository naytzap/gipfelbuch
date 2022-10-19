import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:testapp/database_helper.dart';
import 'package:testapp/models/Activities.dart';
import 'package:testapp/models/MountainActivity.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  void loadDb(BuildContext context) {
    debugPrint("adding default values");
    List<MountainActivity> list = Activities.fetchAll();
    for (MountainActivity a in list){
      DatabaseHelper.instance.addActivity(a);
    }
    Navigator.pop(context);
  }

  void clearDb(BuildContext context) async {
    debugPrint("clearing database");
    List<MountainActivity> list = await DatabaseHelper.instance.getAllActivities();
    for (MountainActivity a in list){
      DatabaseHelper.instance.delete(a.id??9999999);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              InkWell(
                  onTap: (){loadDb(context);},
                  child: Container(
                    alignment: Alignment.center,
                    color: Colors.cyan,
                    height: 50,
                    child: Text(
                      "Load initial database",
                      style: TextStyle(fontSize: 20),
                    ),
                  )),
              SizedBox(height:20),
              InkWell(
                  onTap: (){clearDb(context);},
                  child: Container(
                    alignment: Alignment.center,
                    color: Colors.red,
                    height: 50,
                    child: Text(
                      "Clear entire database",
                      style: TextStyle(fontSize: 20),
                    ),
                  ))
            ],
          ),
        )));
  }
}

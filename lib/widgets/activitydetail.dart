import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database_helper.dart';
import '../models/MountainActivity.dart';
import 'qrwidget.dart';

class ActivityDetail extends StatelessWidget{
  final MountainActivity activity;
  const ActivityDetail(this.activity, {super.key});


  showDeleteDialog(BuildContext context) {

    // set up the buttons
    Widget deleteButton = TextButton(
      child: const Text("Delete", style: TextStyle(color: Colors.red)),
      onPressed:  () {
        // TODO: remove image as well, if there is any
        DatabaseHelper.instance.delete(activity.id!);
        var count = 0;
        Navigator.popUntil(context, (route) {
          return count++ == 2;
        });
        },
    );
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed:  () {Navigator.of(context).pop();},
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Delete Activity"),
      content: const Text("Are you sure? This can't be undone!"),
      actions: [
        deleteButton,
        cancelButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(activity.mountainName),
          actions: <Widget>[
            InkWell(
              child:const Icon(Icons.map),
              onTap: () {
                debugPrint("Show on map not implemented");
              },
            ),
            Container(width: 20,),
            InkWell(
                child:const Icon(Icons.qr_code),
                onTap: () {
                  var data = json.encode(activity.toMap());
                  debugPrint(data);
                  Navigator.push(context,MaterialPageRoute(builder: (context) => QrWidget(data)));
                  },
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch(value){
                  case 'Edit':
                    debugPrint("Pressed Edit");
                    editActivity(context);
                    break;
                  case 'Delete':
                    showDeleteDialog(context);
                    break;
                }
              },
              itemBuilder: (BuildContext context) {
                return {'Edit', 'Delete'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
        ),
        body: ListView(
          children: [
            const Image(image: AssetImage('assets/11_Langkofel_group_Dolomites_Italy.jpg')),
            Container(height: 5),
            ListTile(
                leading: const Icon(Icons.date_range),
                title: const Text("Date of visit"),
                subtitle: Text(DateFormat('dd.MM.yyyy').format(activity.date)),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text("Visitors"),
              subtitle: Text(activity.participants??""),
            ),
            ListTile(
              leading: const Icon(Icons.arrow_forward),
              title: const Text("Distance"),
              subtitle: Text("${activity.distance} km"),
            ),
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text("Duration"),
              subtitle: Text("${activity.duration} h"),
            ),
            ListTile(
              leading: const Icon(Icons.upgrade_outlined),
              title: const Text("Vertical"),
              subtitle: Text("${activity.climb} hm"),
            ),
            ListTile(
              leading: const Icon(Icons.place_rounded),
              title: const Text("Position"),
              subtitle: Text("Lat: ${activity.location?.latitude}\nLon: ${activity.location?.longitude}"),
            )
          ],
        )
    );
  }


  void handleClick(value) {
    switch (value) {
      case 'Delete':
        debugPrint('clicked delete...');
        showDeleteDialog;
        break;
      case 'Edit':
        break;
    }
  }

  editActivity(BuildContext context) {
    debugPrint("editing: $activity");
    Navigator.pushNamed(context, "/add",arguments: activity);
  }
}
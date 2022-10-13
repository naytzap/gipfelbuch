import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database_helper.dart';
import '../models/MountainActivity.dart';
import 'qrwidget.dart';

class ActivityDetail extends StatelessWidget{
  final MountainActivity activity;
  ActivityDetail(this.activity);


  showDeleteDialog(BuildContext context) {

    // set up the buttons
    Widget deleteButton = TextButton(
      child: Text("Delete"),
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
      child: Text("Cancel"),
      onPressed:  () {Navigator.of(context).pop();},
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete Activity"),
      content: Text("Are you sure? This can't be undone!"),
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
              child:Icon(Icons.map),
              onTap: () {
                debugPrint("Show on map not implemented");
              },
            ),
            Container(width: 10,),
            InkWell(
                child:Icon(Icons.qr_code),
                onTap: () {
                  var data = json.encode(activity.toMap());
                  debugPrint(data);
                  Navigator.push(context,MaterialPageRoute(builder: (context) => QrWidget(data)));
                  },
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch(value){
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
            Image(image: AssetImage('assets/11_Langkofel_group_Dolomites_Italy.jpg')),
            Container(height: 10),
            ListTile(
                leading: Icon(Icons.date_range),
                title: Text("Date of visit"),
                subtitle: Text(DateFormat('dd.MM.yyyy').format(activity.date)),
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text("Visitors"),
              subtitle: Text(activity.participants??""),
            ),
            ListTile(
              leading: Icon(Icons.arrow_forward),
              title: Text("Distance"),
              subtitle: Text(activity.distance.toString() + " km"),
            ),
            ListTile(
              leading: Icon(Icons.timer),
              title: Text("Duration"),
              subtitle: Text(activity.duration.toString() + " h"),
            ),
            ListTile(
              leading: Icon(Icons.keyboard_arrow_up_outlined),
              title: Text("Vertical"),
              subtitle: Text(activity.climb.toString() + " hm"),
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
}
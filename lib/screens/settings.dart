import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:testapp/database_helper.dart';
import 'package:testapp/models/activities.dart';
import 'package:testapp/models/mountain_activity.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  void loadDb(BuildContext context) {
    debugPrint("adding default values");
    List<MountainActivity> list = Activities.fetchAll();
    for (MountainActivity a in list) {
      DatabaseHelper.instance.addActivity(a);
    }
    Navigator.pop(context);
  }

  void clearDb(BuildContext context) async {
    debugPrint("clearing database");
    List<MountainActivity> list = await DatabaseHelper.instance
        .getAllActivities();
    for (MountainActivity a in list) {
      DatabaseHelper.instance.delete(a.id ?? 9999999);
    }
    Navigator.pop(context);
  }

  Future<void> writeFile(String data, String name) async {
    // storage permission ask
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    // the downloads folder path
    //Directory tempDir = await DownloadsPathProvider.downloadsDirectory;
    //String tempPath = tempDir.path;
    var filePath = '/storage/emulated/0/Download/' + '/$name';
    //
    File(filePath).writeAsString(data);
    // the data
    //var bytes = ByteData.view(data.buffer);
    //final buffer = bytes.buffer;
    // save the data in the path
    //return File(filePath).writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }


  Future<void> importDb(BuildContext context) async {
    debugPrint("importing from file... not implemented");
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path ?? "");
      List<dynamic> data = json.decode(await file.readAsString());
      print(data);
      data.forEach((element){
        try {
          MountainActivity me = MountainActivity.fromMap(element);
          DatabaseHelper.instance.addActivity(me);
          print("Added new activity: " + me.mountainName);
        } catch (e) {
          print(e);
        }
      });

    } else {
      // User canceled the picker
    }
    Navigator.pop(context);
  }


  Future<void> exportDb(BuildContext context) async {
    debugPrint("export db to file...");
    var list = await DatabaseHelper.instance.getAllActivities();
    var data = json.encode(list.map((e) => e.toMap()).toList());
    writeFile(data.toString(), 'GB_export.json');
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
                        onTap: () {
                          loadDb(context);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          color: Colors.cyan,
                          height: 50,
                          child: const Text(
                            "Load initial database",
                            style: TextStyle(fontSize: 20),
                          ),
                        )),
                    const SizedBox(height: 20),
                    InkWell(
                        onTap: () {
                          clearDb(context);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          color: Colors.red,
                          height: 50,
                          child: const Text(
                            "Clear entire database",
                            style: TextStyle(fontSize: 20),
                          ),
                        )),
                    const SizedBox(height: 20),
                    InkWell(
                        onTap: () {
                          exportDb(context);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          color: Colors.deepPurple,
                          height: 50,
                          child: const Text(
                            "Export database",
                            style: TextStyle(fontSize: 20),
                          ),
                        )),
                    const SizedBox(height: 20),
                    InkWell(
                        onTap: () {
                          importDb(context);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          color: Colors.lightGreen,
                          height: 50,
                          child: const Text(
                            "Import database2",
                            style: TextStyle(fontSize: 20),
                          ),
                        ))
                  ],
                ))));
  }
}
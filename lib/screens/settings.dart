import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gipfelbuch/database_helper.dart';
import 'package:gipfelbuch/models/activities.dart';
import 'package:gipfelbuch/models/mountain_activity.dart';
import 'package:collection/collection.dart'; //firstwhereornull

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Column devFunctions() {
    return Column(children: [
      const SizedBox(height: 20),
      InkWell(
          onTap: () {
            clearCachedImgs(context);
          },
          child: Container(
            alignment: Alignment.center,
            color: Colors.red,
            height: 50,
            child: const Text(
              "Delete cached images",
              style: TextStyle(fontSize: 20),
            ),
          )),
      const SizedBox(height: 20),
      InkWell(
          onTap: () {
            clearThumbs(context);
          },
          child: Container(
            alignment: Alignment.center,
            color: Colors.orange,
            height: 50,
            child: const Text(
              "Delete cached thumbnails",
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
              "Delete database",
              style: TextStyle(fontSize: 20),
            ),
          )),
      const SizedBox(height: 20),
    ]);
  }

  Future<void> loadDemoDb(BuildContext context) async {
    var list = await DatabaseHelper.instance.getAllActivities();
    if (list.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text("Demo can only be loaded if there are no activities!")));
    } else {
      debugPrint("adding default values");
      List<MountainActivity> list = Activities.fetchAll();
      for (MountainActivity a in list) {
        DatabaseHelper.instance.addActivity(a);
      }
    }
    Navigator.pop(context, true);
  }

  void clearDb(BuildContext context) async {
    debugPrint("clearing database");
    Widget deleteButton = TextButton(
      child: const Text("Delete", style: TextStyle(color: Colors.red)),
      onPressed: () async {
        //Navigator.pop(context);
        List<MountainActivity> list =
            await DatabaseHelper.instance.getAllActivities();
        for (MountainActivity a in list) {
          DatabaseHelper.instance.delete(a.id!);
        }
        var count = 0;
        Navigator.popUntil(context, (route) {
          return count++ == 2;
        });
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Delete database?"),
      content: const Text(
          "Are you sure? This can't be undone!\n(maybe do a export first!)"),
      actions: [
        deleteButton,
        TextButton(
            child: const Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );

    //
  }

  void clearThumbs(BuildContext context) async {
    final directory = await getApplicationDocumentsDirectory();
    var counter = 0;
    for (var i = 0; i < 1000; i++) {
      File image = File('${directory.path}/activity_${i}_thumbnail');
      if (await image.exists()) {
        debugPrint("Deleted ${image.path}");
        image.delete();
        counter++;
      }
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Deleted $counter thumbnails")));
  }

  void clearCachedImgs(BuildContext context) {
    Widget deleteButton = TextButton(
      child: const Text("Delete", style: TextStyle(color: Colors.red)),
      onPressed: () async {
        clearThumbs(context);
        final directory = await getApplicationDocumentsDirectory();
        //try to delete 5000 ids (bad practice...)
        var counter = 0;
        for (var i = 0; i < 1000; i++) {
          File image = File('${directory.path}/activity_$i');
          if (await image.exists()) {
            debugPrint("Deleted ${image.path}");
            image.delete();
            counter++;
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Deleted $counter cached images")));
        var count = 0;
        Navigator.popUntil(context, (route) {
          return count++ == 2;
        });
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Delete cached images?"),
      content: const Text(
          "Are you sure? This can't be undone!\n(won't delete images of your gallery :) )"),
      actions: [
        deleteButton,
        TextButton(
            child: const Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop();
            }),
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

  Future<void> writeFile(String data, String filePath) async {
    // storage permission ask
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    File(filePath).writeAsString(data);
  }

  Future<void> importDb(BuildContext context) async {
    debugPrint("importing from file... not implemented");
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      File file = File(result.files.single.path ?? "");
      List<dynamic> data = json.decode(await file.readAsString());
      var existingActivities = await DatabaseHelper.instance.getAllActivities();
      //debugPrint(data);
      var imports = 0;
      for (var element in data) {
        MountainActivity impAct = MountainActivity.fromMap(element);
        MountainActivity? match = existingActivities.firstWhereOrNull((e) =>
            (e.mountainName == impAct.mountainName || e.date == impAct.date));
        if (match == null) {
          var id = await DatabaseHelper.instance.addActivity(MountainActivity(
              id: null,
              mountainName: impAct.mountainName,
              participants: impAct.participants,
              date: impAct.date,
              distance: impAct.distance,
              duration: impAct.duration,
              climb: impAct.climb,
              location: impAct.location));
          debugPrint("Added new activity: ${impAct.mountainName} (id: $id)");
          imports++;
        } else {
          /*
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    duration: const Duration(milliseconds: 750),
                    content: Text("Skipped ${impAct.mountainName} (${impAct.date} already exists!)")));*/
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Imported $imports/${data.length} activities.")));
    } else {
      // User canceled the picker
    }
    Navigator.pop(context, true);
  }

  Future<void> exportDb(BuildContext context) async {
    debugPrint("export db to file...");
    var list = await DatabaseHelper.instance.getAllActivities();
    if (list.isNotEmpty) {
      var data = json.encode(list.map((e) => e.toMap()).toList());
      var now = DateTime.now();
      var formatter = DateFormat('yyMMddHHmm');
      String formattedDate = formatter.format(now);
      var filePath =
          "/storage/emulated/0/Download/GipfelBuchDBexp_$formattedDate.json";
      writeFile(data.toString(), filePath);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(seconds: 7),
          content: Text("Exported ${list.length} activities to $filePath")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("DB empty, nothing to export!")));
    }
    Navigator.pop(context, false);
  }

  bool enableDevFuncs = false;

  //TextEditingController _controller = TextEditingController();
  //_controller.text =

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
                  children: [
                    const SizedBox(height: 20),
                    InkWell(
                        onTap: () {
                          loadDemoDb(context);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          color: Colors.cyan,
                          height: 50,
                          child: const Text(
                            "Load demo database",
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
                          color: Colors.teal,
                          height: 50,
                          child: const Text(
                            "Export data to JSON",
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
                            "Import data from JSON",
                            style: TextStyle(fontSize: 20),
                          ),
                        )),
                    const SizedBox(height: 20),
                    themeSelectorWidget(),
                    const SizedBox(height: 20,),
                    FutureBuilder(
                        future: getGpxTolerance(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Container();
                          } else {
                            var controller = TextEditingController();
                            TextField tf = TextField(
                                controller: controller,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  icon: Icon(Icons.satellite),
                                    hintText: "1...100 [m]",
                                    labelText: "GPX tolerance [m]",
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(15))),
                                onChanged: (val) async {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  prefs.setInt("gpxTolerance", int.parse(val));
                                });
                            var gpxTolerance = snapshot.data;
                            controller.text = snapshot.data.toString();
                            //return ListTile(leading: Icon(Icons.satellite), title: Text("GPX Track tolerance"), subtitle: Text("1...100 [m]"),trailing: tf);
                            return tf;
                            //TODO: ListTile with ontap dropdown menu
                            //return ListTile(title: Text("GPX Track Visualization"),subtitle: Text("$gpxTolerance m tolerance"),,);
                          }
                        }),
                    Row(children: [
                      Text("Enable developer options "),
                      Switch(
                        value: enableDevFuncs,
                        onChanged: (bool value) {
                          setState(() {
                            enableDevFuncs = value;
                          });
                        },
                      )
                    ]),
                    enableDevFuncs ? devFunctions() : Container(),
                  ],
                ))));
  }

  getGpxTolerance() async {
    int defaultValue = 25;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt("gpxTolerance") ?? defaultValue;
  }

  getThemeSettings() async {
    String defaultValue = "light";
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("theme") ?? defaultValue;
  }


  themeSelectorWidget() =>
    FutureBuilder(future: getThemeSettings(), builder: (context, snapshot) {
      if(!snapshot.hasData) {
        return Container();
      }
      else {

        var btn = DropdownButton<String>(
            value: snapshot.data!.toString(),
            isDense: true,
            //icon: const Icon(Icons.arrow_downward),
            onChanged: (String? value) {
              // This is called when the user selects an item.
              setState(() async {
                SharedPreferences prefs =
                await SharedPreferences.getInstance();
                prefs.setString("theme", value!);
              });
            },
            items: [DropdownMenuItem(value: "light", child: Text("light")),DropdownMenuItem(value: "dark", child: Text("dark")),DropdownMenuItem(value: "system", child: Text("system")),]
        );
        //return Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text("App Theme"),Spacer() ,btn],);
        return ListTile(leading: Icon(Icons.color_lens), title: Row(children: [Text("App Theme"), Spacer(), btn ]), subtitle: Text("will change after app restart"),);
      }

    });

}

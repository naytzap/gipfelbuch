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
      ListTile(
        leading: const Icon(Icons.landscape),
        onTap: () {
          loadDemoDb(context);
        },
        title: const Text(
          "Load demo database",
        ),
      ),
      ListTile(
          onTap: () {
            clearCachedImgs(context);
          },
          title: const Text(
              "Delete all activity images",
            ),
        leading: const Icon(Icons.image_not_supported),
          ),
      ListTile(
          onTap: () {
            clearThumbs(context);
          },
          title: const Text(
              "Delete cached thumbnails",
            ),
        leading: const Icon(Icons.image_not_supported_outlined),
          ),
      ListTile(
          onTap: () {
            clearDb(context);
          },
          title: const Text(
              "Delete database",
            ),
        leading: const Icon(Icons.delete_forever),
          ),
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
    var sectionTextStyle = const TextStyle(fontSize: 12, fontWeight: FontWeight.bold);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("General Appearance".toUpperCase(),style: sectionTextStyle,),
                    themeSelectorWidget(),
                    gpxToleranceSetting(),
                    gpxBadgeWidget(),
                    const Divider(),
                    Text("Data Import/Export".toUpperCase(),style: sectionTextStyle,),
                    ListTile(
                      leading: const Icon(Icons.file_download),
                      onTap: () {
                        importDb(context);
                      },
                      title: const Text(
                        "Import activities from JSON",
                      ),
                      subtitle: const Text("Reads JSON file from device and imports activities"),
                    ),
                    ListTile(
                      leading: const Icon(Icons.upload_file),
                      onTap: () {
                        exportDb(context);
                      },
                      title: const Text(
                        "Export activities to JSON",
                      ),
                      subtitle: const Text(
                          "Creates a JSON file in download directory that contains activity data"),
                    ),
                    const Divider(),
                    Text("Developer Options".toUpperCase(),style: sectionTextStyle,),
                    Container(color: enableDevFuncs ? Colors.red.withOpacity(0.2) : null, child:Wrap(children: [
                    SwitchListTile(
                      title: const Text("Enable Developer Options"),
                      subtitle: const Text("Be careful what you are doing!"),
                      value: enableDevFuncs,
                      onChanged: (bool value) {
                        setState(() {
                          enableDevFuncs = value;
                        });
                      },
                      secondary: const Icon(Icons.code),
                    ),
                    enableDevFuncs ? devFunctions() : Container(),
                      ]))
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

  themeSelectorWidget() {
    return FutureBuilder(
        future: getThemeSettings(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          String currentValue = snapshot.data!.toString();
          return PopupMenuButton<String>(
            initialValue: currentValue,
            onSelected: (String value) async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString("theme", value);
              debugPrint("Theme brightness set to: $value");
              setState(() {});
            },
            child: ListTile(
              leading: const Icon(Icons.color_lens),
              title: Text("App Theme ($currentValue)"),
              subtitle: const Text(
                  "Changes after App restart"),
            ),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem(
                  value: "light", child: Text("Light theme")),
              const PopupMenuItem(value: "dark", child: Text("Dark theme")),
              const PopupMenuItem(value: "system", child: Text("Use device theme")),
            ],
          );
        });
  }

  gpxToleranceSetting() {
    return FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          var currentValue = snapshot.data!.getInt("gpxTolerance") ?? 25;
          return PopupMenuButton<int>(
            initialValue: currentValue,
            onSelected: (int value) async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setInt("gpxTolerance", value);
              debugPrint("GPX Tolerance set to: $value");
              setState(() {});
            },
            child: ListTile(
              leading: const Icon(Icons.straighten),
              title: currentValue>0?Text("GPX track detail (${currentValue}m)"):const Text("GPX track detail (tracks hidden)"),
              subtitle: const Text(
                  "If map view encounters performance issues, reduce details of gpx tracks"),
            ),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
              const PopupMenuItem(
                  value: 0, child: Text("Hide GPX tracks")),
              const PopupMenuItem(value: 1, child: Text("Very High Detail (1m)")),
              const PopupMenuItem(value: 5, child: Text("High Detail (5m)")),
              const PopupMenuItem(
                  value: 15, child: Text("Medium Detail (15m)")),
              const PopupMenuItem(
                  value: 25, child: Text("Default Detail (25m)")),
              const PopupMenuItem(value: 50, child: Text("Low Detail (50m)")),
              const PopupMenuItem(
                  value: 100, child: Text("Very Low Detail (100m)")),
            ],
          );
        });
  }

  gpxBadgeWidget() {

    return FutureBuilder(future: SharedPreferences.getInstance(),builder: (context, snapshot) {
      if(!snapshot.hasData) {
        return Container();
      }
      var showGpxIndicator = snapshot.data!.getBool("gpxIndicator")??false;
      return SwitchListTile(
        title: const Text("GPX indicator"),
        subtitle: const Text(
            "Show an indicator if activity is associated with a GPX track"),
        value: showGpxIndicator,
        onChanged: (value) async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool("gpxIndicator", value);
          setState(() {});
        },
        secondary: const Icon(Icons.satellite),
      );
    });
  }
}

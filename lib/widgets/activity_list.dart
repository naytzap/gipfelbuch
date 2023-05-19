import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database_helper.dart';
import '../models/mountain_activity.dart';
import 'activity_detail.dart';

class ActivityList extends StatefulWidget {
  static const double imagePadding = 0;
  String query = "";
  ActivityList({this.query="Osser",super.key,});

  @override
  State<ActivityList> createState() => _ActivityListState();
}

class _ActivityListState extends State<ActivityList> {
  //final List<MountainActivity> db = Activities.fetchAll();
  static const double _height = 115;
  //late int thumbnailDetail = 20;
  late SharedPreferences prefs;

  reloadList() {
    //this hast to be a stateful widget
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    sharedData();
  }

  void sharedData() async {
    prefs = await SharedPreferences.getInstance(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder<List<MountainActivity>>(
            future: DatabaseHelper.instance.getAllActivities(),
            builder: (BuildContext context,
                AsyncSnapshot<List<MountainActivity>> snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: Text("Loading..."));
              }
              if (snapshot.data!.isEmpty) {
                return const Center(
                    child: Text(
                  "No activities.\n Add an adventure! :)",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 22),
                ));
              }
              List<MountainActivity> allActivities = snapshot.data!;
              List<MountainActivity>? activities = searchActivities(widget.query, allActivities);
              return ListView.separated(
                  cacheExtent: 4000,
                  separatorBuilder: (BuildContext context, int index) =>
                      Container(height: 5),
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    return Card(
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                            onTap: () {
                              debugPrint('Tapped activity $index');
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ActivityDetail(
                                          activities.elementAt(index).id!))).then((_) => setState(() {}));
                            },
                            child: SizedBox(
                                width: 250,
                                height: _height,
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 190,
                                              child: Text(activities
                                          .elementAt(index)
                                          .mountainName,
                                                overflow: TextOverflow.fade,
                                                maxLines: 1,
                                                softWrap: false,
                                                style: const TextStyle(
                                                    fontSize: 20)),),
                                            Wrap(children:[Text(DateFormat('dd.MM.yyyy')
                                                .format(activities
                                                    .elementAt(index)
                                                    .date)),gpxIndicator(activities.elementAt(index).id!)]),
                                            Expanded(child: Container()),
                                            getInfoFooter(activities.elementAt(index).distance,activities.elementAt(index).duration,activities.elementAt(index).climb)

                                          ]),
                                    ),
                                    Expanded(child: Container()),
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Padding(
                                              padding: const EdgeInsets.all(0),
                                              child: FutureBuilder(
                                                  future: loadImage(activities.elementAt(index).id!),
                                                    builder: (context, snapshot2) {
                                                    if(!snapshot2.hasData) {
                                                      //debugPrint("NO IMAGE DATA FOR: ${snapshot.data!.elementAt(index).mountainName}");
                                                      return const Image(
                                                          height: _height,
                                                          image: AssetImage(
                                                              'assets/Langkofel_bw.jpg'));
                                                    } else {
                                                      //return SizedBox(height: _height, width: 154, child:  Image.file(snapshot2.data!,fit: BoxFit.fitHeight, alignment : Alignment.center, ));
                                                      return  Container(constraints: const BoxConstraints(maxWidth: 154), child: Image.file(snapshot2.data!,fit: BoxFit.fitHeight, alignment : Alignment.center, height: _height, ));
                                                    }
                                                  }
                                                  ),
                                                  )
                                        ])
                                  ],
                                ))));
                  });
            }),
        floatingActionButton: FloatingActionButton(
            onPressed: () async {
              debugPrint('Tapped add activity');
              //Navigator.push(context,MaterialPageRoute(builder: (context) => const AddActivityForm())).then((_) => setState(() {}));
              await Navigator.pushNamed(context, '/add',arguments: null).then((_) => setState(() {}));
            },
            tooltip: 'Add Activity',
            child: const Icon(Icons.add),

        ),
    );
  }

  /*
  Future<File?> loadImage(int activityId) async{
    final directory = await getApplicationDocumentsDirectory();
    File image = File('${directory.path}/activity_$activityId');
    return await image.exists() ? image : null;
  }
   */

  Future<File?> loadImage(int activityId) async {
    final directory = await getApplicationDocumentsDirectory();
    File thumbnail = File('${directory.path}/activity_${activityId}_thumbnail');
    if(!await thumbnail.exists()) {
      File image = File('${directory.path}/activity_$activityId');
      if(image.existsSync()){
        //we have a image but no thumbnail yet...
        //debugPrint("Found image without thumb id: $activityId");
        var thumbnailDetail = prefs.getInt("thumbnailDetail")??20;
        var newThumb =  await FlutterNativeImage.compressImage(image.path,quality: thumbnailDetail);
        //ImageProperties props = await FlutterNativeImage.getImageProperties(image.path);
        debugPrint("created a new thumb for $activityId with quality $thumbnailDetail %");
        newThumb.copy("${image.path}_thumbnail");
        return await newThumb.exists() ? newThumb : null;
      } else {
        //we did not find no image
        //debugPrint("no image found id: $activityId");
        return null;
      }
    }
    return await thumbnail.exists() ? thumbnail : null;
  }

  Text getInfoFooter(double? distance, double? duration, int? climb) {
    String txt = "";
    if(distance!=null) {
      txt += "$distance km";
      if(duration != null || climb !=null) {
        txt += " | ";
      }
    }
    if(duration!=null) {
      txt += "$duration h";
      if(climb !=null) {
        txt += " | ";
      }
    }
    if(climb != null) {
      txt += "$climb vm";
    }
    return Text(txt);
  }

  List<MountainActivity> searchActivities(String query,List<MountainActivity> allActivities) {
    final activities = allActivities.where((act) {
      final nameLower = act.mountainName.toLowerCase();
      //final participantsLower = act.participants?.toLowerCase();
      final searchLower = query.toLowerCase();

      bool foundParticipant = false;
      if(act.participants != null && act.participants!.isNotEmpty) {
        foundParticipant = act.participants!.toLowerCase().contains(searchLower);
      }

      return nameLower.contains(searchLower) || foundParticipant;
    }).toList();

    return activities;
  }

  gpxIndicator(int id) {
    checkIfFileExists(id) async {
      //TODO: move this to initialization, this only has to be done once!
      var prefs = await SharedPreferences.getInstance();
      var showIndicator = prefs.getBool("gpxIndicator")??false;
      if(!showIndicator) {
        return false;
      }
      final directory = await getApplicationDocumentsDirectory();
      File? savedFile = File("${directory.path}/track_$id.gpx");
      return savedFile.existsSync();
    }

    return FutureBuilder(future: checkIfFileExists(id),builder: (context, snapshot){
      if (!snapshot.hasData || !snapshot.data!) {
        return Container();
      } else {
        return const Padding(padding: EdgeInsets.only(left: 5),child:Icon(Icons.satellite,size: 20));
      }
    });
  }





}

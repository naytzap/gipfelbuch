import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../database_helper.dart';
import '../models/mountain_activity.dart';
import 'activity_detail.dart';

class ActivityList extends StatefulWidget {
  static const double imagePadding = 0;
  ActivityList({super.key,});

  @override
  State<ActivityList> createState() => _ActivityListState();
}

class _ActivityListState extends State<ActivityList> {
  //final List<MountainActivity> db = Activities.fetchAll();
  static const double _height = 115;

  reloadList() {
    //this hast to be a stateful widget
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
              return ListView.separated(
                  cacheExtent: 4000,
                  separatorBuilder: (BuildContext context, int index) =>
                      Container(height: 5),
                  itemCount: snapshot.data!.length,
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
                                          snapshot.data!.elementAt(index).id!))).then((_) => setState(() {}));
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
                                              child: Text(snapshot.data!
                                          .elementAt(index)
                                          .mountainName,
                                                overflow: TextOverflow.fade,
                                                maxLines: 1,
                                                softWrap: false,
                                                style: const TextStyle(
                                                    fontSize: 20)),),
                                            Text(DateFormat('dd.MM.yyyy')
                                                .format(snapshot.data!
                                                    .elementAt(index)
                                                    .date)),
                                            Expanded(child: Container()),
                                            getInfoFooter(snapshot.data?.elementAt(index).distance,snapshot.data!.elementAt(index).duration,snapshot.data!.elementAt(index).climb)

                                          ]),
                                    ),
                                    Expanded(child: Container()),
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Padding(
                                              padding: const EdgeInsets.all(
                                                  ActivityList.imagePadding),
                                              child: FutureBuilder(
                                                  future: loadImage(snapshot.data!.elementAt(index).id!),
                                                    builder: (context, snapshot2) {
                                                    if(!snapshot2.hasData) {
                                                      //debugPrint("NO IMAGE DATA FOR: ${snapshot.data!.elementAt(index).mountainName}");
                                                      return const Image(
                                                          height: _height,
                                                          image: AssetImage(
                                                              'assets/11_Langkofel_group_Dolomites_Italy.jpg'));
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
    if(!await thumbnail.exists()) {;
      File image = File('${directory.path}/activity_$activityId');
      if(image.existsSync()){
        //we have a image but no thumbnail yet...
        //debugPrint("Found image without thumb id: $activityId");
        var newThumb =  await FlutterNativeImage.compressImage(image.path,quality: 30);
        //ImageProperties props = await FlutterNativeImage.getImageProperties(image.path);
        debugPrint("created a new thumb for $activityId");
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



}

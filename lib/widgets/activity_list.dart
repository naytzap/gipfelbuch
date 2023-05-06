import 'package:flutter/material.dart';
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
                                            Text(snapshot.data!
                                          .elementAt(index)
                                          .mountainName.length < 18 ?
                                                snapshot.data!
                                                    .elementAt(index)
                                                    .mountainName : snapshot.data!
                                                .elementAt(index)
                                                .mountainName.substring(0,18)+"...",
                                                style: const TextStyle(
                                                    fontSize: 20)),
                                            Text(DateFormat('dd.MM.yyyy')
                                                .format(snapshot.data!
                                                    .elementAt(index)
                                                    .date)),
                                            Expanded(child: Container()),
                                            Text(
                                                "${snapshot.data?.elementAt(index).distance.toString() ?? "-"} km | ${snapshot.data!.elementAt(index).duration.toString()} h | ${snapshot.data!.elementAt(index).climb.toString()} vm")
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
                                                    builder: (context, snapshot) {
                                                    if(!snapshot.hasData) {
                                                      return const Image(
                                                          height: _height,
                                                          image: AssetImage(
                                                              'assets/11_Langkofel_group_Dolomites_Italy.jpg'));
                                                    }else {
                                                      //return  DecorationImage(fit: BoxFit.f, image: FileImage(snapshot.data!));
                                                      return SizedBox(height: _height, width: 154, child:  Image.file(snapshot.data!,fit: BoxFit.fill ));
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

  Future<File?> loadImage(int activityId) async{
    final directory = await getApplicationDocumentsDirectory();
    File image = File('${directory.path}/activity_$activityId');
    return await image.exists() ? image : null;
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database_helper.dart';
import '../models/Activities.dart';
import '../models/MountainActivity.dart';
import 'activitydetail.dart';

class ActivityList extends StatelessWidget {
  //final List<MountainActivity> db = Activities.fetchAll();
  final double _height = 115;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MountainActivity>>(
        future: DatabaseHelper.instance.getAllActivities(),
        builder: (BuildContext context,
            AsyncSnapshot<List<MountainActivity>> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: Text("Loading..."));
          }
          if (snapshot.data!.isEmpty) {
            return Center(
                child: Text("No activities.\n Go on an adventure! :)"));
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
                                      snapshot.data!.elementAt(index))));
                        },
                        child: SizedBox(
                            width: 250,
                            height: _height,
                            child: Expanded(
                                child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            snapshot.data!
                                                .elementAt(index)
                                                .mountainName,
                                            style: TextStyle(fontSize: 20)),
                                        Text(DateFormat('dd.MM.yyyy').format(
                                            snapshot.data!
                                                .elementAt(index)
                                                .date)),
                                        Expanded(child: Container()),
                                        Text(
                                            "${snapshot.data!.elementAt(index).distance.toString()} km | ${snapshot.data!.elementAt(index).duration.toString()} h | ${snapshot.data!.elementAt(index).climb.toString()} vm")
                                      ]),
                                ),
                                Expanded(child: Container()),
                                Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                          child: Image(
                                              height: _height,
                                              image: AssetImage(
                                                  'assets/11_Langkofel_group_Dolomites_Italy.jpg')))
                                    ])
                              ],
                            )))));
              });
        });
  }
}

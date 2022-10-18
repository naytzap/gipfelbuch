import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database_helper.dart';
import '../models/MountainActivity.dart';
import 'activitydetail.dart';

class ActivityList extends StatelessWidget {
  //final List<MountainActivity> db = Activities.fetchAll();
  //Todo: Add possibility to search list
  final double _height = 115;
  static const double imagePadding = 0;
  const ActivityList({super.key});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MountainActivity>>(
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
                                      snapshot.data!.elementAt(index))));
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
                                        Text(
                                            snapshot.data!
                                                .elementAt(index)
                                                .mountainName,
                                            style:
                                                const TextStyle(fontSize: 20)),
                                        Text(DateFormat('dd.MM.yyyy').format(
                                            snapshot.data!
                                                .elementAt(index)
                                                .date)),
                                        Expanded(child: Container()),
                                        Text(
                                            "${snapshot.data?.elementAt(index).distance.toString()??"-"} km | ${snapshot.data!.elementAt(index).duration.toString()} h | ${snapshot.data!.elementAt(index).climb.toString()} vm")
                                      ]),
                                ),
                                Expanded(child: Container()),
                                Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Padding(
                                padding: const EdgeInsets.all(imagePadding),
                                    child:
                                      Image(
                                          height: _height-2*imagePadding,
                                          image: const AssetImage(
                                              'assets/11_Langkofel_group_Dolomites_Italy.jpg'))
                                      )])
                              ],
                            ))));
              });
        });
  }
}

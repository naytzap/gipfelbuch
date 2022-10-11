import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/MountainActivity.dart';
import 'activitydetail.dart';

class ActivityList extends StatelessWidget {
  final List<MountainActivity> db;
  ActivityList(this.db);
  final double _height = 115;
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        separatorBuilder: (BuildContext context, int index) => Container(height: 5),
        itemCount: db.length,
        itemBuilder: (context, index) {
          /*return Card(
              child: ListTile(
                  onTap: (){},
                  title: Text(titles[index]),
                  subtitle: Text(subtitles[index]),
                  trailing: CircleAvatar(
                      backgroundImage: NetworkImage(
                          "https://images.unsplash.com/photo-1547721064-da6cfb341d50")),
                  )
          );*/
          return Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: (){
                debugPrint('Tapped activity $index');
                Navigator.push(context,MaterialPageRoute(builder: (context) => ActivityDetail(db[index])));
                },
            child: SizedBox(
              width: 300,
              height: _height,
              child: Expanded(
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(db[index].mountainName, style: TextStyle(fontSize: 22)),
                          Text(DateFormat('dd.MM.yyyy').format(db[index].dateTime)),
                          Expanded(child: Container()),
                          Text("${db[index].distance.toString()} km | ${db[index].duration.toString()} h | ${db[index].verticalAscend.toString()} vm")
                        ]
                    ),
                    Expanded(child: Container()),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                              child:Image(
                                height: _height,
                                  image: AssetImage('assets/11_Langkofel_group_Dolomites_Italy.jpg')
                              )
                          )
                        ]
                    )
                  ],
                )
              )
            )
            )
          );
        });
  }
}


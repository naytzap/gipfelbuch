import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:testapp/database_helper.dart';
import 'package:testapp/models/mountain_activity.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/activity_detail.dart';

class Statistics extends StatelessWidget {
  const Statistics({super.key});



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: Container(
        alignment: Alignment.center,
        child: FutureBuilder<List<MountainActivity>>(
            future: DatabaseHelper.instance.getAllActivities(),
            builder: (BuildContext context, AsyncSnapshot<List<MountainActivity>> snapshot) {
              List<Widget> myChildren = [];
              if (!snapshot.hasData) {
                myChildren.add( const Center(child: Text("Crunching data for you...")));
              }
              else if (snapshot.data!.isEmpty) {
                myChildren.add( const Center(child: Text("Oh wow, such empty!\nLet's go on an adventure first :)",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontStyle: FontStyle.italic, height: 1.4, fontSize: 18))));
              }
              else {
                var _totalActivities = snapshot.data!.length;
                var _furthestAct = snapshot.data!.reduce((current, next) => (current.distance??0) > (next.distance??0) ? current : next);
                var _longestAct = snapshot.data!.reduce((current, next) => (current.duration??0) > (next.duration??0) ? current : next);
                var _highestAct = snapshot.data!.reduce((current, next) => (current.climb??0) > (next.climb??0) ? current : next);

                var _earliestAct = snapshot.data!.reduce((current, next) => current.date.isBefore(next.date) ? current : next);
                var _latestAct = snapshot.data!.reduce((current, next) => current.date.isAfter(next.date) ? current : next);

                var formatter = DateFormat('dd.MM.yyyy');
                String _earliestDate = formatter.format(_earliestAct.date);
                String _latestDate = formatter.format(_latestAct.date);

                double _totalDistance = snapshot.data!.fold(0,(double sum,elem) => sum + (elem.distance??0.0));
                double _totalTime = snapshot.data!.fold(0,(double sum,elem) => sum + (elem.duration??0.0));
                double _totalClimb = snapshot.data!.fold(0,(double sum,elem) => sum + (elem.climb??0.0));

                myChildren.add( Card(
                      child: ListTile(
                        leading: Icon(Icons.numbers_rounded),
                        title: Text("Number of activities"),
                        subtitle: Text("$_totalActivities"),
                      )
                  ));
                myChildren.add( Card(
                      child: ListTile(
                        onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => ActivityDetail(_furthestAct.id!))); },
                        leading: Icon(Icons.nordic_walking_rounded),
                        title: Text("Furthest Walk"),
                        subtitle: Text("${_furthestAct.distance} km (${_furthestAct.mountainName})"),
                      )
                  ));
                myChildren.add(Card(
                      child: ListTile(
                        onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => ActivityDetail(_longestAct.id!))); },
                        leading: Icon(Icons.timer_rounded),
                        title: Text("Longest Walk"),
                        subtitle: Text("${_longestAct.duration} h (${_longestAct.mountainName})"),
                      )
                ));
                myChildren.add(Card(
                      child: ListTile(
                        onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => ActivityDetail(_highestAct.id!))); },
                        leading: Icon(Icons.arrow_upward_rounded),
                        title: Text("Highest ascend"),
                        subtitle: Text("${_highestAct.climb} m (${_highestAct.mountainName})"),
                      )
                  ));
                myChildren.add(Card(
                      child: ListTile(
                        leading: Icon(Icons.functions_rounded),
                        title: Text("Totals"),
                        subtitle: Text("You've walked ${_totalDistance.ceil()} km in ${_totalTime.ceil()} hours and climbed ${_totalClimb.ceil()} m (from $_earliestDate until $_latestDate)"),
                      )
                  ));
                myChildren.add(const Expanded(
                    child: Center(
                      child: Text("Keep on walking!",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontStyle: FontStyle.italic, height: 1.4, fontSize: 16)
                      ),
                    ),
                  ));
                myChildren.add(const Image(image: AssetImage('assets/11_Langkofel_group_Dolomites_Italy.jpg')));
              }

              return  Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: myChildren
              );
            }

        )

      ),
    );
  }
}
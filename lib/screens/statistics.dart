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
                var totalActivities = snapshot.data!.length;
                var furthestAct = snapshot.data!.reduce((current, next) => (current.distance??0) > (next.distance??0) ? current : next);
                var longestAct = snapshot.data!.reduce((current, next) => (current.duration??0) > (next.duration??0) ? current : next);
                var highestAct = snapshot.data!.reduce((current, next) => (current.climb??0) > (next.climb??0) ? current : next);

                var earliestAct = snapshot.data!.reduce((current, next) => current.date.isBefore(next.date) ? current : next);
                var latestAct = snapshot.data!.reduce((current, next) => current.date.isAfter(next.date) ? current : next);

                var formatter = DateFormat('dd.MM.yy');
                var numFormatter = NumberFormat("###,###,###,###","de");
                String earliestDate = formatter.format(earliestAct.date);
                String latestDate = formatter.format(latestAct.date);

                double totalDistance = snapshot.data!.fold(0,(double sum,elem) => sum + (elem.distance??0.0));
                double totalTime = snapshot.data!.fold(0,(double sum,elem) => sum + (elem.duration??0.0));
                double totalClimb = snapshot.data!.fold(0,(double sum,elem) => sum + (elem.climb??0.0));

                myChildren.add( Card(
                      child: ListTile(
                        leading: Icon(Icons.numbers_rounded),
                        title: Text("Number of activities"),
                        subtitle: Text("$totalActivities"),
                      )
                  ));
                myChildren.add( Card(
                      child: ListTile(
                        onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => ActivityDetail(furthestAct.id!))); },
                        leading: const Icon(Icons.nordic_walking_rounded),
                        title: const Text("Furthest Walk"),
                        subtitle: Text("${furthestAct.distance} km (${furthestAct.mountainName})"),
                      )
                  ));
                myChildren.add(Card(
                      child: ListTile(
                        onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => ActivityDetail(longestAct.id!))); },
                        leading: const Icon(Icons.timer_rounded),
                        title: const Text("Longest Walk"),
                        subtitle: Text("${longestAct.duration} h (${longestAct.mountainName})"),
                      )
                ));
                myChildren.add(Card(
                      child: ListTile(
                        onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => ActivityDetail(highestAct.id!))); },
                        leading: const Icon(Icons.arrow_upward_rounded),
                        title: const Text("Highest ascend"),
                        subtitle: Text("${highestAct.climb} m (${highestAct.mountainName})"),
                      )
                  ));
                myChildren.add(Card(
                      child: ListTile(
                        leading: const Icon(Icons.functions_rounded),
                        title: const Text("Totals"),
                        subtitle: Text("You walked ${numFormatter.format(totalDistance.ceil())} km in ${numFormatter.format(totalTime.ceil())} hours and climbed ${numFormatter.format(totalClimb.ceil())} meters of altitude between $earliestDate and $latestDate"),
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
                //myChildren.add(const Image(image: AssetImage('assets/11_Langkofel_group_Dolomites_Italy.jpg')));
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
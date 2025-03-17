import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gipfelbuch/database_helper.dart';
import 'package:gipfelbuch/models/mountain_activity.dart';
import 'package:text_scroll/text_scroll.dart';

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
              builder: (BuildContext context,
                  AsyncSnapshot<List<MountainActivity>> snapshot) {
                List<Widget> myChildren = [];
                if (!snapshot.hasData) {
                  myChildren.add(
                      const Center(child: Text("Crunching data for you...")));
                } else if (snapshot.data!.isEmpty) {
                  myChildren.add(const Center(
                      child: Text(
                          "Oh wow, such empty!\nLet's go on an adventure first :)",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              height: 1.4,
                              fontSize: 18))));
                } else {
                  var numberActivities = snapshot.data!.length;
                  var furthestAct = snapshot.data!.reduce((current, next) =>
                      (current.distance ?? 0) > (next.distance ?? 0)
                          ? current
                          : next);
                  var longestAct = snapshot.data!.reduce((current, next) =>
                      (current.duration ?? 0) > (next.duration ?? 0)
                          ? current
                          : next);
                  var highestAct = snapshot.data!.reduce((current, next) =>
                      (current.climb ?? 0) > (next.climb ?? 0)
                          ? current
                          : next);

                  var earliestAct = snapshot.data!.reduce((current, next) =>
                      current.date.isBefore(next.date) ? current : next);
                  var latestAct = snapshot.data!.reduce((current, next) =>
                      current.date.isAfter(next.date) ? current : next);

                  var formatter = DateFormat('dd.MM.yy');
                  var numFormatter = NumberFormat("###,###,###,###", "de");
                  String earliestDate = formatter.format(earliestAct.date);
                  String latestDate = formatter.format(latestAct.date);

                  double totalDistance = snapshot.data!.fold(
                      0, (double sum, elem) => sum + (elem.distance ?? 0.0));
                  double totalTime = snapshot.data!.fold(
                      0, (double sum, elem) => sum + (elem.duration ?? 0.0));
                  double totalClimb = snapshot.data!
                      .fold(0, (double sum, elem) => sum + (elem.climb ?? 0.0));

                  String companions = snapshot.data!
                      .fold("", (c, elem) => "$c${elem.participants ?? " "},");
                  var occComp = occurence(companions);
                  var rankComp = rankCount(occComp);

                  myChildren.add(Card(
                      child: ListTile(
                    leading: Icon(Icons.numbers_rounded),
                    title: Text("Number Of Activities"),
                    subtitle: Text("$numberActivities"),
                  )));
                  myChildren.add(Card(
                      child: ListTile(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ActivityDetail(furthestAct.id!)));
                    },
                    leading: const Icon(Icons.nordic_walking_rounded),
                    title: const Text("Furthest Walk"),
                    subtitle: Text(
                        "${furthestAct.distance} km (${furthestAct.mountainName})"),
                  )));
                  myChildren.add(Card(
                      child: ListTile(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ActivityDetail(longestAct.id!)));
                    },
                    leading: const Icon(Icons.timer_rounded),
                    title: const Text("Longest Walk"),
                    subtitle: Text(
                        "${longestAct.duration} h (${longestAct.mountainName})"),
                  )));
                  myChildren.add(Card(
                      child: ListTile(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ActivityDetail(highestAct.id!)));
                    },
                    leading: const Icon(Icons.arrow_upward_rounded),
                    title: const Text("Highest Ascend"),
                    subtitle: Text(
                        "${highestAct.climb} m (${highestAct.mountainName})"),
                  )));
                  myChildren.add(Card(
                      child: ListTile(
                    leading: const Icon(Icons.functions_rounded),
                    title: const Text("Totals"),
                    subtitle: Text(
                        "You walked ${numFormatter.format(totalDistance.ceil())} km in ${numFormatter.format(totalTime.ceil())} hours and climbed ${numFormatter.format(totalClimb.ceil())} meters of altitude between $earliestDate and $latestDate"),
                  )));
                  myChildren.add(Card(
                      child: ListTile(
                          leading: const Icon(Icons.people_alt_rounded),
                          title: const Text("Frequent Companions"),
                          onTap: () {
                            showCompanions(occComp, context);
                          },
                          subtitle: Column(
                            children: buildLeaderboard(rankComp),
                          ))));
                  myChildren.add(const Expanded(
                    child: Center(
                      child: Text("Keep on walking!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              height: 1.4,
                              fontSize: 16)),
                    ),
                  ));
                  //myChildren.add(const Image(image: AssetImage('assets/11_Langkofel_group_Dolomites_Italy.jpg')));
                }

                return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: myChildren);
              })),
    );
  }

  Map<String, int> occurence(String text) {
    //List<String?> words = text.split(",").map((word) => word.isNotEmpty?word.trim():null ).toList();
    List<String> words = text
        .split(",")
        .where((s) => s.isNotEmpty)
        .map((w) => w.trim())
        .toList()
      ..sort();
    //words = words.removeWhere((element) => element==null);
    //var newWords =  words.map((l) => l.l.where((i) => i.isNotEmpty).toList()).toList();
    print(words); // [hello, hi, hello, one, two, two, three]

    Map<String, int> count = {};
    for (var word in words) {
      count.update(word, (value) => value + 1, ifAbsent: () => 1);
        }
    //rankCount(count);
    return count;
  }

  Map<int, String> rankCount(Map<String, int> count) {
    Map<int, String> rank = {};
    for (var c in count.entries) {
      rank.update(c.value, (value) => "$value,  ${c.key}",
          ifAbsent: () => c.key);
    }
    final sorted =
        SplayTreeMap<int, String>.from(rank, (a, b) => b.compareTo(a));
    return sorted;
  }

  buildLeaderboard(ranking) {
    var counts = ranking.keys;
    var values = ranking.values;
    List<Widget> l = [];
    var medals = ["🥇", "🥈", "🥉"];
    for (var i = 0; i < min(3, counts.length); i++) {
      l.add(Row(
        children: [
          Text(medals[i]),
          Text("${counts.elementAt(i)}x\t"),
          TextScroll(values.elementAt(i))
        ],
      ));
    }
    return l;
  }

  Future<void> showCompanions(Map<String, int> occComp, context) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('All Companions'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [for(var i=0;i<occComp.length;i++) Text("${occComp.keys.elementAt(i)} (${occComp.values.elementAt(i)}x)")],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

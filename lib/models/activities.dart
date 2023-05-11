import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

import './mountain_activity.dart';

class Activities {
  static final List<MountainActivity> _db = [
    MountainActivity(mountainName: "Mont Blanc",    participants:  "Sepp, Lisa, Paul",  date: DateTime(2021,9,30),distance: 35,duration: 18,climb: 4808,location: GeoPoint(latitude: 45.8327057,longitude: 6.8651706)),
    MountainActivity(mountainName: "Dufourspitze",  participants:  "Martin, Clara",     date: DateTime(2020,9,30),distance: 33,duration: 17,climb: 4634,location: GeoPoint(latitude: 45.9369096,longitude: 7.866751)),
    MountainActivity(mountainName: "Zumsteinspitze",participants:  "Anna, Sepp, Paul",  date: DateTime(2020,6, 1),distance: 31,duration: 16,climb: 4563,location: GeoPoint(latitude: 45.9321656,longitude: 7.8714077)),
    MountainActivity(mountainName: "Dom",           participants:  "Thorsten, Sepp",    date: DateTime(2019,9,30),distance: 29,duration: 15,climb: 4545,location: GeoPoint(latitude: 46.0939293,longitude: 7.8588713)),
    MountainActivity(mountainName: "Liskamm",       participants:  "Paul, Anna",        date: DateTime(2018,8, 8),distance: 27,duration: 14,climb: 4527,location: GeoPoint(latitude: 45.9232742,longitude: 7.8336489)),
    MountainActivity(mountainName: "Weisshorn",     participants:  "Lisa, Anna",        date: DateTime(2020,7,15),distance: 25,duration: 13,climb: 4505,location: GeoPoint(latitude: 46.101233, longitude: 7.7161432))
  ];

  static List<MountainActivity> fetchAll() {
    return _db;
  }



}
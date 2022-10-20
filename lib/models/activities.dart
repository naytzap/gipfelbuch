import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

import './mountain_activity.dart';

class Activities {
  static final List<MountainActivity> _db = [
    MountainActivity(mountainName: "Säuling",participants:  "Stefan, Jonas",date: DateTime(2021,9,30),distance:  19.65,duration: 6.25,climb:  2047,location: GeoPoint(latitude: 47.534722,longitude: 10.755)),
    MountainActivity(mountainName: "Schellschlicht",participants:  "Stefan, Franzi, Jonas",date:  DateTime(2020,9,30),distance:  13.8,duration: 6,climb:  2049,location: GeoPoint(latitude: 47.509722,longitude: 10.916667)),
    MountainActivity(mountainName: "Schneibstein",participants:  "Stefan, Franzi,  Jonas",date:  DateTime(2020,6,1),distance:  19.78,duration: 6.2,climb:  2276,location: GeoPoint(latitude: 47.562222,longitude: 13.057222)),
    MountainActivity(mountainName: "Kammerlinghorn",participants:  "Stefan, Franzi, Jonas",date:  DateTime(2019,9,30),distance:  9,duration: 6.5,climb:  999,location: GeoPoint(latitude: 47.5450497, longitude: 12.8327097)),
    MountainActivity(mountainName: "Arber",participants:  "Jonas, Franzi", date: DateTime(2018,8,8),distance:  11,duration: 5.5,climb:  999,location: GeoPoint(latitude: 49.1124718, longitude: 13.13619)),
    MountainActivity(mountainName: "Lusen",participants:  "Jonas",date:  DateTime(2020,7,15),distance:  11,duration: 5.5,climb:  999,location: GeoPoint(latitude: 48.9391964, longitude: 13.5067775))
  ];

  static List<MountainActivity> fetchAll() {
    return _db;
  }



}
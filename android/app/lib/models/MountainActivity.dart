import 'dart:core';

import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:intl/intl.dart';

class MountainActivity {
  final int? id;
  final String mountainName;
  final String? participants;
  final DateTime date;
  final double? distance; //tour distance in km
  final double? duration; //tour duration in hours
  final int? climb;       //vertical climb in meters
  final GeoPoint? location;
  /*
  Addition Information
  Image
  GPX-Track
   */

  const MountainActivity({
      this.id,
      required this.mountainName,
      this.participants,
      required this.date,
      this.distance,
      this.duration,
      this.climb,
      this.location});

  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'mountainName': mountainName,
      'participants': participants,
      'date': date
          .millisecondsSinceEpoch, //DateFormat("dd.MM.yyyy").format(dateTime),
      'distance': distance,
      'duration': duration,
      'climb': climb,
      'latitude': location?.latitude,
      'longitude': location?.longitude,
    };
  }

  factory MountainActivity.fromMap(Map<String, dynamic> m) {
    return MountainActivity(
        id: m['id'],
        mountainName: m['mountainName'],
        participants: m['participants'],
        date: DateTime.fromMillisecondsSinceEpoch(m['date']),
        distance: m['distance'],
        duration: m['duration'],
        climb: m['climb'],
        location: GeoPoint(latitude: m['latitude'], longitude: m['longitude']));
  }
}

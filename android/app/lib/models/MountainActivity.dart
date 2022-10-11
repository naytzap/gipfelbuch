import 'dart:core';

import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:intl/intl.dart';

class MountainActivity {
  final String mountainName;
  final String participants;
  final DateTime dateTime;
  final double distance;
  final double duration;
  final int verticalAscend;
  final GeoPoint location;
  /*
  Position
  Image
  GPX-Track
   */

  const MountainActivity(this.mountainName, this.participants, this.dateTime, this.distance, this.duration, this.verticalAscend,this.location);

  Map<String, dynamic> toMap() {
    return {
      'mountainName' : mountainName,
      'participants' : participants,
      'date' : DateFormat("dd.MM.yyyy").format(dateTime),
      'distance' : distance,
      'duration' : duration,
      'vAsc' : verticalAscend
    };
  }
}
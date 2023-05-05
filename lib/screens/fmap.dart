import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:testapp/models/mountain_activity.dart';

import '../database_helper.dart';
import '../widgets/activity_detail.dart';

class FMap extends StatefulWidget {
  LatLng? initPos;
  FMap({this.initPos, Key? key }) : super(key: key) {
    print("FMap(): $initPos, $key");
  }

  @override
  State<FMap> createState() => _FMapState();
}


class _FMapState extends State<FMap> {
  List<Marker> allMarkers = [];

  Marker createMountainMarker(MountainActivity act,context) {
    return Marker(
          point: LatLng(act.location!.latitude,act.location!.longitude),
          builder: (context) => GestureDetector(
              onTap: (){
                //ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tap1")));
                Navigator.push(context,MaterialPageRoute(
                    builder: (context) => ActivityDetail(act.id!))).then((_) => setState(() {}));
              },
              child: CircleAvatar(
                        backgroundColor: Colors.teal,
                        child: Text(act.mountainName.substring(0,3).toUpperCase(),style: TextStyle(fontSize: 10),),
                      )
                     )
              );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    print("FMAP: init ${widget.initPos}");
    return Scaffold(
      body:  Container(
              child: FlutterMap(
                options: MapOptions(
                  center: widget.initPos??LatLng(48, 12.5),
                  zoom: widget.initPos!=null ? 12 : 7,
                  maxZoom: 17,
                  minZoom: 5,
                  interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  ),
                  //MarkerLayer(markers: allMarkers),
                  FutureBuilder<List<MountainActivity>>(
                      future: DatabaseHelper.instance.getAllActivities(),
                      builder:  (BuildContext context, AsyncSnapshot<List<MountainActivity>> snapshot) {
                          List<Marker> myMarkers = [];
                          if (!snapshot.hasData) {
                            return const MarkerLayer(markers: []);
                          }
                          if (snapshot.data!.isEmpty) {
                            return const MarkerLayer(markers: []);
                          } else {
                            var nAct = snapshot.data!.length;
                            if(nAct > 0) {
                              for(var i=0; i<nAct; i++) {
                                MountainActivity act = snapshot.data!.elementAt(i);
                                if(act.location != null ) {
                                  myMarkers.add(createMountainMarker(act,context));
                                }
                              }
                            }
                            return MarkerLayer(markers: myMarkers);
                          }
                      },)
                ],
              ),
            ),
      );
  }
}
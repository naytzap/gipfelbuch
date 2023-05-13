import 'dart:math';
import 'dart:io';
import 'package:maps_toolkit/maps_toolkit.dart' as mt;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gpx/gpx.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    var pos = LatLng(act.location!.latitude,act.location!.longitude);
    bool marked = (widget.initPos!=null && widget.initPos==pos) ? true : false;
    return Marker(
          point: pos,
          builder: (context) => GestureDetector(
              onTap: (){
                //ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tap1")));
                Navigator.push(context,MaterialPageRoute(
                    builder: (context) => ActivityDetail(act.id!))).then((_) => setState(() {}));
              },
              child: CircleAvatar(
                        backgroundColor: marked ? Colors.orange.withOpacity(0.75) : Colors.teal.withOpacity(0.75),
                        child: Text(act.mountainName.substring(0,3).toUpperCase(),style: TextStyle(fontSize: 11, color: marked ? Colors.black : Colors.white),),
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
                  FutureBuilder<List<Polyline>>(
                    future: getPolylines(),
                    builder:  (BuildContext context, AsyncSnapshot<List<Polyline>> snapshot) {
                      //List<Marker> myMarkers = [];
                      if (!snapshot.hasData) {
                        return PolylineLayer(polylines: [],);
                      } else {
                        return PolylineLayer(polylines: snapshot.data!,);
                        //return PolylineLayer(polylines: [Polyline(color: Colors.red.withOpacity(0.8),strokeWidth: 5,points: snapshot!.data!)],);
                      }
                    }),
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
                    },),
                ],
              ),
            ),
      );
  }

  Future<List<Polyline>> getPolylines() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    debugPrint("Prefs");
    final int tolerance = prefs.getInt("gpxTolerance")??25;
    debugPrint("GPX tolerance set to $tolerance meters");
    var activities = await DatabaseHelper.instance.getAllActivities();
    final directory = await getApplicationDocumentsDirectory();

    List<Polyline> polyList = [];
    for (MountainActivity act in activities) {
      File gpxFile = File("${directory.path}/track_${act.id}.gpx");
      List<LatLng> points = [];
      if (gpxFile.existsSync()) {
        debugPrint("GPX File Exists (id: ${act.id})");
        var xmlGpx = GpxReader().fromString(gpxFile.readAsStringSync());
        var trackPoints = xmlGpx.trks[0].trksegs[0].trkpts;
        for (Wpt wpt in trackPoints) {
          points.add(LatLng(wpt.lat ?? 0, wpt.lon ?? 0));
        }
        /*var peakHeight = trackPoints.fold(
            0.0, (init, next) =>
        (init > (next.ele ?? 0)) ? init : next.ele ??
            0);

         */
        //asc = trackPoints.reduce((this,next)=>())
        //debugPrint("Found peak at $peakHeight m");
        //debugPrint(points.toString());
        int pointsBefore = points.length;
        List<mt.LatLng> cPoints = points.map((e)=>mt.LatLng(e.latitude,e.longitude)).toList();
        points = mt.PolygonUtil.simplify(cPoints, tolerance).map((e)=>LatLng(e.latitude, e.longitude)).toList();
        debugPrint("Reduced from $pointsBefore to ${points.length}");
        polyList.add(Polyline(color: Colors.teal.withOpacity(0.75),strokeWidth: 3, points: points));

      }
    }
      return polyList;
  }

  double calculateDistance(LatLng p1, LatLng p2){
    /*Returns distance in meters*/
    double lat1 = p1.latitude;
    double lon1 = p1.longitude;
    double lat2 = p2.latitude;
    double lon2 = p2.longitude;
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a)) * 1000;
  }

  double calculateTrackDistance(List<LatLng> data) {
    double totalDistance = 0;
    for(var i = 0; i < data.length-1; i++){
      totalDistance += calculateDistance(data[i], data[i+1]);
    }
    return totalDistance;
  }

}
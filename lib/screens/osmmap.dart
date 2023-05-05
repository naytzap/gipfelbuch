import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:testapp/database_helper.dart';
import 'package:testapp/models/mountain_activity.dart';

//import '../models/activities.dart';
//import '../models/mountain_activity.dart';

class OsmMap extends StatefulWidget {
  OsmMap({Key? key}) : super(key: key);

  @override
  _OsmMapState createState() => _OsmMapState();
}

class _OsmMapState extends State<OsmMap>  with OSMMixinObserver{
  //List<MountainActivity> db = Activities.fetchAll();
  MapController controller = MapController.customLayer(
    initMapWithUserPosition: false,
    initPosition: GeoPoint(
        latitude: 46.919393,
        longitude: 11.072966), //GeoPoint(latitude: 47.4358055, longitude: 8.4737324),
    //areaLimit: BoundingBox( east: 10.4922941, north: 47.8084648, south: 45.817995, west: 5.9559113,),
    customTile: CustomTile(
      sourceName: "opentopomap",
      tileExtension: ".png",
      minZoomLevel: 2,
      maxZoomLevel: 19,
      urlsServers: [
        TileURLs(
          url: "https://tile.opentopomap.org/",
          subdomains: [],
        )
      ],
      tileSize: 256,
    ),
  );

  @override
  void initState() {
    super.initState();
    //drawPositions();

  }

  /*void drawPositions() async{
    debugPrint("###########Draw locations");
    for (var activity in db) {
      await controller.addMarker(activity.location,
          markerIcon: MarkerIcon(
              iconWidget: SizedBox.fromSize(
                size: const Size.square(32),
                child: Stack(
                  children: [
                    const Icon(
                      Icons.circle,
                      color: Colors.red,
                      size: 32,
                    ),
                    Text(
                      activity.mountainName,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              )));
    }
  }
*/
  @override
  Widget build(BuildContext context) {
    final act = ModalRoute.of(context)?.settings.arguments;
    if (act!=null){
      MountainActivity activity = act as MountainActivity;
      FutureBuilder<void>(
        future: controller.setZoom(zoomLevel: 12),
        initialData: null,
        builder: (context, snapshot) {
          return Container();
        });
    }

    return Scaffold(
      //appBar: AppBar(title: Text("map"),),
      body: OSMFlutter(
        controller: controller,
        trackMyPosition: false,
        initZoom: 8,
        minZoomLevel: 5,
        maxZoomLevel: 16,
        stepZoom: 1.0,
        userLocationMarker: UserLocationMaker(
          personMarker: const MarkerIcon(
            icon: Icon(
              Icons.location_history_rounded,
              color: Colors.red,
              size: 48,
            ),
          ),
          directionArrowMarker: const MarkerIcon(
            icon: Icon(
              Icons.double_arrow,
              size: 48,
            ),
          ),
        ),
        roadConfiguration: RoadConfiguration(
          startIcon: const MarkerIcon(
            icon: Icon(
              Icons.person,
              size: 64,
              color: Colors.red,
            ),
          ),
          roadColor: Colors.yellowAccent,
        ),
        markerOption: MarkerOption(
            defaultMarker: const MarkerIcon(
          icon: Icon(
            Icons.person_pin_circle,
            color: Colors.blue,
            size: 56,
          ),
        )),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: (){
            //mapIsInitialized();
            print("map Button");
            drawMountains();
            debugPrint("map test");
          },tooltip: "test",
          child: const Icon(Icons.update_sharp)),
    );
  }

  @override
  Future<void> mapIsReady(bool isReady) async {
    if (isReady) {
      await mapIsInitialized();
      await drawMountains();
    }
  }

  Future<void> drawMountains() async {
    var activities = await DatabaseHelper.instance.getAllActivities();
    for (MountainActivity act in activities){
      debugPrint("drawing: ${act.location}");
      if(act.location!=null) {
        await controller.addMarker(
          act.location ?? GeoPoint(latitude: 47.442475, longitude: 8.4680389),
          markerIcon: MarkerIcon(
            icon: const Icon(
              Icons.place_rounded,
              color: Colors.lightGreen,
              size: 128,
            ),
            //iconWidget: Text(act.mountainName ?? "")
          ),
        );
      }

    }
  }

  Future<void> mapIsInitialized() async {
    await controller.setZoom(zoomLevel: 12);
    // await controller.setMarkerOfStaticPoint(
    //   id: "line 1",
    //   markerIcon: MarkerIcon(
    //     icon: Icon(
    //       Icons.train,
    //       color: Colors.red,
    //       size: 48,
    //     ),
    //   ),
    // );
    await controller.setMarkerOfStaticPoint(
      id: "line 2",
      markerIcon: const MarkerIcon(
        icon: Icon(
          Icons.train,
          color: Colors.orange,
          size: 60,
        ),
      ),
    );

    await controller.setStaticPosition(
      [
        GeoPointWithOrientation(
          latitude: 47.4433594,
          longitude: 8.4680184,
          angle: pi / 4,
        ),
        /*GeoPointWithOrientation(
          latitude: 47.4517782,
          longitude: 8.4716146,
          angle: pi / 2,
        ),*/
      ],
      "line 2",
    );
    final bounds = await controller.bounds;
    debugPrint(bounds.toString());
    await controller.addMarker(
      GeoPoint(latitude: 47.442475, longitude: 8.4680389),
      markerIcon: const MarkerIcon(
        icon: Icon(
          Icons.car_repair,
          color: Colors.red,
          size: 64,
        ),
      ),
    );
    final gps = await controller.geopoints;
    debugPrint(gps.first.toString());
  }
}

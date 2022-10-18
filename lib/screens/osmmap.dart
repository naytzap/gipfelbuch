import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

//import '../models/Activities.dart';
//import '../models/MountainActivity.dart';

class OsmMap extends StatefulWidget {
  const OsmMap({Key? key}) : super(key: key);

  @override
  _OsmMapState createState() => _OsmMapState();
}

class _OsmMapState extends State<OsmMap>  with OSMMixinObserver{
  //List<MountainActivity> db = Activities.fetchAll();
  MapController controller =MapController.customLayer(
    initMapWithUserPosition: false,
    initPosition: GeoPoint(
        latitude: 46.919393,
        longitude:
        11.072966), //GeoPoint(latitude: 47.4358055, longitude: 8.4737324),
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
    return Scaffold(
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
    );
  }

  @override
  Future<void> mapIsReady(bool isReady) async {
    if (isReady) {
      await mapIsInitialized();
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
          size: 36,
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
          color: Colors.black45,
          size: 32,
        ),
      ),
    );
    final gps = await controller.geopoints;
    debugPrint(gps.first.toString());
  }
}

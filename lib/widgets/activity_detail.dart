import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
//import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:gipfelbuch/widgets/pinch_zoom_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_scroll/text_scroll.dart';

import '../database_helper.dart';
import '../models/mountain_activity.dart';
import '../screens/fmap.dart';
import 'qrwidget.dart';

class ActivityDetail extends StatefulWidget {
  final int activityId;
  const ActivityDetail(this.activityId, {super.key});

  @override
  State<ActivityDetail> createState() => _ActivityDetailState();
}

class _ActivityDetailState extends State<ActivityDetail> {
  //File? image;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    sharedData();
  }

  void sharedData() async {
    prefs = await SharedPreferences.getInstance(); 
  }

  showDeleteDialog(BuildContext context) {
    // set up the buttons
    Widget deleteButton = TextButton(
      child: const Text("Delete", style: TextStyle(color: Colors.red)),
      onPressed: () {
        // TODO: remove image as well, if there is any
        DatabaseHelper.instance.delete(widget.activityId);
        var count = 0;
        Navigator.popUntil(context, (route) {
          return count++ == 2;
        });
      },
    );
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Delete Activity"),
      content: const Text("Are you sure? This can't be undone!"),
      actions: [
        deleteButton,
        cancelButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showDeleteGPXDialog(BuildContext context) {
    // set up the buttons
    Widget deleteButton = TextButton(
      child: const Text("Delete GPX", style: TextStyle(color: Colors.red)),
      onPressed: () async {
        final directory = await getApplicationDocumentsDirectory();
        File gpxFile = File("${directory.path}/track_${widget.activityId}.gpx");
        if (gpxFile.existsSync()) {
          gpxFile.delete();
        }
        Navigator.of(context).pop();
      },
    );
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Delete GPX"),
      content: const Text("Are you sure? This can't be undone!"),
      actions: [
        deleteButton,
        cancelButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.wait([
          DatabaseHelper.instance.getActivity(widget.activityId),
          loadImage(widget.activityId)
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator(); //Center(child: Text("Loading..."));
          }
          /*
          if (snapshot.data![0]?.id != widget.activityId) {
            return const Center(
                child: Text(
                  "Error.\nCould not load right activity :/",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 22),
                ));
          }*/
          MountainActivity activity = snapshot.data![0] as MountainActivity;
          File? image = snapshot.data![1] as File?;
          const TextStyle dfStyle = TextStyle(fontSize: 20);

          return Scaffold(
              appBar: AppBar(
                title: TextScroll(
                  activity.mountainName,
                  fadedBorder: true,
                  fadedBorderWidth: 0.05,
                  fadeBorderSide: FadeBorderSide.right,
                  numberOfReps: 3,
                  delayBefore: Duration(milliseconds: 1200),
                  pauseBetween: Duration(milliseconds: 800),
                  //velocity = const Velocity(pixelsPerSecond: Offset(80, 0)),
                ),
                actions: <Widget>[
                  InkWell(
                      child: const Icon(Icons.map),
                      onTap: () {
                        if (activity.location != null) {
                          var llPos = LatLng(activity.location!.latitude,
                              activity.location!.longitude);
                          debugPrint("Show map on $llPos");
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      FMap(initPos: llPos, key: UniqueKey())));
                        }
                      }),
                  Container(
                    width: 20,
                  ),
                  InkWell(
                    child: const Icon(Icons.qr_code),
                    onTap: () {
                      var data = json.encode(activity.toMap());
                      debugPrint(data);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => QrWidget(data)));
                    },
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'Edit':
                          debugPrint("Pressed Edit");
                          editActivity(context);
                          break;
                        case 'Delete GPX':
                          showDeleteGPXDialog(context);
                          break;
                        case 'Delete Activity':
                          showDeleteDialog(context);
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return {'Edit', 'Delete GPX', 'Delete Activity'}
                          .map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice),
                        );
                      }).toList();
                    },
                  ),
                ],
              ),
              body: ListView(
                children: [
                  InkWell(
                      onTap: () async {
                        await openImageModal(context);
                      }, //pickImage,
                      //child: image != null ? Image.file(image) : defaultImage()
                      child: image != null ?  PinchZoomImage(img: Image.file(image,fit: BoxFit.fill)) : defaultImage()
                      //const Image(image: AssetImage('assets/11_Langkofel_group_Dolomites_Italy.jpg'))
                      ),
                  Container(height: 5),
                  ListTile(
                    leading: const Icon(Icons.date_range),
                    title: const Text("Date of visit"),
                    subtitle: Text(
                        DateFormat('dd.MM.yyyy').format(activity.date),
                        style: dfStyle),
                  ),
                  ListTile(
                    leading: const Icon(Icons.people),
                    title: const Text("Visitors"),
                    subtitle: Text(
                        (activity.participants == null ||
                                activity.participants!.isEmpty)
                            ? "you'll never walk alone :)"
                            : activity.participants.toString(),
                        style: dfStyle),
                  ),
                  ListTile(
                    leading: const Icon(Icons.arrow_forward),
                    title: const Text("Distance"),
                    subtitle: Text(
                      activity.distance == null
                          ? "-"
                          : "${activity.distance} km",
                      style: dfStyle,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.timer),
                    title: const Text("Duration"),
                    subtitle: Text(
                      activity.duration == null
                          ? "-"
                          : "${activity.duration} h",
                      style: dfStyle,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.upgrade_outlined),
                    title: const Text("Elevation Gain"),
                    subtitle: Text(
                      activity.climb == null ? "-" : "${activity.climb} m",
                      style: dfStyle,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.place_rounded),
                    title: const Text("Position"),
                    subtitle: Text(
                      activity.location == null
                          ? "-"
                          : "Coordinates:\t${activity.location?.latitude.toStringAsFixed(3)}, ${activity.location?.longitude.toStringAsFixed(3)}",
                      style: dfStyle,
                    ),
                    onTap: () {
                      if (activity.location != null) {
                        postClipboard(
                            "${activity.location?.latitude}, ${activity.location?.longitude}",
                            context);
                      }
                    },
                  )
                ],
              ));
        });
  }

  void handleClick(value) {
    switch (value) {
      case 'Delete':
        debugPrint('clicked delete...');
        showDeleteDialog;
        break;
      case 'Edit':
        break;
    }
  }

  editActivity(BuildContext context) async {
    debugPrint("editing: ${widget.activityId}");
    await Navigator.pushNamed(context, "/add", arguments: widget.activityId)
        .then((_) => setState(() {}));
  }

  Future pickImage() async {
    try {
      debugPrint("pick image");
      XFile? img = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (img == null) return;
      debugPrint("Chose: ${img.path}");
      final imgSaved = await saveImage(img.path, widget.activityId);
      setState(() {
        debugPrint("(setState) chose image");
      });
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  openImageModal(context) async {
    showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        builder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.image),
                  title: const Text('Chose image from gallery'),
                  //onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                  onTap: () async {
                    await pickImage().then(Navigator.of(context).pop);
                  },
                ),
                Container(height: 75,)
              ],
            ));
  }

  Future<File> saveImage(String oldImagePath, int activityId) async {
    final directory = await getApplicationDocumentsDirectory();
    //final fileExtension = extension(oldImagePath);
    final name = basename('activity_$activityId'); //.$fileExtension');
    final newImage = File('${directory.path}/$name');
    //we also need to create/update the thumbnail!
    var thumbnailDetail = prefs.getInt("thumbnailDetail")??20;
    //var newThumb =
        //await FlutterNativeImage.compressImage(oldImagePath, quality: thumbnailDetail);
    var newThumb = await FlutterImageCompress.compressAndGetFile(oldImagePath, "${newImage.path}_thumbnail.jpg", quality: thumbnailDetail);
    //ImageProperties props = await FlutterNativeImage.getImageProperties(image.path);
    debugPrint("created a new thumb for $activityId with quality $thumbnailDetail %");
    //newThumb.copy("${newImage.path}_thumbnail");
    //debugPrint("compressed to: ${newThumb.lengthSync()}");
    return File(oldImagePath).copy(newImage.path);
  }

  Future<File?> loadImage(int activityId) async {
    final directory = await getApplicationDocumentsDirectory();
    File image = File('${directory.path}/activity_$activityId');
    return await image.exists() ? image : null;
  }

  postClipboard(String txt, context) {
    Clipboard.setData(ClipboardData(text: txt)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Position copied to clipboard")));
    });
  }

  defaultImage() {
    return Stack(alignment: Alignment.center, children: [
      Image(image: AssetImage('assets/Langkofel_bw.jpg')),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),//EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.all(Radius.circular(20))),
        child: const Text(
        "tap here to add image",
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: Colors.white54,
        ),
      ))
    ]);
  }
}

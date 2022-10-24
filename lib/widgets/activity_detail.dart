import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../database_helper.dart';
import '../models/mountain_activity.dart';
import 'qrwidget.dart';

class ActivityDetail extends StatefulWidget{
  final int activityId;
  const ActivityDetail(this.activityId, {super.key});

  @override
  State<ActivityDetail> createState() => _ActivityDetailState();
}

class _ActivityDetailState extends State<ActivityDetail> {

  //File? image;

  showDeleteDialog(BuildContext context) {
    // set up the buttons
    Widget deleteButton = TextButton(
      child: const Text("Delete", style: TextStyle(color: Colors.red)),
      onPressed:  () {
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
      onPressed:  () {Navigator.of(context).pop();},
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

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: Future.wait([DatabaseHelper.instance.getActivity(widget.activityId), loadImage(widget.activityId)]),
        builder: (context, snapshot){
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();//Center(child: Text("Loading..."));
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

          return Scaffold(
              appBar: AppBar(
                title: Text(activity.mountainName),
                actions: <Widget>[
                  InkWell(
                    child:const Icon(Icons.map),
                    onTap: () {
                      debugPrint("Show on map not implemented");
                    },
                  ),
                  Container(width: 20,),
                  InkWell(
                    child:const Icon(Icons.qr_code),
                    onTap: () {
                      var data = json.encode(activity.toMap());
                      debugPrint(data);
                      Navigator.push(context,MaterialPageRoute(builder: (context) => QrWidget(data)));
                    },
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch(value){
                        case 'Edit':
                          debugPrint("Pressed Edit");
                          editActivity(context);
                          break;
                        case 'Delete':
                          showDeleteDialog(context);
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return {'Edit', 'Delete'}.map((String choice) {
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
                      onTap: ()async{await openImageModal(context);},//pickImage,
                      child: image!=null ?Image.file(image) : const Image(image: AssetImage('assets/11_Langkofel_group_Dolomites_Italy.jpg'))
                  ),
                  Container(height: 5),
                  ListTile(
                    leading: const Icon(Icons.date_range),
                    title: const Text("Date of visit"),
                    subtitle: Text(DateFormat('dd.MM.yyyy').format(activity.date)),
                  ),
                  ListTile(
                    leading: const Icon(Icons.people),
                    title: const Text("Visitors"),
                    subtitle: Text(activity.participants??""),
                  ),
                  ListTile(
                    leading: const Icon(Icons.arrow_forward),
                    title: const Text("Distance"),
                    subtitle: Text("${activity.distance} km"),
                  ),
                  ListTile(
                    leading: const Icon(Icons.timer),
                    title: const Text("Duration"),
                    subtitle: Text("${activity.duration} h"),
                  ),
                  ListTile(
                    leading: const Icon(Icons.upgrade_outlined),
                    title: const Text("Vertical"),
                    subtitle: Text("${activity.climb} hm"),
                  ),
                  ListTile(
                    leading: const Icon(Icons.place_rounded),
                    title: const Text("Position"),
                    subtitle: Text("Lat: ${activity.location?.latitude}\nLon: ${activity.location?.longitude}"),
                  )
                ],
              )
          );
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
    await Navigator.pushNamed(context, "/add",arguments: widget.activityId).then((_) => setState((){}));
  }

  Future pickImage() async{
    try {
      debugPrint("pick image");
      XFile? img = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (img == null) return;
      debugPrint("Chose: ${img.path}");
      final imgSaved = await saveImage(img.path,widget.activityId);
      setState((){debugPrint("(setState) chose image");});
    } on PlatformException catch(e) {
      print('Failed to pick image: $e');
    }
  }


  openImageModal(context) async {
     showModalBottomSheet(
        context: context,
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Chose image from gallery'),
              //onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              onTap: ()async {await pickImage().then(Navigator.of(context).pop);},
            )
          ],
        )
     );

  }

  Future<File> saveImage(String oldImagePath, int activityId) async{
    final directory = await getApplicationDocumentsDirectory();
    //final fileExtension = extension(oldImagePath);
    final name = basename('activity_$activityId');//.$fileExtension');
    final newImage = File('${directory.path}/$name');
    return File(oldImagePath).copy(newImage.path);
  }

  Future<File?> loadImage(int activityId) async{
    final directory = await getApplicationDocumentsDirectory();
    File image = File('${directory.path}/activity_$activityId');
    return await image.exists() ? image : null;
  }
}
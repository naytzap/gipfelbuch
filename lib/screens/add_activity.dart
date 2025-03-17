import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart' as osm;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database_helper.dart';
import '../models/mountain_activity.dart';

//import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class AddActivityForm extends StatefulWidget {
  //final int activityId;
  const AddActivityForm(/*this.activityId,*/ {super.key});

  @override
  State<StatefulWidget> createState() => _AddActivityFormState();
}

class _AddActivityFormState extends State<AddActivityForm> {
  final _formKey = GlobalKey<FormState>();
  late bool _editMode = false;
  late SharedPreferences prefs;
  bool edited = false;
  File? gpxFile;
  late final TextEditingController _nameCtrl = TextEditingController();
  late final TextEditingController _visitorCtrl = TextEditingController();
  late final TextEditingController _dateCtrl = TextEditingController();
  late final TextEditingController _distanceCtrl = TextEditingController();
  late final TextEditingController _durationCtrl = TextEditingController();
  late final TextEditingController _climbCtrl = TextEditingController();
  late final TextEditingController _locationCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    sharedData();
  }
    void sharedData() async {
    prefs = await SharedPreferences.getInstance(); 
  }

  loadInitGpx() async {
    final int actId = ModalRoute.of(context)?.settings.arguments as int;
    final directory =   await getApplicationDocumentsDirectory();
    File? savedFile = File("${directory.path}/track_$actId.gpx");
    setState((){
      debugPrint("loaded file");
      gpxFile = savedFile.existsSync()?savedFile:null;});
  }

  @override
  void dispose() {
    debugPrint("dispose add/edit activity");
    _nameCtrl.dispose();
    _visitorCtrl.dispose();
    _dateCtrl.dispose();
    _distanceCtrl.dispose();
    _durationCtrl.dispose();
    _climbCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> scanQR() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      //barcodeScanRes = await FlutterBarcodeScanner.scanBarcode("#8BC34AFF", 'Cancel', false, ScanMode.QR);
      barcodeScanRes = "TODO";//await MobileScanner().
      debugPrint(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      //_scanBarcode = barcodeScanRes;
      debugPrint(barcodeScanRes.toString());
      var act = jsonDecode(barcodeScanRes.toString());
      //Todo: error handling
      _nameCtrl.text = act["mountainName"];
      _visitorCtrl.text = act["participants"];
      _dateCtrl.text = DateFormat("dd.MM.yyyy")
          .format(DateTime.fromMillisecondsSinceEpoch(act["date"]));
      _distanceCtrl.text = act["distance"].toString();
      _durationCtrl.text = act["duration"].toString();
      _climbCtrl.text = act["climb"].toString();
      _locationCtrl.text = "${act["latitude"]}, ${act["longitude"]}";
      //location
    });
  }

  setInputFields(MountainActivity act) {
    _nameCtrl.text = act.mountainName;
    _visitorCtrl.text = act.participants ?? "";
    _dateCtrl.text = DateFormat('dd.MM.yyyy').format(act.date);
    _distanceCtrl.text = (act.distance ?? "").toString();
    _durationCtrl.text = (act.duration ?? "").toString();
    _climbCtrl.text = (act.climb ?? "").toString();

    if (act.location?.latitude != null && act.location?.longitude != null) {
      _locationCtrl.text =
          "${act.location?.latitude}, ${act.location?.longitude}";
    } else {
      _locationCtrl.text = "";
    }
  }

  buildForm(int? actId) {
    double vSpacing = 10;
    return Form(
        //padding: const EdgeInsets.all(10),
        //itemExtent: 70,
        key: _formKey,
        child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Mountain Name',
                      icon: Icon(
                        Icons.landscape_outlined,
                      ),
                    ),
                    controller: _nameCtrl,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: vSpacing),
                  TextField(
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Visitors',
                        icon: Icon(Icons.people_outlined)),
                    controller: _visitorCtrl,
                  ),
                  SizedBox(height: vSpacing),
                  TextFormField(
                    controller:
                        _dateCtrl, //editing controller of this TextField
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        icon: Icon(Icons.calendar_today), //icon of text field
                        labelText: "Date" //label text of field
                        ),
                    readOnly:
                        true, //set it true, so that user will not able to edit text
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _dateCtrl.text.isEmpty
                              ? DateTime.now()
                              : DateFormat("dd.MM.yyyy").parse(_dateCtrl.text),
                          firstDate: DateTime(
                              1960), //DateTime.now() - not to allow to choose before today.
                          lastDate: DateTime.now(),
                          locale: const Locale('de', 'DE'));

                      if (pickedDate != null) {
                        //print(pickedDate);  //pickedDate output format => 2021-03-10 00:00:00.000
                        String formattedDate =
                            DateFormat('dd.MM.yyyy').format(pickedDate);
                        debugPrint(
                            "Selected $formattedDate"); //formatted date output using intl package =>  2021-03-16
                        //you can implement different kind of Date Format here according to your requirement

                        setState(() {
                          _dateCtrl.text =
                              formattedDate; //set output date to TextField value.
                        });
                      } else {
                        debugPrint("Date is not selected");
                      }
                    },
                    validator: (value) {
                      if (value?.isEmpty ?? false) {
                        return 'Please select a date';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: vSpacing),
                  TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Distance [km]',
                      icon: Icon(
                        Icons.straighten_outlined,
                      ),
                    ),
                    controller: _distanceCtrl,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      return validatePositiveNumber(value);
                    },
                  ),
                  SizedBox(height: vSpacing),
                  TextFormField(
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Duration [h]',
                        icon: Icon(Icons.timer_outlined)),
                    controller: _durationCtrl,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      return validatePositiveNumber(value);
                    },
                  ),
                  SizedBox(height: vSpacing),
                  TextFormField(
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Vertical Meters [m]',
                        icon: Icon(Icons.height_outlined)),
                    controller: _climbCtrl,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      return validatePositiveNumber(value);
                    },
                  ),
                  SizedBox(height: vSpacing),
                  TextFormField(
                    //
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Position [12.345, 67.890]',
                      icon: const Icon(Icons.place_rounded),
                      suffixIcon: GestureDetector(
                        child: Icon(Icons.my_location_outlined),
                        onTap: () async {
                          osm.GeoPoint? p = await osm.showSimplePickerLocation(
                            context: context,
                            isDismissible: false,
                            title: "Select Summit Position",
                            titleStyle: TextStyle(fontSize: 20),
                            textConfirmPicker: "Select",
                            textCancelPicker: "Cancel",
                            //initCurrentUserPosition: false,
                            initPosition: (_locationCtrl.text.isEmpty)
                                ? osm.GeoPoint(
                                    latitude: 47.886302, longitude: 12.467000)
                                : parseLocation(_locationCtrl.text),
                            zoomOption: osm.ZoomOption(initZoom: (_locationCtrl.text.isEmpty)
                                ? 8 : 12)

                          );
                          if (p != null) {
                            String formattedPoint =
                                "${p.latitude}, ${p.longitude}";
                            debugPrint("Selected $formattedPoint");
                            //_location = p;
                            setState(() {
                              _locationCtrl.text =
                                  formattedPoint; //set output date to TextField value.
                            });
                          } else {
                            debugPrint("Date is not selected");
                          }
                        },
                      ),
                    ),
                    controller: _locationCtrl,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      //thanks to: https://stackoverflow.com/a/18690202
                      final locationPattern = RegExp(
                          r'^[-+]?([1-8]?\d(\.\d+)?|90(\.0+)?),\s*[-+]?(180(\.0+)?|((1[0-7]\d)|([1-9]?\d))(\.\d+)?)$');
                      if ((value?.isNotEmpty ?? false)) {
                        if (!locationPattern.hasMatch(_locationCtrl.text)) {
                          return "Please enter format in format: [12.345, 67.890]";
                        }
                      }
                      return null;
                    },
                    //readOnly: true,
                    //onTap:
                  ),
                  SizedBox(height: vSpacing),
                  gpxFile != null
                      ? gpxWidget(actId)
                      : Text("No GPX file"),
                  SizedBox(height: vSpacing),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       TextButton(
                            onPressed: () {
                              addGPX(context);
                              //setState(() {});
                            },
                            child: gpxFile == null ? Text("Add GPX") : Text("Change GPX")),

                      SizedBox(
                        width: 50,
                      ),
                      //Expanded(child: Container()),,

                       FloatingActionButton(
                              onPressed: () async {
                                debugPrint("Add act pressed");
                                if (_formKey.currentState!.validate()) {
                                  var activity = MountainActivity(
                                      id: _editMode ? actId! : null,
                                      mountainName: _nameCtrl.text,
                                      climb: int.tryParse(_climbCtrl.text),
                                      distance:
                                          double.tryParse(_distanceCtrl.text),
                                      duration:
                                          double.tryParse(_durationCtrl.text),
                                      location: (_locationCtrl.text.isEmpty)
                                          ? null
                                          : parseLocation(
                                              _locationCtrl.text), //_location,
                                      participants: _visitorCtrl.text,
                                      date: DateFormat("dd.MM.yyyy")
                                          .parse(_dateCtrl.text));
                                  debugPrint(activity.toMap().toString());
                                  int? id;
                                  if (_editMode) {
                                    id = actId;
                                    await DatabaseHelper.instance
                                        .update(activity);
                                  } else {
                                    id = await DatabaseHelper.instance
                                        .addActivity(activity);
                                  }
                                  if (gpxFile != null && id != null && path.basename(gpxFile!.path)!="track_$id.gpx") {
                                    final directory =
                                        await getApplicationDocumentsDirectory();
                                    gpxFile!.copy(
                                        "${directory.path}/track_$id.gpx");
                                  }
                                  Navigator.pop(context);
                                } else {
                                  debugPrint("Form not valid!");
                                }
                              },
                              child: Text(
                                _editMode ? "Save" : "Add",
                                /*style: const TextStyle(
                                    backgroundColor: Colors.lightGreen,
                                    color: Colors.white),*/
                              )),
                    ],
                  )
                ],
              ),
            )));
  }

  @override
  Widget build(BuildContext context) {
    final int? actId = ModalRoute.of(context)?.settings.arguments as int?;
    _editMode = actId != null;
    debugPrint("EditMode: $_editMode");

    return Scaffold(
        appBar: AppBar(
          title: _editMode == true
              ? const Text("Edit Activity")
              : const Text("Add Activity"),
          /*actions: _editMode
              ? []
              : <Widget>[
                  InkWell(
                      onTap: scanQR, child: const Icon(Icons.qr_code_scanner)),
                  Container(
                    width: 15,
                  ),
                ],*/
        ),
        body: _editMode
            ? FutureBuilder(
                future: DatabaseHelper.instance.getActivity(actId!),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Text("No data");
                  }
                  MountainActivity act = snapshot.data as MountainActivity;
                  if (_editMode && !edited) {
                    edited = true;
                    setInputFields(act);
                    loadInitGpx();
                  }
                  return buildForm(act.id);
                })
            : buildForm(null));
  }

  osm.GeoPoint parseLocation(String text) {
    var latlon = text.split(",");
    double lat = double.parse(latlon[0]);
    double lon = double.parse(latlon[1]);
    return osm.GeoPoint(latitude: lat, longitude: lon);
  }

  validatePositiveNumber(value) {
    if ((value?.isNotEmpty ?? false) && !(double.tryParse(value!) == null)) {
      if (double.tryParse(value)! < 0) {
        return 'Insert positive value';
      }
      return null;
    } else if (value?.isNotEmpty ?? false) {
      return 'Please enter a positive number!';
    }
  }

  Future<void> addGPX(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      //type: FileType.custom,
      //allowedExtensions: ['gpx'],
    );

    if (result != null) {
      setState((){gpxFile = File(result.files.single.path ?? "");});
      debugPrint("Picked GPX ${gpxFile!.path}");
      //TODO: Test for gpx extension if not possible to filter to GPX
    } else {
      //user cancelled file picker dialogue
    }
  }

  gpxWidget(id) {
    String fname = path.basename(gpxFile!.path);
    //fname = "oneofthe_longestFileNamesyouCan_imagine123456.gpx";
    if(fname=="track_$id.gpx") {
     fname = "GPX-File";
    }
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(10),

    ),child:Row(
      mainAxisSize: MainAxisSize.min,
        children:[Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            constraints: const BoxConstraints(maxWidth: 250),
            child:
              Text( fname,
              style: const TextStyle(color: Colors.white),),
        )
      ],
    ),
          _editMode ? Container() :Container(width:10),
          _editMode ? Container() :
          InkWell(onTap: (){setState(() {
            gpxFile = null;
          });},child: Icon(Icons.delete, color: Colors.white)),]));
    /*return Container(
        constraints: BoxConstraints(minWidth: 50, maxWidth: 250),
      //width: 240,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: const BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.all(Radius.circular(80))),
        child: Row(children: [
          Text( txt,
              style: const TextStyle(color: Colors.white),),
          Container(width: 10,),
          const Icon(Icons.close, color: Colors.deepOrange),
    ],)
    );*/
  }

  //build()
} //class

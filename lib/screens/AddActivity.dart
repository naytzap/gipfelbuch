import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:intl/intl.dart';

import '../database_helper.dart';
import '../models/MountainActivity.dart';

import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class AddActivityForm extends StatefulWidget {
  final MountainActivity? activity;
  AddActivityForm(this.activity, {super.key});

  @override
  State<StatefulWidget> createState() => _AddActivityFormState();
}

class _AddActivityFormState extends State<AddActivityForm> {
  final _formKey = GlobalKey<FormState>();
  late bool _editMode = false;
  bool edited = false;
  late MountainActivity _editedActivity;
  //late MountainActivity? activity;
  late final TextEditingController _nameCtrl= TextEditingController();
  late final TextEditingController _visitorCtrl= TextEditingController();
  late final TextEditingController _dateCtrl= TextEditingController();
  late final TextEditingController _distanceCtrl= TextEditingController();
  late final TextEditingController _durationCtrl= TextEditingController();
  late final TextEditingController _climbCtrl= TextEditingController();

  @override
  void initState() {

    super.initState();

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
    super.dispose();
  }

  Future<void> readQrCode() async {
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        Colors.lightGreen.toString(),
        "Cancel",
        false, ScanMode.QR);
    debugPrint(barcodeScanRes.toString());
  }

  Future<void> scanQR() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#8BC34AFF", 'Cancel', false, ScanMode.QR);
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
      var activity = jsonDecode(barcodeScanRes.toString());
      //Todo: error handling
      _nameCtrl.text = activity["mountainName"];
      _visitorCtrl.text = activity["participants"];
      _dateCtrl.text = DateFormat("dd.MM.yyyy")
          .format(DateTime.fromMillisecondsSinceEpoch(activity["date"]));
      _distanceCtrl.text = activity["distance"].toString();
      _durationCtrl.text = activity["duration"].toString();
      _climbCtrl.text = activity["climb"].toString();
    });
  }


  @override
  Widget build(BuildContext context) {

    final act = ModalRoute.of(context)?.settings.arguments as MountainActivity;
    _editMode = act.id!=null;
    if(_editMode){
        if (!edited) {
          //this is only once called
          edited = true;
          _editedActivity = act;
          _nameCtrl.text = _editedActivity!.mountainName;
          _visitorCtrl.text = _editedActivity!.participants??"";
          _dateCtrl.text = DateFormat('dd.MM.yyyy').format(_editedActivity!.date);
          _distanceCtrl.text = _editedActivity!.distance.toString();
          _durationCtrl.text = _editedActivity!.duration.toString();
          _climbCtrl.text = _editedActivity!.climb.toString();
        }
    }

    double vSpacing = 10;
    return Scaffold(
        appBar: AppBar(
          title: _editMode == true ? const Text("Edit Activity") : const Text("Add Activity"),
          actions: _editMode?[]:<Widget> [
            InkWell(
              onTap: scanQR,
              child: const Icon(Icons.qr_code_scanner)
            ),
            Container(width: 15,),
          ],
        ),
        body: Form(
          //padding: const EdgeInsets.all(10),
          //itemExtent: 70,
          key: _formKey,
          child:
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
            child:
          SingleChildScrollView(
    child:
          Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Mountain Name',
                  icon: Icon(Icons.landscape_outlined,),),
              controller: _nameCtrl,
              validator: (value) {
                if (value == null || value.isEmpty){
                  return 'Please enter a name';
                  }
                return null;
              },
            ),
            SizedBox(height:vSpacing),
            TextField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Visitors',
                  icon: Icon(Icons.people_outlined)),
              controller: _visitorCtrl,
            ),
            //InputDatePickerFormField(,firstDate: DateTime(1990,1,1), lastDate: DateTime.now(),
            //),
            SizedBox(height:vSpacing),
            TextFormField(
              controller: _dateCtrl, //editing controller of this TextField
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  icon: Icon(Icons.calendar_today), //icon of text field
                  labelText: "Date" //label text of field
              ),
              readOnly: true,  //set it true, so that user will not able to edit text
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                    context: context, initialDate: DateTime.now(),
                    firstDate: DateTime(1960), //DateTime.now() - not to allow to choose before today.
                    lastDate: DateTime.now(),
                    locale: const Locale('de', 'DE')
                );

                if(pickedDate != null ){
                  //print(pickedDate);  //pickedDate output format => 2021-03-10 00:00:00.000
                  String formattedDate = DateFormat('dd.MM.yyyy').format(pickedDate);
                  debugPrint("Selected $formattedDate"); //formatted date output using intl package =>  2021-03-16
                  //you can implement different kind of Date Format here according to your requirement

                  setState(() {
                    _dateCtrl.text = formattedDate; //set output date to TextField value.
                  });
                }else{
                  debugPrint("Date is not selected");
                }
              },
              validator: (value) {
                if(value?.isEmpty??false) {
                  return 'Please select a date';
                }
              },
            ),
            SizedBox(height:vSpacing),
            TextFormField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: 'Distance',
                  icon: Icon(Icons.straighten_outlined,),),
              controller: _distanceCtrl,
              validator: (value) {
                if((value?.isNotEmpty??false) && !(double.tryParse(value!)==null)){
                  if(double.tryParse(value)!<0) {
                    return 'Insert positive value';
                  }
                  return null;
                }else if(value?.isNotEmpty??false) {
                  return 'Please enter a positive number!';
                }
                },
            ),
            SizedBox(height:vSpacing),
            TextField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: 'Duration',
                  icon: Icon(Icons.timer_outlined)),
              controller: _durationCtrl,
            ),
            SizedBox(height:vSpacing),
            TextField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: 'Vertical Meters',
              icon: Icon(Icons.height_outlined)),
              controller: _climbCtrl,
            ),
            SizedBox(height:vSpacing),
            Container(
                color: Colors.lightGreen,
                child: TextButton(
                    onPressed: () {
                      debugPrint("Add act pressed");
                      if(_formKey.currentState!.validate()) {
                        var activity = MountainActivity(
                            id: _editMode?act.id:null,
                            mountainName: _nameCtrl.text,
                            climb: int.tryParse(_climbCtrl.text),
                            distance: double.tryParse(_distanceCtrl.text),
                            duration: double.tryParse(_durationCtrl.text),
                            location: GeoPoint(latitude: 49, longitude: 12),
                            participants: _visitorCtrl.text,
                            date: DateFormat("dd.MM.yyyy").parse(_dateCtrl.text));
                        debugPrint(activity.toMap().toString());
                        if(_editMode) {
                          DatabaseHelper.instance.update(activity);
                        }else {
                          DatabaseHelper.instance.addActivity(activity);
                        }
                        Navigator.pop(context);
                      }else{debugPrint("Form not valid!");}
                      },
                    child: Text(_editMode?"Edit Activity": "Add Activity",
                      style: TextStyle(
                          backgroundColor: Colors.lightGreen,
                          color: Colors.white),
                    )))
          ],
        ),
          )
          )
        )
    );
  }
}

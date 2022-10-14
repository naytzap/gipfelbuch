import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:intl/intl.dart';

import '../database_helper.dart';
import '../models/MountainActivity.dart';

class AddActivityForm extends StatefulWidget {
  const AddActivityForm({super.key});

  @override
  State<StatefulWidget> createState() => _AddActivityFormState();
}

class _AddActivityFormState extends State<AddActivityForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl= TextEditingController();
  late TextEditingController _visitorCtrl= TextEditingController();
  late TextEditingController _dateCtrl= TextEditingController();
  late TextEditingController _distanceCtrl= TextEditingController();
  late TextEditingController _durationCtrl= TextEditingController();
  late TextEditingController _climbCtrl= TextEditingController();

  @override
  void initState() {
    super.initState();
    //_nameCtrl = TextEditingController();
    //_dateCtrl = TextEditingController();
    //_visitorCtrl = TextEditingController();
    //_distanceCtrl = TextEditingController();
    //_durationCtrl = TextEditingController();
    //_climbCtrl = TextEditingController();
  }

  @override
  void dispose() {
    //_controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double vSpacing = 10;
    return Scaffold(
        appBar: AppBar(
          title: const Text("Add Activity"),
        ),
        body: Form(
          //padding: const EdgeInsets.all(10),
          //itemExtent: 70,
          key: _formKey,
          child:
          Padding(
            padding: EdgeInsets.fromLTRB(15, 20, 15, 0),
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
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  icon: Icon(Icons.calendar_today), //icon of text field
                  labelText: "Date" //label text of field
              ),
              readOnly: true,  //set it true, so that user will not able to edit text
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                    context: context, initialDate: DateTime.now(),
                    firstDate: DateTime(2000), //DateTime.now() - not to allow to choose before today.
                    lastDate: DateTime(2101)
                );

                if(pickedDate != null ){
                  //print(pickedDate);  //pickedDate output format => 2021-03-10 00:00:00.000
                  String formattedDate = DateFormat('dd.MM.yyyy').format(pickedDate);
                  //print(formattedDate); //formatted date output using intl package =>  2021-03-16
                  //you can implement different kind of Date Format here according to your requirement

                  setState(() {
                    _dateCtrl.text = formattedDate; //set output date to TextField value.
                  });
                }else{
                  print("Date is not selected");
                }
              },
              validator: (value) {
                if(value?.isEmpty??false)
                  return 'Please select a date';
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
                  if(double.tryParse(value)!<0)
                    return 'Insert positive value';
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
                            mountainName: _nameCtrl.text,
                            climb: int.tryParse(_climbCtrl.text),
                            distance: double.tryParse(_distanceCtrl.text),
                            duration: double.tryParse(_durationCtrl.text),
                            location: GeoPoint(latitude: 49, longitude: 12),
                            participants: _visitorCtrl.text??"",
                            date: DateFormat("dd.MM.yyyy").parse(_dateCtrl.text));
                        debugPrint(activity.toMap().toString());
                        DatabaseHelper.instance.addActivity(activity);
                        Navigator.pop(context);
                      }else{debugPrint("Form not valid!");}
                      },
                    child: const Text(
                      "Add activity",
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

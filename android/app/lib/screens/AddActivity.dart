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
  late TextEditingController _controller;
  late TextEditingController _nameCtrl;
  late TextEditingController _dateCtrl;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _nameCtrl = TextEditingController();
    _dateCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Add Activity"),
        ),
        body: Form(
          //padding: const EdgeInsets.all(10),
          //itemExtent: 70,
          key: _formKey,
          child: Column(

          children: [
            TextFormField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: 'Mountain Name'),
              controller: _nameCtrl,
              validator: (value) {
                if (value == null || value.isEmpty){
                  return 'Please enter a name';
                  }
                return null;
              },
            ),
            TextField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: 'Visitors'),
              controller: _controller,
            ),
            //InputDatePickerFormField(,firstDate: DateTime(1990,1,1), lastDate: DateTime.now(),
            //),
            TextFormField(
              controller: _dateCtrl, //editing controller of this TextField
              decoration: InputDecoration(
                  //icon: Icon(Icons.calendar_today), //icon of text field
                  labelText: "Enter Date" //label text of field
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
            ),
            TextField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: 'Distance'),
              controller: _controller,
            ),
            TextField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: 'Duration'),
              controller: _controller,
            ),
            TextField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: 'Vertical Meters'),
              controller: _controller,
            ),
            Container(
                color: Colors.lightGreen,
                child: TextButton(
                    onPressed: () {
                      debugPrint("Add act pressed");
                      if(_formKey.currentState!.validate()) {
                        DatabaseHelper.instance.addActivity(MountainActivity(
                            mountainName: _nameCtrl.text,
                            climb: 13,
                            distance: 14,
                            duration: 234,
                            location: GeoPoint(latitude: 1, longitude: 1),
                            participants: "ich, und, wer, anders",
                            date: DateFormat("dd.MM.yyyy").parse(_dateCtrl.text)));
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
    );
  }
}

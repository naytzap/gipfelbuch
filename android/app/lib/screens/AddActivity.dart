import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

import '../database_helper.dart';
import '../models/MountainActivity.dart';

class AddActivityForm extends StatefulWidget {
  const AddActivityForm({super.key});

  @override
  State<StatefulWidget> createState() => _AddActivityFormState();
}

class _AddActivityFormState extends State<AddActivityForm> {
  late TextEditingController _controller;
  late TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _nameCtrl = TextEditingController();
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
        body: ListView(
          padding: const EdgeInsets.all(10),
          itemExtent: 70,
          children: [
            TextField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: 'Mountain Name'),
              controller: _nameCtrl,
            ),
            TextField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: 'Visitors'),
              controller: _controller,
            ),
            InputDatePickerFormField(firstDate: DateTime(1990,1,1), lastDate: DateTime.now(),
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
                      DatabaseHelper.instance.addActivity(MountainActivity(
                          mountainName: _nameCtrl.text,
                          climb: 13,
                          distance: 14,
                          duration: 234,
                          location: GeoPoint(latitude: 1,longitude: 1),
                          participants: "ich, und, wer, anders",
                          date: DateTime.now()));
                    Navigator.pop(context);
                      },
                    child: const Text(
                      "Add activity",
                      style: TextStyle(
                          backgroundColor: Colors.lightGreen,
                          color: Colors.white),
                    )))
          ],
        )
    );
  }
}

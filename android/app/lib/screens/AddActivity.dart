import 'package:flutter/material.dart';

class AddActivityForm extends StatefulWidget {
  const AddActivityForm({super.key});

  @override
  State<StatefulWidget> createState() => _AddActivityFormState();
}

class _AddActivityFormState extends State<AddActivityForm> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
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
              controller: _controller,
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

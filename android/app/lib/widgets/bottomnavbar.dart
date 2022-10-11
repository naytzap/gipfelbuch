import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _MyBottomNBState();

  getIndex() {
    
  }
}

class _MyBottomNBState extends State<BottomNavBar> {
  var _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(
          () {
        _selectedIndex = index;
      },
    );
  }

  int getIndex() => _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'List',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: 'Map',
        ),
      ],
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
    );
  }
}
// The home screen

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'rosie_theme.dart';
import 'get_started/get_started.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Selected tab
  int _selectedIndex = 2;

  _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _addRosieBackground(Widget child) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        child: Container(
          decoration: createRosieScreenBoxDecoration(),
          child: child
        ),
        value: SystemUiOverlayStyle.dark
      );
  }

  Widget _buildSelectedPage() {
    switch (_selectedIndex) {
      case 2:
        return _addRosieBackground(const Center(child: GetStarted()));
      default:
        return _addRosieBackground(const Center(child: Text("Not Implemented")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        child: _buildSelectedPage(),
        value: SystemUiOverlayStyle.dark
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.download),
            label: 'PDM',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail),
            label: 'Care Plan'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.arrow_upward),
            label: 'Home'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.share),
            label: 'Community'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Settings'
          )
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped
      ),
    );
  }
}
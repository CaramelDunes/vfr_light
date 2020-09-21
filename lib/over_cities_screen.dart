import 'package:flutter/material.dart';

class OverCitiesScreen extends StatefulWidget {
  @override
  _OverCitiesScreenState createState() => _OverCitiesScreenState();
}

class _OverCitiesScreenState extends State<OverCitiesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Overflying cities'),
        ),
        body: Center(
          child: Image.asset('assets/survol.png'),
        ));
  }
}

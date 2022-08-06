import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background/flutter_background.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:positioned_tap_detector_2/positioned_tap_detector_2.dart';
import 'package:wakelock/wakelock.dart';

import '../record_button.dart';
import '../route_manager.dart';
import 'flight_map.dart';
import '../instruments.dart';
import '../instruments_data_source.dart';
import '../over_cities_screen.dart';
import '../navigation_data_source.dart';
import '../navigation_info.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late InstrumentsDataSource _instrumentsDataSource;
  late RouteManager _routeManager;
  NavigationDataSource? _navigationDataSource;
  late StreamSubscription<LatLng> _destinationStreamSubscription;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    Wakelock.enable();

    _instrumentsDataSource =
        InstrumentsDataSource(qnh: 1013.25, surfaceAltitudeInM: 0);

    _routeManager = RouteManager(instrumentsDataSource: _instrumentsDataSource);

    _destinationStreamSubscription =
        _routeManager.destinationStream.listen((event) {
      _navigationDataSource?.dispose();
      _navigationDataSource = NavigationDataSource(
          destination: event, stream: _instrumentsDataSource.data);
      setState(() {});
    });

    final androidConfig = FlutterBackgroundAndroidConfig(
      notificationTitle: "VFR Light location service",
      notificationText:
          "Enables recording of GPS data while app is in the background.",
    );
    Future<bool> success =
        FlutterBackground.initialize(androidConfig: androidConfig);
  }

  @override
  void dispose() {
    _destinationStreamSubscription.cancel();
    _navigationDataSource?.dispose();

    // The next line disables the wakelock again.
    Wakelock.disable();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RecordButton(dataSource: _instrumentsDataSource),
              IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.city,
                  color: Colors.white,
                ),
                tooltip: 'Overflying Cities',
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                    return OverCitiesScreen();
                  }));
                },
              ),
              IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.tachometerAlt,
                  color: Colors.white,
                ),
                tooltip: 'Quick Calibration',
                onPressed: () {
                  String val = '';
                  showDialog(
                      context: context,
                      builder: (c) {
                        return AlertDialog(
                          title: Text('Quick altimeter calibration'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                decoration: InputDecoration(
                                    labelText: 'Field altitude (m)'),
                                keyboardType: TextInputType.number,
                                onChanged: (s) {
                                  val = s;
                                },
                              ),
                              SizedBox(height: 8),
                              ElevatedButton(
                                child: Text('Submit'),
                                onPressed: () {
                                  print(double.parse(val));
                                  _instrumentsDataSource.recalibrateAtSfc(
                                      surfaceAltitudeInM: double.parse(val));
                                  Navigator.pop(c);
                                },
                              )
                            ],
                          ),
                        );
                      });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.navigation,
                  color: Colors.white,
                ),
                color: _navigationDataSource != null ? Colors.green : null,
                tooltip: 'Navigation',
                onPressed: () {
                  if (_navigationDataSource == null) {
                    _routeManager.startNavigation();
                  } else {
                    _routeManager.stopNavigation();
                    _navigationDataSource?.dispose();

                    setState(() {
                      _navigationDataSource = null;
                    });
                  }
                },
              ),
            ],
          ),
          if (_navigationDataSource != null)
            StreamBuilder(
                stream: _navigationDataSource!.data,
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.active:
                      return NavigationInfo(data: snapshot.data);

                    case ConnectionState.none:
                    case ConnectionState.waiting:
                    case ConnectionState.done:
                    default:
                      return Center(
                        child: Text(
                          'Loading...',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      );
                  }
                }),
          Expanded(
              child: FlightMap(
            dataStream: _instrumentsDataSource.data,
            onLongPress: _onLongPress,
            route: _routeManager.routeRepresentation(),
          )),
          StreamBuilder(
              stream: _instrumentsDataSource.data,
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.active:
                    return Instruments(data: snapshot.data);

                  case ConnectionState.none:
                  case ConnectionState.waiting:
                  case ConnectionState.done:
                  default:
                    return Center(
                      child: Text(
                        'Loading...',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    );
                }
              }),
        ],
      ),
    );
  }

  void _onLongPress(TapPosition _, LatLng position) {
    showDialog(
        context: context,
        builder: (c) {
          return SimpleDialog(
            title: Text(position.toSexagesimal()),
            children: <Widget>[
              SimpleDialogOption(
                child: const Text('Add to route'),
                onPressed: () {
                  _routeManager.waypoints.add(position);
                  Navigator.pop(c);
                  setState(() {});
                },
              ),
              if (_routeManager.waypoints.isNotEmpty)
                SimpleDialogOption(
                  child: const Text('Replace route'),
                  onPressed: () {
                    _routeManager.waypoints = [position];
                    Navigator.pop(c);
                    setState(() {});
                  },
                ),
              SimpleDialogOption(
                child: const Text('Back'),
                onPressed: () {
                  Navigator.pop(c);
                  setState(() {});
                },
              ),
            ],
          );
        });
  }
}

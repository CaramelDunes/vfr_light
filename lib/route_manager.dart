import 'dart:async';

import 'package:meta/meta.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:vfr_essentials/instruments_data_source.dart';

class RouteManager {
  List<LatLng> waypoints = [];
  StreamController<LatLng> _destinationStream = StreamController.broadcast();
  final InstrumentsDataSource instrumentsDataSource;
  StreamSubscription<InstrumentsData> _instrumentsDataSubscription;
  int _destinationIndex = 0;
  bool _navigationStarted = false;

  RouteManager({@required this.instrumentsDataSource}) {
    _instrumentsDataSubscription =
        instrumentsDataSource.data.listen(_onInstrumentsData);
  }

  void dispose() {
    _instrumentsDataSubscription.cancel();
    _destinationStream.close();
  }

  Stream<LatLng> get destinationStream => _destinationStream.stream;

  Polyline routeRepresentation() {
    if (instrumentsDataSource.lastPosition != null) {
      return Polyline(
          points: [instrumentsDataSource.lastPosition] + waypoints,
          strokeWidth: 3);
    } else {
      return Polyline(points: waypoints, strokeWidth: 3);
    }
  }

  void startNavigation() {
    if (!_navigationStarted && waypoints.isNotEmpty) {
      _navigationStarted = true;
      _destinationIndex = 0;
      _destinationStream.add(waypoints[_destinationIndex]);
    }
  }

  void stopNavigation() {
    if (_navigationStarted) {
      _navigationStarted = false;
    }
  }

  void _onInstrumentsData(InstrumentsData data) {
    if (_navigationStarted && waypoints.isNotEmpty && data.position != null) {
      Distance d = Distance();
      double distanceInM =
          d.distance(data.position, waypoints[_destinationIndex]);

      if (distanceInM < 20 && waypoints.length > _destinationIndex + 1) {
        _destinationStream.add(waypoints[++_destinationIndex]);
      }
    }
  }
}

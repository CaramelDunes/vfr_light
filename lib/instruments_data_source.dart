import 'dart:async';

import 'package:enviro_sensors/enviro_sensors.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meta/meta.dart';
import 'standard_atmosphere.dart';
import 'package:latlong/latlong.dart';

class InstrumentsData {
  final LatLng position;
  final double speedInKmH;
  final double altitudeInM;
  final double heightInM;
  final double headingInDeg;
  final DateTime time;

  InstrumentsData(
      {@required this.position,
      @required this.speedInKmH,
      @required this.altitudeInM,
      @required this.heightInM,
      @required this.headingInDeg,
      @required this.time});
}

class InstrumentsDataSource {
  final LocationOptions locationOptions = LocationOptions();

  double qnh;
  double surfaceAltitudeInM;
  final StreamController<InstrumentsData> _instrumentsDataStream =
      StreamController.broadcast();

  StreamSubscription _pressureSubscription;
  StreamSubscription _positionSubscription;

  LatLng _lastPosition;
  double _lastSpeedInKmH;
  double _lastAltitudeInM;
  double _lastHeightInM;
  double _lastHeadingInDeg;

  InstrumentsDataSource(
      {@required this.qnh, @required this.surfaceAltitudeInM}) {
    _positionSubscription =
        getPositionStream(desiredAccuracy: LocationAccuracy.high)
            .listen(_onNewPosition);

    _pressureSubscription =
        barometerEvents.asBroadcastStream().listen(_onNewPressure);
  }

  void dispose() {
    _pressureSubscription.cancel();
    _positionSubscription.cancel();
  }

  Future<void> recalibrateAtSfc({@required double surfaceAltitudeInM}) async {
    this.surfaceAltitudeInM = surfaceAltitudeInM;

    qnh = StandardAtmosphere.qnh(
        pressure: (await barometerEvents.asBroadcastStream().first).reading,
        altitude: surfaceAltitudeInM);
  }

  Stream<InstrumentsData> get data => _instrumentsDataStream.stream;

  LatLng get lastPosition => _lastPosition;

  void _sendData() {
    _instrumentsDataStream.add(InstrumentsData(
        position: _lastPosition,
        speedInKmH: _lastSpeedInKmH,
        altitudeInM: _lastAltitudeInM,
        heightInM: _lastHeightInM,
        headingInDeg: _lastHeadingInDeg,
        time: DateTime.now()));
  }

  void _onNewPosition(Position position) {
    this._lastPosition = LatLng(position.latitude, position.longitude);
    _lastSpeedInKmH = position.speed * 3.6;
    _lastHeadingInDeg = position.heading;

    _sendData();
  }

  void _onNewPressure(BarometerEvent event) {
    _lastAltitudeInM =
        StandardAtmosphere.altitude(qnh: qnh, pressure: event.reading);

    _lastHeightInM = _lastAltitudeInM - surfaceAltitudeInM;

    _sendData();
  }
}

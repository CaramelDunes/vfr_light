import 'dart:async';

import 'package:environment_sensors/environment_sensors.dart';
import 'package:geolocator/geolocator.dart';
import 'standard_atmosphere.dart';
import 'package:latlong2/latlong.dart';

class InstrumentsData {
  final LatLng position;
  final double headingInDeg;
  final DateTime time;
  final double speedInKmH;
  final double? altitudeInM;
  final double? heightInM;

  InstrumentsData(
      {required this.position,
      required this.headingInDeg,
      required this.time,
      required this.speedInKmH,
      required this.altitudeInM,
      required this.heightInM});
}

class InstrumentsDataSource {
  final LocationOptions locationOptions = LocationOptions();

  double qnh;
  double surfaceAltitudeInM;
  final StreamController<InstrumentsData> _instrumentsDataStream =
      StreamController.broadcast();

  late StreamSubscription _pressureSubscription;
  late StreamSubscription _positionSubscription;

  LatLng? _lastPosition;
  double? _lastSpeedInKmH;
  double? _lastAltitudeInM;
  double? _lastHeightInM;
  double? _lastHeadingInDeg;
  double? _lastPressure;

  InstrumentsDataSource({required this.qnh, required this.surfaceAltitudeInM}) {
    _positionSubscription =
        Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.high)
            .listen(_onNewPosition);

    _pressureSubscription = EnvironmentSensors()
        .pressure
        .asBroadcastStream()
        .listen(_onNewPressure);
  }

  void dispose() {
    _pressureSubscription.cancel();
    _positionSubscription.cancel();
  }

  Future<void> recalibrateAtSfc({required double surfaceAltitudeInM}) async {
    this.surfaceAltitudeInM = surfaceAltitudeInM;

    if (_lastPressure != null) {
      qnh = StandardAtmosphere.qnh(
          pressure: _lastPressure!, altitude: surfaceAltitudeInM);
    }
  }

  Stream<InstrumentsData> get data => _instrumentsDataStream.stream;

  LatLng? get lastPosition => _lastPosition;

  void _sendData() {
    _instrumentsDataStream.add(InstrumentsData(
        position: _lastPosition!,
        speedInKmH: _lastSpeedInKmH!,
        headingInDeg: _lastHeadingInDeg!,
        time: DateTime.now(),
        altitudeInM: _lastAltitudeInM,
        heightInM: _lastHeightInM));
  }

  void _onNewPosition(Position position) {
    _lastPosition = LatLng(position.latitude, position.longitude);
    _lastSpeedInKmH = position.speed * 3.6;
    _lastHeadingInDeg = position.heading;

    _sendData();
  }

  void _onNewPressure(double pressure) {
    _lastAltitudeInM =
        StandardAtmosphere.altitude(qnh: qnh, pressure: pressure);

    _lastHeightInM = _lastAltitudeInM! - surfaceAltitudeInM;
    _lastPressure = pressure;

    if (_lastPosition != null &&
        _lastSpeedInKmH != null &&
        _lastHeadingInDeg != null) {
      _sendData();
    }
  }
}

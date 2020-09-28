import 'dart:io';
import 'package:latlong/latlong.dart';

import 'package:vfr_light/instruments_data_source.dart';

class FlightRecorder {
  IOSink _outputSink;

  LatLng _lastPosition;

  FlightRecorder(File outputFile) {
    _outputSink = outputFile.openWrite();
    _outputSink.writeln(
        'longitude,latitude,altitudeInM,heightInM,speedInKmH,datetime');
  }

  void appendData(InstrumentsData data) {
    if (_lastPosition == null || _lastPosition != data.position) {
      _lastPosition = data.position;
      _outputSink.writeln(
          '${data.position.longitude},${data.position.latitude},${data.altitudeInM.round()},${data.heightInM.round()},${data.speedInKmH.round()},${data.time.toIso8601String()}');
    }
  }

  void dispose() {
    _outputSink.close();
  }
}

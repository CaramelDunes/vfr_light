import 'dart:async';

import 'package:meta/meta.dart';
import 'instruments_data_source.dart';

import 'package:latlong/latlong.dart';

class NavigationData {
  final double distanceInM;
  final Duration duration;
  final DateTime eta;

  NavigationData(
      {@required this.distanceInM,
      @required this.duration,
      @required this.eta});
}

class NavigationDataSource {
  final StreamController<NavigationData> _navigationDataStream =
      StreamController.broadcast();

  StreamSubscription _subscription;
  LatLng destination;

  NavigationDataSource(
      {@required this.destination, @required Stream<InstrumentsData> stream}) {
    _subscription = stream.listen(_onNewData);
  }

  void dispose() {
    _subscription.cancel();
  }

  Stream<NavigationData> get data => _navigationDataStream.stream;

  void _onNewData(InstrumentsData data) {
    double distanceInM;
    Duration duration;
    DateTime eta;

    if (data.position != null) {
      Distance d = Distance();
      distanceInM = d.distance(data.position, destination);

      if (data.speedInKmH != null && data.speedInKmH > 5) {
        duration = Duration(
            minutes: (distanceInM / 1000 / data.speedInKmH * 60).round());

        eta = DateTime.now().add(duration);
      }
    }

    _navigationDataStream.add(
        NavigationData(duration: duration, eta: eta, distanceInM: distanceInM));
  }
}

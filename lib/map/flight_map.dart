import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:nofussppg/instruments_data_source.dart';
import 'package:latlong/latlong.dart';
import '../preset_layers.dart';

class FlightMap extends StatefulWidget {
  final Stream<InstrumentsData> dataStream;
  final Polyline route;
  final LongPressCallback onLongPress;

  const FlightMap(
      {Key key,
      @required this.dataStream,
      @required this.onLongPress,
      this.route})
      : super(key: key);

  @override
  _FlightMapState createState() => _FlightMapState();
}

class _FlightMapState extends State<FlightMap> {
  bool _centerOnPosition = false;

  Marker _planeMarker;
  MapController _mapController = MapController();
  StreamSubscription<InstrumentsData> _dataSubscription;
  Polyline _headingPolyline;

  @override
  void initState() {
    super.initState();

    _dataSubscription = widget.dataStream.listen(_onInstrumentsData);
  }

  @override
  void dispose() {
    _dataSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        FlutterMap(
          options: MapOptions(
              center: LatLng(48.705463, 2.515869),
              zoom: 10.0,
              swPanBoundary: LatLng(41.327326, -5.734863),
              nePanBoundary: LatLng(51.138001, 9.382324),
              onLongPress: widget.onLongPress),
          layers: [
            TileLayerOptions(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c']),
           // PresetLayers.oaciVfrFrance,
            TileLayerOptions(
                opacity: 0.5,
                tileProvider: AssetTileProvider(),
                urlTemplate: "assets/offline_layers/oaci_vfr/{z}/{x}-{y}.jpg",
                minNativeZoom: 8,
                maxNativeZoom: 11),
            PolylineLayerOptions(polylines: [
              if (_headingPolyline != null) _headingPolyline,
              if (widget.route != null) widget.route
            ]),
            MarkerLayerOptions(markers: [
              if (_planeMarker != null) _planeMarker,
              ...widget.route.points
                  .asMap()
                  .entries
                  .map((e) => Marker(
                      point: e.value,
                      builder: (context) {
                        return Text(
                          (e.key + 1).toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        );
                      }))
                  .toList()
            ])
          ],
          mapController: _mapController,
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
                child: Icon(Icons.lock,
                    color: _centerOnPosition ? Colors.blue : Colors.black),
                backgroundColor: Colors.white,
                onPressed: () {
                  setState(() {
                    _centerOnPosition = !_centerOnPosition;
                  });
                }),
          ),
        )
      ],
    );
  }

  Polyline _headingLine(LatLng position, double headingInDeg) {
    final Distance distance = const Distance();

    return Polyline(
        points: [position, distance.offset(position, 30000, headingInDeg)],
        strokeWidth: 3.5,
        color: Colors.purpleAccent);
  }

  void _onInstrumentsData(InstrumentsData data) {
    if (_centerOnPosition) {
      _mapController.move(data.position, _mapController.zoom);
    }

    if (data.headingInDeg != null) {
      _headingPolyline = _headingLine(data.position, data.headingInDeg);

      _planeMarker = Marker(
          point: data.position,
          builder: (context) {
            return Transform.rotate(
                angle: data.headingInDeg * 2 * pi / 360,
                child: Icon(Icons.airplanemode_active,
                    color: Colors.purpleAccent));
          });

      setState(() {});
    }
  }
}

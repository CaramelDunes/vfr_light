import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';

class RouteEditor extends StatefulWidget {
  final List<LatLng> waypoints;

  const RouteEditor({Key key, this.waypoints}) : super(key: key);

  @override
  _RouteEditorState createState() => _RouteEditorState();
}

class _RouteEditorState extends State<RouteEditor> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Waypoints'),
      ),
      body: ReorderableListView(
        header: Text(
          'Total length: ${(_tripLengthInM() / 1000).toStringAsFixed(1)} km',
          style: Theme.of(context).textTheme.headline4,
        ),
        onReorder: (int oldIndex, int newIndex) {},
        children: _tiles(),
      ),
    );
  }

  double _tripLengthInM() {
    double length = 0;
    LatLng from;
    Distance d = Distance();

    widget.waypoints.forEach((waypoint) {
      if (from != null) {
        length += d.distance(from, waypoint);
      }

      from = waypoint;
    });

    return length;
  }

  List<double> _legDistancesInM() {
    List<double> distances = [0];
    LatLng from;
    Distance d = Distance();

    widget.waypoints.forEach((waypoint) {
      if (from != null) {
        distances.add(d.distance(from, waypoint));
      }

      from = waypoint;
    });

    return distances;
  }

  List<Widget> _tiles() {
    return widget.waypoints
        .asMap()
        .entries
        .map((e) => ListTile(
              key: ValueKey(e.value),
              title: Text(
                e.value.toSexagesimal(),
                style: TextStyle(fontSize: 12),
              ),
              subtitle: Text(
                  'From previous point: ${(_legDistancesInM()[e.key] / 1000).toStringAsFixed(1)} km'),
              leading: Text((e.key + 1).toString()),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () {},
                  ),
                  Icon(Icons.reorder)
                ],
              ),
            ))
        .toList();
  }
}

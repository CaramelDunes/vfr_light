import 'package:flutter/material.dart';

import 'navigation_data_source.dart';

class NavigationInfo extends StatelessWidget {
  static const TextStyle commonStyle =
      TextStyle(fontWeight: FontWeight.bold, fontSize: 30);

  final NavigationData data;

  const NavigationInfo({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Distance (km)',
                    style: Theme.of(context).textTheme.subtitle2),
                Text(
                    data.distanceInM != null
                        ? (data.distanceInM! / 1000).toStringAsFixed(1)
                        : '???',
                    style: commonStyle),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Duration', style: Theme.of(context).textTheme.subtitle2),
                Text(
                    data.duration != null
                        ? '${data.duration!.inHours}h${data.duration!.inMinutes % 60}'
                        : '???',
                    style: commonStyle),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('ETA', style: Theme.of(context).textTheme.subtitle2),
                Text(
                    data.eta != null
                        ? '${data.eta!.hour}:${data.eta!.minute}'
                        : '???',
                    style: commonStyle),
              ],
            ),
          ],
        ));
  }
}

import 'package:flutter/material.dart';

import 'instruments_data_source.dart';
import 'standard_atmosphere.dart';

class Instruments extends StatelessWidget {
  static const TextStyle commonStyle =
      TextStyle(fontWeight: FontWeight.bold, fontSize: 30);

  final InstrumentsData data;

  const Instruments({Key key, @required this.data}) : super(key: key);

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
                Text('Height (ft)',
                    style: Theme.of(context).textTheme.subtitle2),
                Text(
                    data.heightInM != null
                        ? StandardAtmosphere.feetFromMeters(data.heightInM)
                            .round()
                            .toString()
                        : '???',
                    style: commonStyle),
                Text('Height (m)',
                    style: Theme.of(context).textTheme.subtitle2),
                Text(
                    data.heightInM != null
                        ? data.heightInM.round().toString()
                        : '???',
                    style: commonStyle),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Altitude (ft)',
                    style: Theme.of(context).textTheme.subtitle2),
                Text(
                    data.altitudeInM != null
                        ? StandardAtmosphere.feetFromMeters(data.altitudeInM)
                            .round()
                            .toString()
                        : '???',
                    style: commonStyle),
                Text('Altitude (m)',
                    style: Theme.of(context).textTheme.subtitle2),
                Text(
                    data.altitudeInM != null
                        ? data.altitudeInM.round().toString()
                        : '???',
                    style: commonStyle),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Heading (°)',
                    style: Theme.of(context).textTheme.subtitle2),
                Text(
                    data.headingInDeg != null
                        ? data.headingInDeg.round().toString()
                        : '???',
                    style: commonStyle),
                Text('Speed (km/h)',
                    style: Theme.of(context).textTheme.subtitle2),
                Text(
                    data.speedInKmH != null
                        ? data.speedInKmH.round().toString()
                        : '???',
                    style: commonStyle),
              ],
            ),
          ],
        ));
  }
}

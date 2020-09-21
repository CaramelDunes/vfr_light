import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'flight_recorder.dart';
import 'instruments_data_source.dart';

class RecordButton extends StatefulWidget {
  final InstrumentsDataSource dataSource;

  const RecordButton({Key key, @required this.dataSource}) : super(key: key);

  @override
  _RecordButtonState createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton> {
  bool _isRecording = false;
  StreamSubscription<InstrumentsData> _recorderSubscription;
  FlightRecorder _flightRecorder;

  @override
  void dispose() {
    _isRecording = false;
    _recorderSubscription?.cancel();
    _flightRecorder?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isRecording ? Icons.stop : Icons.fiber_manual_record,
        color: _isRecording ? Colors.red : Colors.white,
      ),
      tooltip: 'Record Flight',
      onPressed: () {
        _toggleRecording();
      },
    );
  }

  void _toggleRecording() {
    if (_isRecording) {
      setState(() {
        _isRecording = false;
      });
      _recorderSubscription.cancel();
      _recorderSubscription = null;
      _flightRecorder.dispose();
      _flightRecorder = null;
    } else {
      getExternalStorageDirectory().then((value) {
        DateTime now = DateTime.now();
        String path =
            '${value.path}/${now.year}-${now.month}-${now.day}_${now.hour}-${now.minute}.csv';

        File outputFile = File(path);

        if (!outputFile.existsSync()) {
          _flightRecorder = FlightRecorder(outputFile);

          setState(() {
            _isRecording = true;
          });

          _recorderSubscription = widget.dataSource.data.listen((event) {
            _flightRecorder.appendData(event);
          });
        }
      });
    }
  }
}

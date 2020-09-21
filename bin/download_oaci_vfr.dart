import 'dart:io';

import 'package:http/http.dart' as http;

class UserAgentClient extends http.BaseClient {
  final String userAgent;
  final http.Client _inner;

  UserAgentClient(this.userAgent, this._inner);

  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['user-agent'] = userAgent;
    return _inner.send(request);
  }
}

Future<bool> downloadTile(http.Client client, int x, int y, int zoom) async {
  var path = 'tiles/$zoom/$y-$x.jpg';

  var file = File(path);

  if (!await file.exists()) {
    String url =
        'https://wxs.ign.fr/an7nvfzojv5wa96dsga5nk8w/geoportail/wmts?layer=GEOGRAPHICALGRIDSYSTEMS.MAPS.SCAN-OACI&style=normal&tilematrixset=PM&Service=WMTS&Request=GetTile&Version=1.0.0&Format=image/jpeg&TileMatrix=$zoom&TileCol=$y&TileRow=$x';

    print('$path dling');
    var r = await client.get(url);

    if (r.statusCode == 200) {
      print('$path 200');

      await file.writeAsBytes(r.bodyBytes);
      return Future.value(true);
    } else {
      print(url);
      return Future.value(false);
    }
  } else {
    // print('tiles/$y-$x.jpg exists');
    return Future.value(true);
  }
}

Future dl11() async {
  String ua =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:78.0) Gecko/20100101 Firefox/78.0';

  var cl = UserAgentClient(ua, http.Client());

  List<Future> toWait = [];

  for (int x = 684; x < 770; x++) {
    for (int y = 993; y < 1080; y++) {
      await downloadTile(cl, x, y, 11);
    }
  }

  await Future.wait(toWait);

  cl.close();
}

Future dl8() async {
  String ua =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:78.0) Gecko/20100101 Firefox/78.0';

  var cl = UserAgentClient(ua, http.Client());

  for (int x = 85; x < 97; x++) {
    for (int y = 123; y < 137; y++) {
      await downloadTile(cl, x, y, 8);
    }
  }

  cl.close();
}

Future dl10() async {
  String ua =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:78.0) Gecko/20100101 Firefox/78.0';

  var cl = UserAgentClient(ua, http.Client());

  for (int x = 340; x < 387; x++) {
    for (int y = 494; y < 545; y++) {
      await downloadTile(cl, x, y, 10);
    }
  }

  cl.close();
}

Future dl9() async {
  String ua =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:78.0) Gecko/20100101 Firefox/78.0';

  var cl = UserAgentClient(ua, http.Client());

  for (int x = 170; x < 194; x++) {
    for (int y = 247; y < 273; y++) {
      await downloadTile(cl, x, y, 9);
    }
  }

  cl.close();
}

Future main(List<String> arguments) async {
  await dl10();
  return 0;
}

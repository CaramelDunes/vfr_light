import 'dart:io';

import 'package:http/http.dart' as http;

class UserAgentClient extends http.BaseClient {
  static final String firefoxUserAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:103.0) Gecko/20100101 Firefox/103.0';

  final String userAgent;
  final http.Client _inner;

  UserAgentClient(this.userAgent, this._inner);

  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['user-agent'] = userAgent;
    return _inner.send(request);
  }
}

Future<bool> downloadTile(http.Client client, int x, int y, int zoom) async {
  var directory = Directory('assets/offline_layers/oaci_vfr/$zoom/');
  directory.createSync(recursive: true);

  var file = File(directory.path + '/$y-$x.jpg');

  if (!await file.exists()) {
    String url =
        'https://wxs.ign.fr/an7nvfzojv5wa96dsga5nk8w/geoportail/wmts?layer=GEOGRAPHICALGRIDSYSTEMS.MAPS.SCAN-OACI&style=normal&tilematrixset=PM&Service=WMTS&Request=GetTile&Version=1.0.0&Format=image/jpeg&TileMatrix=$zoom&TileCol=$y&TileRow=$x';
    var response = await client.get(Uri.parse(url));

    if (response.statusCode == 200) {
      print('Downloaded $zoom/$x-$y.');

      await file.writeAsBytes(response.bodyBytes);
      return true;
    } else {
      print('Error downloading $zoom/$x-$y: HTTP ${response.statusCode}.');
      return false;
    }
  } else {
    return true;
  }
}

Future downloadLayer(http.Client client, int zoomLevel, int fromX, int toX,
    int fromY, int toY) async {
  for (int x = fromX; x < toX; x++) {
    for (int y = fromY; y < toY; y++) {
      await downloadTile(client, x, y, zoomLevel);
    }
  }
}

Future<int> main(List<String> arguments) async {
  http.Client innerClient = http.Client();
  UserAgentClient client =
      UserAgentClient(UserAgentClient.firefoxUserAgent, innerClient);

  await downloadLayer(client, 8, 85, 97, 123, 137);
  await downloadLayer(client, 9, 170, 194, 247, 273);
  await downloadLayer(client, 10, 340, 387, 494, 545);
  await downloadLayer(client, 11, 684, 770, 993, 1080);

  innerClient.close();

  return 0;
}

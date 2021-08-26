import 'package:flutter_map/flutter_map.dart';

import 'package:vfr_light/user_agent_tile_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path/path.dart' as p;

//
// class LongTermCacheManager extends BaseCacheManager {
//   static const key = 'libCachedImageDataLongTerm';
//
//   static LongTermCacheManager _instance;
//
//   factory LongTermCacheManager() {
//     _instance ??= LongTermCacheManager._();
//     return _instance;
//   }
//
//   LongTermCacheManager._() : super(key, maxNrOfCacheObjects: 10000);
//
//   @override
//   Future<String> getFilePath() async {
//     var directory = (await getExternalCacheDirectories())[0];
//     return p.join(directory.path, key);
//   }
// }

class PresetLayers {
  static TileLayerOptions oaciVfrFrance = TileLayerOptions(
      opacity: 0.5,
      urlTemplate:
          "https://wxs.ign.fr/an7nvfzojv5wa96dsga5nk8w/geoportail/wmts?layer=GEOGRAPHICALGRIDSYSTEMS.MAPS.SCAN-OACI&style=normal&tilematrixset=PM&Service=WMTS&Request=GetTile&Version=1.0.0&Format=image%2Fjpeg&TileMatrix={z}&TileCol={x}&TileRow={y}",
      tileProvider: UserAgentTileProvider(),
      minNativeZoom: 8,
      maxNativeZoom: 11);
}

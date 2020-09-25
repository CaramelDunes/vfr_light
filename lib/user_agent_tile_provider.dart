import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vfr_essentials/preset_layers.dart';

export 'package:flutter_map/src/layer/tile_provider/mbtiles_image_provider.dart';

class UserAgentTileProvider extends TileProvider {
  @override
  ImageProvider<Object> getImage(Coords<num> coords, TileLayerOptions options) {
    return CachedNetworkImageProvider(getTileUrl(coords, options),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:78.0) Gecko/20100101 Firefox/78.0'
        },
        cacheManager: LongTermCacheManager());
  }
}

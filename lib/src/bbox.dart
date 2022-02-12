import 'package:turf/coord_each.dart';
import 'package:turf/helpers.dart';

BBox bbox(GeoJSONObject geoJson) {
  var result = [double.infinity, double.infinity, double.negativeInfinity, double.negativeInfinity];

  coordEach(geoJson, (Position coord, _, __, ___, ____) {
    print(coord);
    if (result[0] > coord.lat) {
      result[0] = coord.lat.toDouble();
    }
    if (result[1] > coord.lng.toDouble()) {
      result[1] = coord.lng.toDouble();
    }
    if (result[2] < coord.lat) {
      result[2] = coord.lat.toDouble();
    }
    if (result[3] < coord.lng) {
      result[3] = coord.lng.toDouble();
    }
  });

  return BBox(result[0], result[1], result[2], result[3]);
}

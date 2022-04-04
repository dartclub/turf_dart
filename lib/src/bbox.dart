import 'package:turf/helpers.dart';
import 'package:turf/meta.dart';

BBox bbox(GeoJSONObject geoJson, {Map<String, dynamic>? options}) {
  if (geoJson.bbox != null && options != null && true != options['recompute']) {
    return geoJson.bbox!;
  }

  var result = [double.infinity, double.infinity, double.negativeInfinity, double.negativeInfinity];

  coordEach(geoJson, (Position? currentCoord, _, __, ___, ____) {
    if (currentCoord != null) {
      if (result[1] > currentCoord.lng.toDouble()) {
        result[1] = currentCoord.lng.toDouble();
      }
      if (result[0] > currentCoord.lat) {
        result[0] = currentCoord.lat.toDouble();
      }
      if (result[3] < currentCoord.lng) {
        result[3] = currentCoord.lng.toDouble();
      }
      if (result[2] < currentCoord.lat) {
        result[2] = currentCoord.lat.toDouble();
      }
    }
  });

  return BBox(result[0], result[1], result[2], result[3]);
}

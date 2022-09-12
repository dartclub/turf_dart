import 'package:turf/helpers.dart';
import 'package:turf/meta.dart';

/// Calculates the bounding box for any [geoJson] object, including [FeatureCollection].
/// If [recompute] is not set and the [bbox] is not null, the function uses the [bbox] of the given [GeoJSONObject].
BBox bbox(GeoJSONObject geoJson, {bool recompute = false}) {
  if (geoJson.bbox != null && !recompute) {
    return geoJson.bbox!;
  }

  var result = BBox.named(
    // min x & y
    lng1: double.infinity,
    lat1: double.infinity,
    // max x & y
    lng2: double.negativeInfinity,
    lat2: double.negativeInfinity,
  );

  coordEach(
    geoJson,
    (Position? currentCoord, _, __, ___, ____) {
      if (currentCoord != null) {
        if (result.lng1 > currentCoord.lng) {
          result = result.copyWith(lng1: currentCoord.lng);
        }
        if (result.lat1 > currentCoord.lat) {
          result = result.copyWith(lat1: currentCoord.lat);
        }
        if (result.lng2 < currentCoord.lng) {
          result = result.copyWith(lng2: currentCoord.lng);
        }
        if (result.lat2 < currentCoord.lat) {
          result = result.copyWith(lat2: currentCoord.lat);
        }
      }
    },
  );

  return result;
}

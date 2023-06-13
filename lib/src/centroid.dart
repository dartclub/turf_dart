import 'package:turf/helpers.dart';
import 'package:turf/meta.dart';

/// Takes a [Feature] or a [FeatureCollection] and computes the centroid as the mean of all vertices within the object.
///
/// example:
/// ```dart
/// final line = Feature<LineString>(geometry: LineString(coordinates: [Position(0, 0), Position(1, 1)]));
///
/// final pt = centroid(line);
/// ```
Feature<Point> centroid(
  GeoJSONObject geoJSON, {
  Map<String, dynamic>? properties,
}) {
  num xSum = 0;
  num ySum = 0;
  int len = 0;

  coordEach(geoJSON, (coords, _, __, ___, ____) {
    if (coords != null) {
      xSum += coords[0]!;
      ySum += coords[1]!;
      len++;
    }
  }, true);

  return Feature<Point>(
    geometry: Point(
      coordinates: Position(xSum / len, ySum / len),
    ),
    properties: properties,
  );
}

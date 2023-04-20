import 'package:turf/bearing.dart';
import 'package:turf/distance.dart';
import 'package:turf/src/centroid.dart';
import 'package:turf/src/meta/coord.dart';
import 'package:turf/src/rhumb_destination.dart';

import '../helpers.dart';
import 'invariant.dart';

/// Rotates any [GeoJSONObject] of a specified angle, around its `centroid` or a given `pivot` [Point].
///
/// example:
/// ```dart
/// final line = Feature<LineString>(geometry: LineString.fromJson({'coordinates': [[10, 10],[12, 15]]}));
/// final rotated = transformRotate(line, 100);
/// ```

GeoJSONObject transformRotate(
  GeoJSONObject geoJSON,
  num angle, {
  Point? pivot,
  bool mutate = false,
}) {
  if (angle == 0) {
    return geoJSON;
  }

  // Use centroid of GeoJSON if pivot is not provided
  pivot ??= centroid(geoJSON).geometry!;

  // Clone geojson to avoid side effects
  if (mutate == false) geoJSON = geoJSON.clone();

  // Rotate each coordinate
  coordEach(geoJSON, (pointCoords, _, __, ___, ____) {
    final currentPoint = Point(coordinates: pointCoords!);
    final initialAngle = rhumbBearing(pivot!, currentPoint);
    final finalAngle = initialAngle + angle;
    final distance = rhumbDistance(pivot, currentPoint);
    final newCoords = getCoord(rhumbDestination(pivot, distance, finalAngle));
    pointCoords[0] = newCoords[0]!;
    pointCoords[1] = newCoords[1]!;
  });

  return geoJSON;
}

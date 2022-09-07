import 'package:sweepline_intersections/sweepline_intersections.dart';

import '../helpers.dart';

/// Takes any [LineString] or [Polygon] and returns the intersecting [Point](s).
/// [removeDuplicates=true] removes duplicate intersections,
/// [ignoreSelfIntersections=false] ignores self-intersections on input features
/// Returns a [FeatureCollection<Point>] containing point(s) that intersect both
/// example:
/// ```dart
/// var line1 = LineString(coordinates:[
///    Position.of([126, -11]),
///    Position.of([129, -21]),
///  ]);
/// var line2 = LineString(coordinates:[
///  Position.of([123, -18]),
///  Position.of([131, -14]),
///  ]);
/// var intersects = lineIntersect(line1, line2);
/// //addToMap
/// var addToMap = [line1, line2, intersects]
FeatureCollection<Point> lineIntersect(GeoJSONObject line1, GeoJSONObject line2,
    {bool removeDuplicates = true, bool ignoreSelfIntersections = false}) {
  var features = <Feature>[];
  if (line1 is FeatureCollection) {
    features.addAll(line1.features);
  } else if (line1 is Feature) {
    features.add(line1);
  } else if (line1 is LineString ||
      line1 is Polygon ||
      line1 is MultiLineString ||
      line1 is MultiPolygon) {
    features.add(Feature(geometry: line1 as GeometryType));
  }

  if (line2 is FeatureCollection) {
    features.addAll(line2.features);
  } else if (line2 is Feature) {
    features.add(line2);
  } else if (line2 is LineString ||
      line2 is Polygon ||
      line2 is MultiLineString ||
      line2 is MultiPolygon) {
    features.add(Feature(geometry: line2 as GeometryType));
  }

  var intersections = sweeplineIntersections(
      FeatureCollection(features: features), ignoreSelfIntersections);

  var results = [];
  if (removeDuplicates) {
    Set unique = {};
    for (var intersection in intersections) {
      if (!unique.contains(intersection)) {
        unique.add(intersection);
        results.add(intersection);
      }
    }
  } else {
    results = intersections;
  }
  return FeatureCollection(
      features: results
          .map((r) => Feature(geometry: Point(coordinates: r)))
          .toList());
}

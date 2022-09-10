import 'package:rbush/rbush.dart';
import 'package:turf/bbox.dart';
import 'package:turf/helpers.dart';
import 'package:turf/line_segment.dart';
import 'package:turf/nearest_point_on_line.dart';
import 'package:turf/src/booleans/boolean_point_on_line.dart';
import 'package:turf/src/invariant.dart';
import 'package:turf/src/meta/feature.dart';
import 'package:turf_equality/turf_equality.dart';

/// Takes any [LineString] or [Polygon] and returns the overlapping [LineString]s
/// between both [Feature]s. [line1] is a [Feature]<[LineString]|[MultiLineString]
/// |[Polygon]|[MultiPolygon]> or any [LineString] or [Polygon], [line2] is a
/// [Feature]<[LineString]|[MultiLineString]|[Polygon]|[MultiPolygon]> or any
/// [LineString] or [Polygon]. [tolerance=0] Tolerance distance to match
/// overlapping line segments (in kilometers) returns a [FeatureCollection]<[LineString]>
/// lines(s) that are overlapping between both [Feature]s.
/// example
/// ```dart
/// var line1 = LineString(
///   coordinates: [
///     Position.of([115, -35]),
///     Position.of([125, -30]),
///     Position.of([135, -30]),
///     Position.of([145, -35])
///   ],
/// );
/// var line2 = LineString(
///   coordinates: [
///     Position.of([115, -25]),
///     Position.of([125, -30]),
///     Position.of([135, -30]),
///     Position.of([145, -25])
///   ],
/// );
/// var overlapping = lineOverlap(line1, line2);
/// //addToMap
/// var addToMap = [line1, line2, overlapping]
///```
FeatureCollection<LineString> lineOverlap(
    GeoJSONObject line1, GeoJSONObject line2,
    {num tolerance = 0}) {
  RBushBox _toRBBox(Feature<LineString> feature) {
    var bb = bbox(feature);
    return RBushBox(
        minX: bb.lng1.toDouble(),
        minY: bb.lat1.toDouble(),
        maxX: bb.lng2.toDouble(),
        maxY: bb.lat2.toDouble());
  }
  // Optional parameters

  // Containers
  var features = <Feature<LineString>>[];

  // Create Spatial Index
  var tree = RBushBase<Feature<LineString>>(
      getMinY: (Feature<LineString> feature) => bbox(feature).lat1.toDouble(),
      getMinX: (Feature<LineString> feature) => bbox(feature).lng1.toDouble(),
      toBBox: (feature) => _toRBBox(feature));

  var line = lineSegment(line1);
  tree.load(line.features);
  Feature<LineString>? overlapSegment;
  var additionalSegments = <Feature<LineString>>[];

  // Line Intersection

  // Iterate over line segments
  segmentEach(line2, (Feature<LineString> currentSegment, int featureIndex,
      int? multiFeatureIndex, int? geometryIndex, int segmentIndex) {
    var doesOverlaps = false;

    // Iterate over each segments which falls within the same bounds
    featureEach(
        FeatureCollection<LineString>(
            features: tree.search(_toRBBox(currentSegment))), (match, index) {
      if (!doesOverlaps) {
        List<Position> coordsSegment = () {
          List<Position> list = getCoords(currentSegment) as List<Position>;
          list.sort();
          return list;
        }();
        List<Position> coordsMatch = () {
          List<Position> list = getCoords(match) as List<Position>;
          list.sort();
          return list;
        }();

        Equality eq = Equality();
        // Segment overlaps feature - with dummy LineStrings just to use eq.
        if (eq.compare(LineString(coordinates: coordsSegment),
            LineString(coordinates: coordsMatch))) {
          doesOverlaps = true;
          // Overlaps already exists - only append last coordinate of segment
          if (overlapSegment != null) {
            overlapSegment = concatSegment(overlapSegment!, currentSegment) ??
                overlapSegment;
          } else {
            overlapSegment = currentSegment;
          }
          // Match segments which don't share nodes (Issue #901)
        } else if (tolerance == 0
            ? booleanPointOnLine(Point(coordinates: coordsSegment[0]),
                    match.geometry as LineString) &&
                booleanPointOnLine(Point(coordinates: coordsSegment[1]),
                    match.geometry as LineString)
            : nearestPointOnLine(match.geometry as LineString,
                            Point(coordinates: coordsSegment[0]))
                        .properties!['dist'] <=
                    tolerance &&
                nearestPointOnLine(match.geometry as LineString,
                            Point(coordinates: coordsSegment[1]))
                        .properties!['dist'] <=
                    tolerance) {
          doesOverlaps = true;
          if (overlapSegment != null) {
            overlapSegment = concatSegment(overlapSegment!, currentSegment) ??
                overlapSegment;
          } else {
            overlapSegment = currentSegment;
          }
        } else if (tolerance == 0
            ? booleanPointOnLine(Point(coordinates: coordsMatch[0]),
                    currentSegment.geometry as LineString) &&
                booleanPointOnLine(Point(coordinates: coordsMatch[1]),
                    currentSegment.geometry as LineString)
            : nearestPointOnLine(currentSegment.geometry as LineString,
                            Point(coordinates: coordsMatch[0]))
                        .properties!['dist'] <=
                    tolerance &&
                nearestPointOnLine(currentSegment.geometry as LineString,
                            Point(coordinates: coordsMatch[1]))
                        .properties!['dist'] <=
                    tolerance) {
          // Do not define doesOverlap = true since more matches can occur
          // within the same segment
          // doesOverlaps = true;
          if (overlapSegment != null) {
            var combinedSegment =
                concatSegment(overlapSegment!, match as Feature<LineString>);
            if (combinedSegment != null) {
              overlapSegment = combinedSegment;
            } else {
              additionalSegments.add(match);
            }
          } else {
            overlapSegment = match as Feature<LineString>;
          }
        }
      }
    });

    // Segment doesn't overlap - add overlaps to results & reset
    if (doesOverlaps == false && overlapSegment != null) {
      features.add(overlapSegment!);
      if (additionalSegments.isNotEmpty) {
        features = [...features, ...additionalSegments];
        additionalSegments = [];
      }
      overlapSegment = null;
    }
  });
  // Add last segment if exists
  if (overlapSegment != null) features.add(overlapSegment!);

  return FeatureCollection(features: features);
}

Feature<LineString>? concatSegment(
    Feature<LineString> line, Feature<LineString> segment) {
  var newLine = line.clone();
  var coords = getCoords(segment);
  var lineCoords = getCoords(newLine);
  var start = lineCoords[0];
  var end = lineCoords[lineCoords.length - 1];
  List<Position> geom = (newLine.geometry as LineString).coordinates;

  if (coords[0] == start) {
    geom.insert(0, coords[1]);
  } else if (coords[0] == end) {
    geom.add(coords[1]);
  } else if (coords[1] == start) {
    geom.insert(0, coords[0]);
  } else if (coords[1] == end) {
    geom.add(coords[0]);
  } else {
    return null;
  } // If the overlap leaves the segment unchanged, return null so that this can be
  // identified.

  // Otherwise return the mutated line.
  return newLine;
}

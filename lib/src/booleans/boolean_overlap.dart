import 'package:turf/helpers.dart';
import 'package:turf/line_segment.dart';
import 'package:turf/src/invariant.dart';
import 'package:turf/src/line_intersect.dart';
import 'package:turf/src/line_overlap.dart';
import 'package:turf_equality/turf_equality.dart';

/// Compares two geometries of the same dimension and returns [true] if their
/// intersection Set results in a geometry different from both but of the same
/// dimension. It applies to [Polygon]/[Polygon], [LineString]/[LineString], [MultiPoint]/
/// [MultiPoint], [MultiLineString]/[MultiLineString] and [MultiPolygon]/[MultiPolygon].
/// In other words, it returns [true] if the two geometries overlap, provided that
/// neither completely contains the other.
/// Takes [feature1] and [feature2] which could be [Feature]<[LineString]|
/// [MultiLineString]|[Polygon]|[MultiPolygon]>
/// example
/// ```dart
/// var poly1 = Polygon(
///   coordinates: [
///     [
///       Position.of([0, 0]),
///       Position.of([0, 5]),
///       Position.of([5, 5]),
///       Position.of([5, 0]),
///       Position.of([0, 0])
///     ]
///   ],
/// );
/// var poly2 = Polygon(
///   coordinates: [
///     [
///       Position.of([1, 1]),
///       Position.of([1, 6]),
///       Position.of([6, 6]),
///       Position.of([6, 1]),
///       Position.of([1, 1])
///     ]
///   ],
/// );
/// var poly3 = Polygon(
///   coordinates: [
///     [
///       Position.of([10, 10]),
///       Position.of([10, 15]),
///       Position.of([15, 15]),
///       Position.of([15, 10]),
///       Position.of([10, 10])
///     ]
///   ],
/// );
/// booleanOverlap(poly1, poly2);
/// //=true
/// booleanOverlap(poly2, poly3);
/// //=false
/// ```
bool booleanOverlap(GeoJSONObject feature1, GeoJSONObject feature2) {
  var geom1 = getGeom(feature1);
  var geom2 = getGeom(feature2);

  if ((feature1 is MultiPoint && feature2 is! MultiPoint) ||
      ((feature1 is LineString || feature1 is MultiLineString) &&
          feature2 is! LineString &&
          feature2 is! MultiLineString) ||
      ((feature1 is Polygon || feature1 is MultiPolygon) &&
          feature2 is! Polygon &&
          feature2 is! MultiPolygon)) {
    throw Exception("features must be of the same type");
  }
  if (feature1 is Point) throw Exception("Point geometry not supported");

  // features must be not equal
  var equality = Equality(precision: 6);
  if (equality.compare(feature1, feature2)) {
    return false;
  }

  var overlap = 0;

  if (geom1 is MultiPoint) {
    for (var i = 0; i < geom1.coordinates.length; i++) {
      for (var j = 0; j < (geom2 as MultiPoint).coordinates.length; j++) {
        if (geom1.coordinates[i] == geom2.coordinates[j]) {
          return true;
        }
      }
    }
    return false;
  } else if (feature1 is MultiLineString) {
    segmentEach(
      feature1,
      (
        Feature<LineString> currentSegment,
        int featureIndex,
        int? multiFeatureIndex,
        int? geometryIndex,
        int segmentIndex,
      ) {
        segmentEach(
          feature2,
          (
            Feature<LineString> currentSegment1,
            int featureIndex,
            int? multiFeatureIndex,
            int? geometryIndex,
            int segmentIndex,
          ) {
            if (lineOverlap(currentSegment, currentSegment1)
                .features
                .isNotEmpty) {
              overlap++;
            }
          },
        );
      },
    );
  } else if (feature1 is Polygon || feature1 is MultiPolygon) {
    segmentEach(
      feature1,
      (
        Feature<LineString> currentSegment,
        int featureIndex,
        int? multiFeatureIndex,
        int? geometryIndex,
        int segmentIndex,
      ) {
        segmentEach(
          feature2,
          (
            Feature<LineString> currentSegment1,
            int featureIndex,
            int? multiFeatureIndex,
            int? geometryIndex,
            int segmentIndex,
          ) {
            if (lineIntersect(currentSegment, currentSegment1)
                .features
                .isNotEmpty) {
              overlap++;
            }
          },
        );
      },
    );
  }

  return overlap > 0;
}

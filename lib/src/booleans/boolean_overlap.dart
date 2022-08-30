import 'package:turf/helpers.dart';
import 'package:turf/line_segment.dart';
import 'package:turf/src/line_intersect.dart';
import 'package:turf/src/line_overlap.dart';
import 'package:turf_equality/turf_equality.dart';

/// Compares two geometries of the same dimension and returns true if their intersection set results in a geometry
/// different from both but of the same dimension. It applies to Polygon/Polygon, LineString/LineString,
/// Multipoint/Multipoint, MultiLineString/MultiLineString and MultiPolygon/MultiPolygon.
///
/// In other words, it returns true if the two geometries overlap, provided that neither completely contains the other.
///
/// @name booleanOverlap
/// @param  {Geometry|Feature<LineString|MultiLineString|Polygon|MultiPolygon>} feature1 input
/// @param  {Geometry|Feature<LineString|MultiLineString|Polygon|MultiPolygon>} feature2 input
/// @returns {boolean} true/false
/// @example
/// var poly1 = turf.polygon([[[0,0],[0,5],[5,5],[5,0],[0,0]]]);
/// var poly2 = turf.polygon([[[1,1],[1,6],[6,6],[6,1],[1,1]]]);
/// var poly3 = turf.polygon([[[10,10],[10,15],[15,15],[15,10],[10,10]]]);
///
/// turf.booleanOverlap(poly1, poly2)
/// //=true
/// turf.booleanOverlap(poly2, poly3)
/// //=false
bool booleanOverlap(GeoJSONObject feature1, GeoJSONObject feature2) {
  var geom1 = feature1 is Feature ? feature1.geometry : feature1;
  var geom2 = feature2 is Feature ? feature2.geometry : feature2;

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
  if (equality.compare(feature1, feature2)) return false;

  var overlap = 0;

  if (feature1 is MultiPoint) {
    for (var i = 0; i < (geom1 as MultiPoint).coordinates.length; i++) {
      for (var j = 0; j < (geom2 as MultiPoint).coordinates.length; j++) {
        var coord1 = geom1.coordinates[i];
        var coord2 = geom2.coordinates[j];
        if (coord1[0] == coord2[0] && coord1[1] == coord2[1]) {
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
            if (lineOverlap(line1: currentSegment, line2: currentSegment1)
                .features
                .length) overlap++;
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

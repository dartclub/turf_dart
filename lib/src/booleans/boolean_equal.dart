import 'package:turf_equality/turf_equality.dart';

import '../../helpers.dart';
import '../clean_coords.dart';

/// Determine whether two geometries of the same type have identical X,Y coordinate values.
/// See http://edndoc.esri.com/arcsde/9.0/general_topics/understand_spatial_relations.htm
/// [precision]=6 sets decimal precision to use when comparing coordinates.
/// With [direction] set to [true], even if the [LineString]s are reverse versions
/// of each other but they have similar [Position]s, they will be considered the
/// same. If [shiftedPolygon] is [true], two [Polygon]s with shifted [Position]s
/// are considered the same.
/// Returns [true] if the objects are equal, [false] otherwise
/// example:
/// ```dart
/// var pt1 = Point(coordinates: Position.of([0, 0]));
/// var pt2 = Point(coordinates: Position.of([0, 0]));
/// var pt3 = Point(coordinates: Position.of([1, 1]));
/// booleanEqual(pt1, pt2);
/// //= true
/// booleanEqual(pt2, pt3);
/// //= false
/// ```
bool booleanEqual(
  GeoJSONObject feature1,
  GeoJSONObject feature2, {
  int precision = 6,
  bool direction = false,
  bool shiftedPolygon = false,
}) {
  if (precision < 0 || precision > 17) {
    throw Exception("precision must be a positive number and smaller than 15");
  }

  var equality = Equality(
    precision: precision,
    shiftedPolygons: shiftedPolygon,
    reversedGeometries: direction,
  );
  return equality.compare(cleanCoords(feature1), cleanCoords(feature2));
}

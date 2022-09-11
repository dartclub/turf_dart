import '../../helpers.dart';
import '../../meta.dart';
import 'boolean_disjoint.dart';

/// Returns [true] when two geometries intersect.
/// Takes [feature1] & [feature2] parameters of type [GeoJSONObject] which can be
/// a [Feature] or [GeometryType].
/// example
/// ```dart
/// var point = Point(coordinates:Position.of([2, 2]));
/// var line = LineString(coordinates:[Position.of([1, 1]), Position.of([1, 2]), Position.of([1, 3]), Position.of([1, 4]]));
/// booleanIntersects(line, point);
/// //=true
/// ```
bool booleanIntersects(GeoJSONObject feature1, GeoJSONObject feature2) {
  var result = false;
  flattenEach(
    feature1,
    (flatten1, featureIndex, multiFeatureIndex) {
      flattenEach(
        feature2,
        (flatten2, featureIndex, multiFeatureIndex) {
          if (result) {
            return true;
          }
          result = !booleanDisjoint(flatten1, flatten2);
        },
      );
    },
  );
  return result;
}

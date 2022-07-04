import 'package:turf/helpers.dart';

/// Takes a [Polygon] and returns true or false as to whether it is concave or not.
/// example:
/// ```dart
/// var convexPolygon = Polygon(coordinates: [
///   [
///     Position.of([0, 0]),
///     Position.of([0, 1]),
///     Position.of([1, 1]),
///     Position.of([1, 0]),
///     Position.of([0, 0])
///   ]
/// ]);
/// booleanConcave(convexPolygon)
/// //=false
/// ```
bool booleanConcave(Polygon polygon) {
  // Taken from https://stackoverflow.com/a/1881201 & https://stackoverflow.com/a/25304159
  List<List<Position>> coords = polygon.coordinates;

  if (coords[0].length <= 4) {
    return false;
  }

  var sign = false;
  var n = coords[0].length - 1;
  for (var i = 0; i < n; i++) {
    var dx1 = coords[0][(i + 2) % n][0]! - coords[0][(i + 1) % n][0]!;
    var dy1 = coords[0][(i + 2) % n][1]! - coords[0][(i + 1) % n][1]!;
    var dx2 = coords[0][i][0]! - coords[0][(i + 1) % n][0]!;
    var dy2 = coords[0][i][1]! - coords[0][(i + 1) % n][1]!;
    var zcrossproduct = dx1 * dy2 - dy1 * dx2;
    if (i == 0) {
      sign = zcrossproduct > 0;
    } else if (sign != zcrossproduct > 0) {
      return true;
    }
  }
  return false;
}

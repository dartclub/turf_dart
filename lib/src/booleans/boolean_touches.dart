import '../../helpers.dart';
import 'boolean_point_in_polygon.dart';
import 'boolean_point_on_line.dart';

/// Boolean-touches [true] if none of the [Point]s common to both geometries
/// intersect the interiors of both geometries.
/// example
/// ```dart
/// var line = LineString(coordinates;[Positin.of([1, 1]), Positin.of([1, 2]), Positin.of([1, 3]), Positin.of([1, 4])]);
/// var point = Point(coordinates: Positon.of([1, 1]));
/// booleanTouches(point, line);
/// //=true
bool booleanTouches(GeoJSONObject feature1, GeoJSONObject feature2) {
  var geom1 = feature1 is Feature ? feature1.geometry : feature1;
  var geom2 = feature2 is Feature ? feature2.geometry : feature2;

  if (geom1 is Point) {
    if (geom2 is LineString) {
      return isPointOnLineEnd(geom1, geom2);
    } else if (geom2 is MultiLineString) {
      var foundTouchingPoint = false;
      for (var ii = 0; ii < geom2.coordinates.length; ii++) {
        if (isPointOnLineEnd(
          geom1,
          LineString(
            coordinates: geom2.coordinates[ii],
          ),
        )) {
          foundTouchingPoint = true;
        }
      }
      return foundTouchingPoint;
    } else if (geom2 is Polygon) {
      for (var i = 0; i < geom2.coordinates.length; i++) {
        if (booleanPointOnLine(
          geom1,
          LineString(
            coordinates: geom2.coordinates[i],
          ),
        )) {
          return true;
        }
      }
      return false;
    } else if (geom2 is MultiPolygon) {
      for (var i = 0; i < geom2.coordinates.length; i++) {
        for (var ii = 0; ii < geom2.coordinates[i].length; ii++) {
          if (booleanPointOnLine(
            geom1,
            LineString(
              coordinates: geom2.coordinates[i][ii],
            ),
          )) {
            return true;
          }
        }
      }
      return false;
    } else {
      throw Exception("feature2 $geom2 geometry not supported");
    }
  } else if (geom1 is MultiPoint) {
    if (geom2 is LineString) {
      var foundTouchingPoint = false;
      for (var i = 0; i < geom1.coordinates.length; i++) {
        if (!foundTouchingPoint) {
          if (isPointOnLineEnd(
              Point(coordinates: geom1.coordinates[i]), geom2)) {
            foundTouchingPoint = true;
          }
        }
        if (booleanPointOnLine(Point(coordinates: geom1.coordinates[i]), geom2,
            ignoreEndVertices: true)) return false;
      }
      return foundTouchingPoint;
    } else if (geom2 is MultiLineString) {
      var foundTouchingPoint = false;
      for (var i = 0; i < geom1.coordinates.length; i++) {
        for (var ii = 0; ii < geom2.coordinates.length; ii++) {
          if (!foundTouchingPoint) {
            if (isPointOnLineEnd(Point(coordinates: geom1.coordinates[i]),
                LineString(coordinates: geom2.coordinates[ii]))) {
              foundTouchingPoint = true;
            }
          }
          if (booleanPointOnLine(Point(coordinates: geom1.coordinates[i]),
              LineString(coordinates: geom2.coordinates[ii]),
              ignoreEndVertices: true)) {
            return false;
          }
        }
      }
      return foundTouchingPoint;
    } else if (geom2 is Polygon) {
      var foundTouchingPoint = false;
      for (var i = 0; i < geom1.coordinates.length; i++) {
        if (!foundTouchingPoint) {
          if (booleanPointOnLine(
            Point(coordinates: geom1.coordinates[i]),
            LineString(coordinates: geom2.coordinates[0]),
          )) {
            foundTouchingPoint = true;
          }
        }
        if (booleanPointInPolygon(geom1.coordinates[i], geom2,
            ignoreBoundary: true)) {
          return false;
        }
      }
      return foundTouchingPoint;
    } else if (geom2 is MultiPolygon) {
      var foundTouchingPoint = false;
      for (var i = 0; i < geom1.coordinates.length; i++) {
        for (var ii = 0; ii < geom2.coordinates.length; ii++) {
          if (!foundTouchingPoint) {
            if (booleanPointOnLine(
              Point(coordinates: geom1.coordinates[i]),
              LineString(
                coordinates: geom2.coordinates[ii][0],
              ),
            )) {
              foundTouchingPoint = true;
            }
          }
          if (booleanPointInPolygon(
              geom1.coordinates[i], Polygon(coordinates: geom2.coordinates[ii]),
              ignoreBoundary: true)) {
            return false;
          }
        }
      }
      return foundTouchingPoint;
    } else {
      throw Exception("feature2 $geom2 geometry not supported");
    }
  } else if (geom1 is LineString) {
    if (geom2 is Point) {
      return isPointOnLineEnd(geom2, geom1);
    } else if (geom2 is MultiPoint) {
      var foundTouchingPoint = false;
      for (var i = 0; i < geom2.coordinates.length; i++) {
        if (!foundTouchingPoint) {
          if (isPointOnLineEnd(
              Point(coordinates: geom2.coordinates[i]), geom1)) {
            foundTouchingPoint = true;
          }
        }
        if (booleanPointOnLine(Point(coordinates: geom2.coordinates[i]), geom1,
            ignoreEndVertices: true)) {
          return false;
        }
      }
      return foundTouchingPoint;
    } else if (geom2 is LineString) {
      var endMatch = false;
      if (isPointOnLineEnd(Point(coordinates: geom1.coordinates[0]), geom2)) {
        endMatch = true;
      }
      if (isPointOnLineEnd(
          Point(
            coordinates: geom1.coordinates[geom1.coordinates.length - 1],
          ),
          geom2)) endMatch = true;
      if (endMatch == false) return false;
      for (var i = 0; i < geom1.coordinates.length; i++) {
        if (booleanPointOnLine(Point(coordinates: geom1.coordinates[i]), geom2,
            ignoreEndVertices: true)) {
          return false;
        }
      }
      return endMatch;
    } else if (geom2 is MultiLineString) {
      var endMatch = false;
      for (var i = 0; i < geom2.coordinates.length; i++) {
        if (isPointOnLineEnd(Point(coordinates: geom1.coordinates[0]),
            LineString(coordinates: geom2.coordinates[i]))) {
          endMatch = true;
        }
        if (isPointOnLineEnd(
            Point(
              coordinates: geom1.coordinates[geom1.coordinates.length - 1],
            ),
            LineString(coordinates: geom2.coordinates[i]))) {
          endMatch = true;
        }
        for (var ii = 0; ii < geom1.coordinates[i].length; ii++) {
          if (booleanPointOnLine(Point(coordinates: geom1.coordinates[ii]),
              LineString(coordinates: geom2.coordinates[i]),
              ignoreEndVertices: true)) {
            return false;
          }
        }
      }
      return endMatch;
    } else if (geom2 is Polygon) {
      var foundTouchingPoint = false;
      for (var i = 0; i < geom1.coordinates.length; i++) {
        if (!foundTouchingPoint) {
          if (booleanPointOnLine(Point(coordinates: geom1.coordinates[i]),
              LineString(coordinates: geom2.coordinates[0]))) {
            foundTouchingPoint = true;
          }
        }
        if (booleanPointInPolygon(geom1.coordinates[i], geom2,
            ignoreBoundary: true)) {
          return false;
        }
      }
      return foundTouchingPoint;
    } else if (geom2 is MultiPolygon) {
      var foundTouchingPoint = false;
      for (var i = 0; i < geom1.coordinates.length; i++) {
        for (var ii = 0; ii < geom2.coordinates.length; ii++) {
          if (!foundTouchingPoint) {
            if (booleanPointOnLine(
              Point(coordinates: geom1.coordinates[i]),
              LineString(
                coordinates: geom2.coordinates[ii][0],
              ),
            )) {
              foundTouchingPoint = true;
            }
          }
        }
        if (booleanPointInPolygon(geom1.coordinates[i], geom2,
            ignoreBoundary: true)) {
          return false;
        }
      }
      return foundTouchingPoint;
    } else {
      throw Exception("feature2 $geom2 geometry not supported");
    }
  } else if (geom1 is MultiLineString) {
    if (geom2 is Point) {
      for (var i = 0; i < geom1.coordinates.length; i++) {
        if (isPointOnLineEnd(
            geom2,
            LineString(
              coordinates: geom1.coordinates[i],
            ))) {
          return true;
        }
      }
      return false;
    } else if (geom2 is MultiPoint) {
      var foundTouchingPoint = false;
      for (var i = 0; i < geom1.coordinates.length; i++) {
        for (var ii = 0; ii < geom2.coordinates.length; ii++) {
          if (!foundTouchingPoint) {
            if (isPointOnLineEnd(Point(coordinates: geom2.coordinates[ii]),
                LineString(coordinates: geom1.coordinates[ii]))) {
              foundTouchingPoint = true;
            }
          }
          if (booleanPointOnLine(Point(coordinates: geom2.coordinates[ii]),
              LineString(coordinates: geom1.coordinates[ii]),
              ignoreEndVertices: true)) {
            return false;
          }
        }
      }
      return foundTouchingPoint;
    } else if (geom2 is LineString) {
      var endMatch = false;
      for (var i = 0; i < geom1.coordinates.length; i++) {
        if (isPointOnLineEnd(
            Point(coordinates: geom1.coordinates[i][0]), geom2)) {
          endMatch = true;
        }
        if (isPointOnLineEnd(
            Point(
              coordinates: geom1.coordinates[i]
                  [geom1.coordinates[i].length - 1],
            ),
            geom2)) {
          endMatch = true;
        }
        for (var ii = 0; ii < geom2.coordinates.length; ii++) {
          if (booleanPointOnLine(Point(coordinates: geom2.coordinates[ii]),
              LineString(coordinates: geom1.coordinates[i]),
              ignoreEndVertices: true)) {
            return false;
          }
        }
      }
      return endMatch;
    } else if (geom2 is MultiLineString) {
      var endMatch = false;
      for (var i = 0; i < geom1.coordinates.length; i++) {
        for (var ii = 0; ii < geom2.coordinates.length; ii++) {
          if (isPointOnLineEnd(Point(coordinates: geom1.coordinates[i][0]),
              LineString(coordinates: geom2.coordinates[ii]))) {
            endMatch = true;
          }
          if (isPointOnLineEnd(
              Point(
                coordinates: geom1.coordinates[i]
                    [geom1.coordinates[i].length - 1],
              ),
              LineString(coordinates: geom2.coordinates[ii]))) {
            endMatch = true;
          }
          for (var iii = 0; iii < geom1.coordinates[i].length; iii++) {
            if (booleanPointOnLine(
                Point(coordinates: geom1.coordinates[i][iii]),
                LineString(coordinates: geom2.coordinates[ii]),
                ignoreEndVertices: true)) {
              return false;
            }
          }
        }
      }
      return endMatch;
    } else if (geom2 is Polygon) {
      var foundTouchingPoint = false;
      for (var i = 0; i < geom1.coordinates.length; i++) {
        for (var ii = 0; ii < geom1.coordinates.length; ii++) {
          if (!foundTouchingPoint) {
            if (booleanPointOnLine(Point(coordinates: geom1.coordinates[i][ii]),
                LineString(coordinates: geom2.coordinates[0]))) {
              foundTouchingPoint = true;
            }
          }
          if (booleanPointInPolygon(geom1.coordinates[i][ii], geom2,
              ignoreBoundary: true)) {
            return false;
          }
        }
      }
      return foundTouchingPoint;
    } else if (geom2 is MultiPolygon) {
      var foundTouchingPoint = false;
      for (var i = 0; i < geom2.coordinates[0].length; i++) {
        for (var ii = 0; ii < geom1.coordinates.length; ii++) {
          for (var iii = 0; iii < geom1.coordinates[ii].length; iii++) {
            if (!foundTouchingPoint) {
              if (booleanPointOnLine(
                  Point(
                    coordinates: geom1.coordinates[ii][iii],
                  ),
                  LineString(
                    coordinates: geom2.coordinates[0][i],
                  ))) {
                foundTouchingPoint = true;
              }
            }
            if (booleanPointInPolygon(geom1.coordinates[ii][iii],
                Polygon(coordinates: [geom2.coordinates[0][i]]),
                ignoreBoundary: true)) {
              return false;
            }
          }
        }
      }
      return foundTouchingPoint;
    } else {
      throw Exception("feature2 $geom2 geometry not supported");
    }
  } else if (geom1 is Polygon) {
    if (geom2 is Point) {
      for (var i = 0; i < geom1.coordinates.length; i++) {
        if (booleanPointOnLine(
            geom2,
            LineString(
              coordinates: geom1.coordinates[i],
            ))) {
          return true;
        }
      }
      return false;
    } else if (geom2 is MultiPoint) {
      var foundTouchingPoint = false;
      for (var i = 0; i < geom2.coordinates.length; i++) {
        if (!foundTouchingPoint) {
          if (booleanPointOnLine(Point(coordinates: geom2.coordinates[i]),
              LineString(coordinates: geom1.coordinates[0]))) {
            foundTouchingPoint = true;
          }
        }
        if (booleanPointInPolygon(geom2.coordinates[i], geom1,
            ignoreBoundary: true)) return false;
      }
      return foundTouchingPoint;
    } else if (geom2 is LineString) {
      var foundTouchingPoint = false;
      for (var i = 0; i < geom2.coordinates.length; i++) {
        if (!foundTouchingPoint) {
          if (booleanPointOnLine(Point(coordinates: geom2.coordinates[i]),
              LineString(coordinates: geom1.coordinates[0]))) {
            foundTouchingPoint = true;
          }
        }
        if (booleanPointInPolygon(geom2.coordinates[i], geom1,
            ignoreBoundary: true)) {
          return false;
        }
      }
      return foundTouchingPoint;
    } else if (geom2 is MultiLineString) {
      var foundTouchingPoint = false;
      for (var i = 0; i < geom2.coordinates.length; i++) {
        for (var ii = 0; ii < geom2.coordinates[i].length; ii++) {
          if (!foundTouchingPoint) {
            if (booleanPointOnLine(Point(coordinates: geom2.coordinates[i][ii]),
                LineString(coordinates: geom1.coordinates[0]))) {
              foundTouchingPoint = true;
            }
          }
          if (booleanPointInPolygon(geom2.coordinates[i][ii], geom1,
              ignoreBoundary: true)) {
            return false;
          }
        }
      }
      return foundTouchingPoint;
    } else if (geom2 is Polygon) {
      var foundTouchingPoint = false;
      for (var i = 0; i < geom1.coordinates[0].length; i++) {
        if (!foundTouchingPoint) {
          if (booleanPointOnLine(
            Point(coordinates: geom1.coordinates[0][i]),
            LineString(coordinates: geom2.coordinates[0]),
          )) {
            foundTouchingPoint = true;
          }
        }
        if (booleanPointInPolygon(geom1.coordinates[0][i], geom2,
            ignoreBoundary: true)) {
          return false;
        }
      }
      return foundTouchingPoint;
    } else if (geom2 is MultiPolygon) {
      var foundTouchingPoint = false;
      for (var i = 0; i < geom2.coordinates[0].length; i++) {
        for (var ii = 0; ii < geom1.coordinates[0].length; ii++) {
          if (!foundTouchingPoint) {
            if (booleanPointOnLine(Point(coordinates: geom1.coordinates[0][ii]),
                LineString(coordinates: geom2.coordinates[0][i]))) {
              foundTouchingPoint = true;
            }
          }
          if (booleanPointInPolygon(geom1.coordinates[0][ii],
              Polygon(coordinates: [geom2.coordinates[0][i]]),
              ignoreBoundary: true)) {
            return false;
          }
        }
      }
      return foundTouchingPoint;
    } else {
      throw Exception("feature2 $geom2 geometry not supported");
    }
  } else if (geom1 is MultiPolygon) {
    if (geom2 is Point) {
      for (var i = 0; i < geom1.coordinates[0].length; i++) {
        if (booleanPointOnLine(
          geom2,
          LineString(
            coordinates: geom1.coordinates[0][i],
          ),
        )) {
          return true;
        }
      }
      return false;
    } else if (geom2 is MultiPoint) {
      var foundTouchingPoint = false;
      for (var i = 0; i < geom1.coordinates[0].length; i++) {
        for (var ii = 0; ii < geom2.coordinates.length; ii++) {
          if (!foundTouchingPoint) {
            if (booleanPointOnLine(Point(coordinates: geom2.coordinates[ii]),
                LineString(coordinates: geom1.coordinates[0][i]))) {
              foundTouchingPoint = true;
            }
          }
          if (booleanPointInPolygon(geom2.coordinates[ii],
              Polygon(coordinates: [geom1.coordinates[0][i]]),
              ignoreBoundary: true)) {
            return false;
          }
        }
      }
      return foundTouchingPoint;
    } else if (geom2 is LineString) {
      var foundTouchingPoint = false;
      for (var i = 0; i < geom1.coordinates[0].length; i++) {
        for (var ii = 0; ii < geom2.coordinates.length; ii++) {
          if (!foundTouchingPoint) {
            if (booleanPointOnLine(Point(coordinates: geom2.coordinates[ii]),
                LineString(coordinates: geom1.coordinates[0][i]))) {
              foundTouchingPoint = true;
            }
          }
          if (booleanPointInPolygon(geom2.coordinates[ii],
              Polygon(coordinates: [geom1.coordinates[0][i]]),
              ignoreBoundary: true)) {
            return false;
          }
        }
      }
      return foundTouchingPoint;
    } else if (geom2 is MultiLineString) {
      var foundTouchingPoint = false;
      for (var i = 0; i < geom1.coordinates.length; i++) {
        for (var ii = 0; ii < geom2.coordinates.length; ii++) {
          for (var iii = 0; iii < geom2.coordinates[ii].length; iii++) {
            if (!foundTouchingPoint) {
              if (booleanPointOnLine(
                Point(
                  coordinates: geom2.coordinates[ii][iii],
                ),
                LineString(
                  coordinates: geom1.coordinates[i][0],
                ),
              )) {
                foundTouchingPoint = true;
              }
            }
            if (booleanPointInPolygon(geom2.coordinates[ii][iii],
                Polygon(coordinates: [geom1.coordinates[i][0]]),
                ignoreBoundary: true)) {
              return false;
            }
          }
        }
      }

      return foundTouchingPoint;
    } else if (geom2 is Polygon) {
      var foundTouchingPoint = false;
      for (var i = 0; i < geom1.coordinates[0].length; i++) {
        for (var ii = 0; ii < geom1.coordinates[0][i].length; ii++) {
          if (!foundTouchingPoint) {
            if (booleanPointOnLine(
                Point(coordinates: geom1.coordinates[0][i][ii]),
                LineString(coordinates: geom2.coordinates[0]))) {
              foundTouchingPoint = true;
            }
          }
          if (booleanPointInPolygon(geom1.coordinates[0][i][ii], geom2,
              ignoreBoundary: true)) {
            return false;
          }
        }
      }
      return foundTouchingPoint;
    } else if (geom2 is MultiPolygon) {
      var foundTouchingPoint = false;
      for (var i = 0; i < geom1.coordinates[0].length; i++) {
        for (var ii = 0; ii < geom2.coordinates[0].length; ii++) {
          for (var iii = 0; iii < geom1.coordinates[0].length; iii++) {
            if (!foundTouchingPoint) {
              if (booleanPointOnLine(
                Point(
                  coordinates: geom1.coordinates[0][i][iii],
                ),
                LineString(
                  coordinates: geom2.coordinates[0][ii],
                ),
              )) {
                foundTouchingPoint = true;
              }
            }
            if (booleanPointInPolygon(geom1.coordinates[0][i][iii],
                Polygon(coordinates: [geom2.coordinates[0][ii]]),
                ignoreBoundary: true)) {
              return false;
            }
          }
        }
      }
      return foundTouchingPoint;
    } else {
      throw Exception("feature2  $geom2 geometry not supported");
    }
  } else {
    throw Exception("feature1 $geom1 geometry not supported");
  }
}

isPointOnLineEnd(Point point, LineString line) {
  if (line.coordinates[0] == point.coordinates) return true;
  if (line.coordinates[line.coordinates.length - 1] == point.coordinates) {
    return true;
  }
  return false;
}

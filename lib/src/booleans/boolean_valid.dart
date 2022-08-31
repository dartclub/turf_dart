import '../../helpers.dart';
import '../invariant.dart';
import '../line_intersect.dart';
import 'boolean_crosses.dart';
import 'boolean_disjoint.dart';

/// booleanValid checks if the geometry is a valid according to the OGC Simple Feature Specification.
///  Take a [Feature] or a [GeometryType]
///  returns a boolean true/false
///  example
///  ```dart
///  var line = LineString(coordinates:[Position.of([1, 1]), Position.of([1, 2]), Position.of([1, 3]), Position.of([1, 4])]);
///
///  booleanValid(line); // => true
///  booleanValid({foo: "bar"}); // => false
/// ```
booleanValid(GeoJSONObject feature) {
  // // Automatic False
  // if (!feature.type) return false;

  // Parse GeoJSON
  var geom = getGeom(feature);
  var type = geom.type;
  var coords = geom.coordinates;

  switch (type) {
    case Point:
      return coords.length > 1;
    case MultiPoint:
      for (var i = 0; i < coords.length; i++) {
        if (coords[i].length < 2) return false;
      }
      return true;
    case LineString:
      if (coords.length < 2) return false;
      for (var i = 0; i < coords.length; i++) {
        if (coords[i].length < 2) return false;
      }
      return true;
    case MultiLineString:
      if (coords.length < 2) return false;
      for (var i = 0; i < coords.length; i++) {
        if (coords[i].length < 2) return false;
      }
      return true;
    case Polygon:
      for (var i = 0; i < geom.coordinates.length; i++) {
        if (coords[i].length < 4) return false;
        if (!checkRingsClose(coords[i])) return false;
        if (checkRingsForSpikesPunctures(coords[i])) return false;
        if (i > 0) {
          if (lineIntersect(Polygon(coordinates: [coords[0]]),
                  Polygon(coordinates: [coords[i]])).features.length >
              1) return false;
        }
      }
      return true;
    case MultiPolygon:
      for (var i = 0; i < geom.coordinates.length; i++) {
        var poly = geom.coordinates[i];

        for (var ii = 0; ii < poly.length; ii++) {
          if (poly[ii].length < 4) return false;
          if (!checkRingsClose(poly[ii])) return false;
          if (checkRingsForSpikesPunctures(poly[ii])) return false;
          if (ii == 0) {
            if (!checkPolygonAgainstOthers(poly, geom.coordinates, i)) {
              return false;
            }
          }
          if (ii > 0) {
            if (lineIntersect(Polygon(coordinates: [poly[0]]),
                    Polygon(coordinates: [poly[ii]])).features.length >
                1) {
              return false;
            }
          }
        }
      }
      return true;
    default:
      return false;
  }
}

checkRingsClose(List<Position> geom) {
  return (geom[0][0] == geom[geom.length - 1][0] ||
      geom[0][1] == geom[geom.length - 1][1]);
}

checkRingsForSpikesPunctures(List<Position> geom) {
  for (var i = 0; i < geom.length - 1; i++) {
    var point = Point(coordinates: geom[i]);
    for (var ii = i + 1; ii < geom.length - 2; ii++) {
      var seg = [geom[ii], geom[ii + 1]];
      if (isPointOnLine(LineString(coordinates: seg), point)) return true;
    }
  }
  return false;
}

checkPolygonAgainstOthers(
    List<List<Position>> poly, List<List<List<Position>>> geom, int index) {
  var polyToCheck = Polygon(coordinates: poly);
  for (var i = index + 1; i < geom.length; i++) {
    if (!booleanDisjoint(polyToCheck, Polygon(coordinates: geom[i]))) {
      if (booleanCrosses(polyToCheck, LineString(coordinates: geom[i][0]))) {
        return false;
      }
    }
  }
  return true;
}

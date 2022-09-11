import 'package:turf/polygon_to_line.dart';
import 'package:turf/src/booleans/boolean_disjoint.dart';
import 'package:turf/src/booleans/boolean_point_on_line.dart';
import 'package:turf/src/invariant.dart';
import 'package:turf/src/meta/extensions.dart';

import '../../helpers.dart';
import '../line_intersect.dart';
import 'boolean_crosses.dart';

bool _checkRingsClose(List<Position> geom) {
  return (geom[0].lng == geom[geom.length - 1].lng ||
      geom[0].lat == geom[geom.length - 1].lat);
}

bool _checkRingsForSpikesPunctures(List<Position> geom) {
  for (var i = 0; i < geom.length - 1; i++) {
    var point = Point(coordinates: geom[i]);
    for (var ii = i + 1; ii < geom.length - 2; ii++) {
      var seg = [geom[ii], geom[ii + 1]];
      if (booleanPointOnLine(point, LineString(coordinates: seg))) return true;
    }
  }
  return false;
}

bool _checkPolygonAgainstOthers(Polygon poly, MultiPolygon geom, int index) {
  for (var i = index + 1; i < geom.coordinates.length; i++) {
    if (!booleanDisjoint(poly, Polygon(coordinates: geom.coordinates[i]))) {
      LineString lineS = LineString(coordinates: geom.coordinates[i][0]);
      if (booleanCrosses(poly, lineS)) {
        Feature line = polygonToLine(poly) as Feature;
        var doLinesIntersect = lineIntersect(lineS, line);

        /// http://portal.opengeospatial.org/files/?artifact_id=829 p.22 - 2 :
        /// 1 intersection Point is 'finite', therefore passes the test
        if (doLinesIntersect.features.length == 1) return true;
        return false;
      }
    }
  }
  return true;
}

/// booleanValid checks if the geometry is a valid according to the OGC Simple
/// Feature Specification.
///  Take a [Feature] or a [GeometryType]
///  example
///  ```dart
///  var line = LineString(coordinates:[Position.of([1, 1]), Position.of([1, 2]),
///  Position.of([1, 3]), Position.of([1, 4])]);
///  booleanValid(line); // => true
///  booleanValid({foo: "bar"}); // => false
/// ```
bool booleanValid(GeoJSONObject feature) {
  // Parse GeoJSON
  if (feature is FeatureCollection<GeometryObject>) {
    for (Feature f in feature.features) {
      if (!booleanValid(f)) {
        return false;
      }
    }
  } else if (feature is GeometryCollection) {
    for (GeometryObject g in feature.geometries) {
      if (!booleanValid(g)) {
        return false;
      }
    }
  } else {
    var geom = getGeom(feature);

    if (geom is Point) {
      if (!(geom.coordinates.length >= 2 && geom.coordinates.length <= 3)) {
        return false;
      }
    } else if (geom is MultiPoint) {
      if (geom.coordinates.length < 2) {
        return false;
      }
      for (Position p in geom.coordinates) {
        if (!booleanValid(Point(coordinates: p))) return false;
      }
    } else if (geom is LineString) {
      if (geom.coordinates.length < 2) return false;
      for (Position p in geom.coordinates) {
        if (!booleanValid(Point(coordinates: p))) return false;
      }
    } else if (geom is MultiLineString) {
      if (geom.coordinates.length < 2) return false;
      for (var i = 0; i < geom.coordinates.length; i++) {
        if (!booleanValid(LineString(coordinates: geom.coordinates[i]))) {
          return false;
        }
      }
    } else if (geom is Polygon) {
      var valid = true;
      geom.coordEach((Position? cCoord, _, __, ___, ____) {
        valid = booleanValid(Point(coordinates: cCoord!));
      });
      if (!valid) return false;
      for (var i = 0; i < geom.coordinates.length; i++) {
        if (geom.coordinates[i].length < 4) return false;
        if (!_checkRingsClose(geom.coordinates[i])) return false;
        if (_checkRingsForSpikesPunctures(geom.coordinates[i])) return false;
        if (i > 0) {
          if (lineIntersect(
                Polygon(coordinates: [geom.coordinates[0]]),
                Polygon(coordinates: [geom.coordinates[i]]),
              ).features.length >
              1) {
            return false;
          }
        }
      }
    } else if (geom is MultiPolygon) {
      for (var i = 0; i < geom.coordinates.length; i++) {
        var poly = geom.coordinates[i];

        for (var ii = 0; ii < poly.length; ii++) {
          if (poly[ii].length < 4) {
            return false;
          }
          if (!_checkRingsClose(poly[ii])) {
            return false;
          }
          if (_checkRingsForSpikesPunctures(poly[ii])) {
            return false;
          }
          if (ii == 0) {
            if (!_checkPolygonAgainstOthers(
                Polygon(coordinates: poly), geom, i)) {
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
    } else {
      throw Exception('the type ${geom.type} is not supported');
    }
  }
  return true;
}

import '../helpers.dart';
import 'invariant.dart';

/// Removes redundant coordinates from any GeometryType.
/// Takes a [Feature] or [GeometryType]
/// [mutate] allows GeoJSON input to be mutated
/// Returns the cleaned input Feature/Geometry
/// example:
/// ```dart
/// var line = LineString(coordinates:[Position.of([0, 0]), Position.of([0, 2]), Position.of([0, 5]), Position.of([0, 8]), Position.of([0, 8]), Position.of([0, 10])]);
/// var multiPoint = MultiPoint(coordinates:[Position.of([0, 0]), Position.of([0, 0]), Position.of([2, 2])]);
/// cleanCoords(line).geometry.coordinates;
/// //= [Position.of([0, 0]), Position.of([0, 10])]
/// cleanCoords(multiPoint).geometry.coordinates;
/// //= [Position.of([0, 0]), Position.of([2, 2])]
GeoJSONObject cleanCoords(
  GeoJSONObject geojson, {
  bool mutate = false,
}) {
  // Store new "clean" points in this List
  var newCoords = [];
  var geom = geojson is Feature ? geojson.geometry : geojson;
  if (geom is LineString) {
    newCoords = <Position>[];
    newCoords = _cleanLine(geom.coordinates, geojson);
  } else if (geom is MultiLineString || geom is Polygon) {
    newCoords = <List<Position>>[];
    (getCoords(geom) as List<List<Position>>).forEach(
      (List<Position> coord) {
        newCoords.add(_cleanLine(coord, geojson));
      },
    );
  } else if (geom is MultiPolygon) {
    newCoords = <List<List<Position>>>[];
    (getCoords(geom) as List<List<List<Position>>>).forEach(
      (List<List<Position>> polyList) {
        var listPoly = <List<Position>>[];
        polyList.forEach(
          (List<Position> poly) {
            listPoly.add(_cleanLine(poly, geom));
          },
        );
        newCoords.add(listPoly);
      },
    );
  } else if (geom is Point) {
    return geojson is Feature ? geojson : geom;
  } else if (geom is MultiPoint) {
    newCoords = <Position>[];
    Set set = <String>{};
    var list = getCoords(geom) as List<Position>;
    list.forEach(
      (element) {
        if (!set.contains([element.alt, element.lat, element.lng].join('-'))) {
          newCoords.add(element.clone());
        }
        set.add([element.alt, element.lat, element.lng].join('-'));
      },
    );
  } else {
    throw Exception("${geom?.type} is not supported");
  }

  // Support input mutation
  if (geojson is GeometryType) {
    if (mutate) {
      geojson.coordinates = newCoords;
      return geojson;
    }
    geojson = geojson.clone()..coordinates = newCoords;
    return geojson;
  } else if (geojson is Feature) {
    if (mutate) {
      (geojson.geometry as GeometryType).coordinates = newCoords;
      return geojson;
    }

    return Feature(
      geometry: (geom as GeometryType)..coordinates = newCoords,
      properties: geojson.properties,
      bbox: geojson.bbox,
      id: geojson.id,
    );
  } else {
    throw Exception('${geojson.type} is not a supported type');
  }
}

List<Position> _cleanLine(List<Position> coords, GeoJSONObject geojson) {
  var points = getCoords(coords) as List<Position>;
  // handle "clean" segment
  if (points.length == 2 && points[0] != points[1]) {
    return points;
  }

  var newPoints = <Position>[];
  int secondToLast = points.length - 1;
  int newPointsLength = newPoints.length;

  newPoints.add(points[0]);
  for (int i = 1; i < secondToLast; i++) {
    var prevAddedPoint = newPoints[newPoints.length - 1];
    if (points[i] == prevAddedPoint) {
      continue;
    } else {
      newPoints.add(points[i]);
      newPointsLength = newPoints.length;
      if (newPointsLength > 2) {
        if (isPointOnLineSegment(newPoints[newPointsLength - 3],
            newPoints[newPointsLength - 1], newPoints[newPointsLength - 2])) {
          newPoints.removeAt(newPoints.length - 2);
        }
      }
    }
  }
  newPoints.add(points[points.length - 1]);
  newPointsLength = newPoints.length;

  // (Multi)Polygons must have at least 4 points, but a closed LineString with only 3 points is acceptable
  if ((geojson is Polygon || geojson is MultiPolygon) &&
      points[0] == points[points.length - 1] &&
      newPointsLength < 4) {
    throw Exception("invalid polygon");
  }

  if (isPointOnLineSegment(newPoints[newPointsLength - 3],
      newPoints[newPointsLength - 1], newPoints[newPointsLength - 2])) {
    newPoints.removeAt(newPoints.length - 2);
  }
  return newPoints;
}

/// Returns if [point] is on the segment between [start] and [end].
/// Borrowed from `booleanPointOnLine` to speed up the evaluation (instead of
/// using the module as dependency).
/// [start] is the coord pair of start of line, [end] is the coord pair of end
/// of line, and [point] is the coord pair of point to check.
bool isPointOnLineSegment(Position start, Position end, Position point) {
  var x = point[0], y = point[1];
  var startX = start[0], startY = start[1];
  var endX = end[0], endY = end[1];

  var dxc = x! - startX!;
  var dyc = y! - startY!;
  var dxl = endX! - startX;
  var dyl = endY! - startY;
  var cross = dxc * dyl - dyc * dxl;

  if (cross != 0) {
    return false;
  } else if ((dxl).abs() >= (dyl).abs()) {
    return dxl > 0 ? startX <= x && x <= endX : endX <= x && x <= startX;
  } else {
    return dyl > 0 ? startY <= y && y <= endY : endY <= y && y <= startY;
  }
}

import '../helpers.dart';
import 'invariant.dart';

/// Removes redundant coordinates from any [GeometryType].
/// Takes a [Feature] or [GeometryType]
/// [mutate] allows GeoJSON input to be mutated
/// Returns the cleaned input [Feature]
/// example:
/// ```dart
/// var line = LineString(coordinates:[Position.of([0, 0]), Position.of([0, 2]), Position.of([0, 5]), Position.of([0, 8]), Position.of([0, 8]), Position.of([0, 10])]);
/// var multiPoint = MultiPoint(coordinates:[Position.of([0, 0]), Position.of([0, 0]), Position.of([2, 2])]);
/// cleanCoords(line).geometry.coordinates;
/// //= [Position.of([0, 0]), Position.of([0, 10])]
/// cleanCoords(multiPoint).geometry.coordinates;
/// //= [Position.of([0, 0]), Position.of([2, 2])]
/// ```
Feature cleanCoords(
  GeoJSONObject geojson, {
  bool mutate = false,
}) {
  if (geojson is Feature && geojson.geometry == null) {
    throw Exception("Geometry of the Feature is null");
  }
  GeometryObject geom =
      geojson is Feature ? geojson.geometry! : geojson as GeometryObject;
  geom = mutate ? geom : geom.clone() as GeometryObject;

  if (geojson is GeometryCollection || geojson is FeatureCollection) {
    throw Exception("${geojson.type} is not supported");
  } else if (geom is LineString) {
    var newCoords = _cleanLine(geom.coordinates, geojson);
    geom.coordinates = newCoords;
  } else if (geom is MultiLineString || geom is Polygon) {
    var newCoords = <List<Position>>[];
    for (var coord in (getCoords(geom) as List<List<Position>>)) {
      newCoords.add(_cleanLine(coord, geom));
    }
    (geom as GeometryType).coordinates = newCoords;
  } else if (geom is MultiPolygon) {
    var newCoords = <List<List<Position>>>[];
    for (var polyList in (getCoords(geom) as List<List<List<Position>>>)) {
      var listPoly = <List<Position>>[];
      for (var poly in polyList) {
        listPoly.add(_cleanLine(poly, geom));
      }
      newCoords.add(listPoly);
    }
    geom.coordinates = newCoords;
  } else if (geom is MultiPoint) {
    var newCoords = <Position>[];
    Set set = <String>{};
    var list = getCoords(geom) as List<Position>;
    for (var element in list) {
      if (!set.contains([element.alt, element.lat, element.lng].join('-'))) {
        newCoords.add(element);
      }
      set.add([element.alt, element.lat, element.lng].join('-'));
    }
    geom.coordinates = newCoords;
  }

  if (geojson is GeometryType) {
    return Feature(geometry: geom);
  } else if (geojson is Feature) {
    if (mutate) {
      return geojson;
    } else {
      return Feature(
        geometry: geom,
        properties: Map.of(geojson.properties ?? {}),
        bbox: geojson.bbox?.clone(),
        id: geojson.id,
      );
    }
  } else {
    throw Exception('${geojson.type} is not a supported type');
  }
}

List<Position> _cleanLine(List<Position> coords, GeoJSONObject geojson) {
  // handle "clean" segment
  if (coords.length == 2 && coords[0] != coords[1]) {
    return coords;
  }

  var newPoints = <Position>[];
  int secondToLast = coords.length - 1;
  int newPointsLength = newPoints.length;

  newPoints.add(coords[0]);
  for (int i = 1; i < secondToLast; i++) {
    var prevAddedPoint = newPoints[newPoints.length - 1];
    if (coords[i] == prevAddedPoint) {
      continue;
    } else {
      newPoints.add(coords[i]);
      newPointsLength = newPoints.length;
      if (newPointsLength > 2) {
        if (isPointOnLineSegment(newPoints[newPointsLength - 3],
            newPoints[newPointsLength - 1], newPoints[newPointsLength - 2])) {
          newPoints.removeAt(newPoints.length - 2);
        }
      }
    }
  }
  newPoints.add(coords[coords.length - 1]);
  newPointsLength = newPoints.length;

  // (Multi)Polygons must have at least 4 points, but a closed LineString with only 3 points is acceptable
  if ((geojson is Polygon || geojson is MultiPolygon) &&
      coords[0] == coords[coords.length - 1] &&
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
  var x = point.lat, y = point.lng;
  var startX = start.lat, startY = start.lng;
  var endX = end.lat, endY = end.lng;

  var dxc = x - startX;
  var dyc = y - startY;
  var dxl = endX - startX;
  var dyl = endY - startY;
  var cross = dxc * dyl - dyc * dxl;

  if (cross != 0) {
    return false;
  } else if ((dxl).abs() >= (dyl).abs()) {
    return dxl > 0 ? startX <= x && x <= endX : endX <= x && x <= startX;
  } else {
    return dyl > 0 ? startY <= y && y <= endY : endY <= y && y <= startY;
  }
}

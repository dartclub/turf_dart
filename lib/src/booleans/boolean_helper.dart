import 'package:turf/helpers.dart';
import 'package:turf/src/bbox.dart';

import 'boolean_point_on_line.dart';
import 'boolean_point_in_polygon.dart';

class GeometryNotSupported implements Exception {
  final GeometryObject geometry;
  GeometryNotSupported(this.geometry);

  @override
  String toString() => "geometry not supported ($geometry).";
}

class GeometryCombinationNotSupported implements Exception {
  final GeometryObject geometry1;
  final GeometryObject geometry2;

  GeometryCombinationNotSupported(this.geometry1, this.geometry2);

  @override
  String toString() => "geometry not supported ($geometry1, $geometry2).";
}

bool isPointInMultiPoint(Point point, MultiPoint multipoint) {
  return multipoint.coordinates
      .any((position) => position == point.coordinates);
}

bool isPointOnLine(Point point, LineString line) {
  return booleanPointOnLine(point, line, ignoreEndVertices: true);
}

bool isPointInPolygon(Point point, Polygon polygon) {
  return booleanPointInPolygon(
    point.coordinates,
    polygon,
    ignoreBoundary: true,
  );
}

bool isPointInMultiPolygon(Point point, MultiPolygon polygon) {
  return booleanPointInPolygon(
    point.coordinates,
    polygon,
    ignoreBoundary: true,
  );
}

bool isMultiPointInMultiPoint(MultiPoint points1, MultiPoint points2) {
  return points1.coordinates.every(
    (point1) => points2.coordinates.any(
      (point2) => point1 == point2,
    ),
  );
}

bool isMultiPointOnLine(MultiPoint points, LineString line) {
  final allPointsOnLine = points.coordinates.every(
    (point) => booleanPointOnLine(
      Point(coordinates: point),
      line,
    ),
  );
  if (allPointsOnLine) {
    final anyInteriorPoint = points.coordinates.any(
      (point) => booleanPointOnLine(
        Point(coordinates: point),
        line,
        ignoreEndVertices: true,
      ),
    );

    if (anyInteriorPoint) {
      return true;
    }
  }
  return false;
}

bool isMultiPointInPolygon(MultiPoint points, Polygon polygon) =>
    _isMultiPointInGeoJsonPolygon(points, polygon);

bool isMultiPointInMultiPolygon(MultiPoint points, MultiPolygon polygon) =>
    _isMultiPointInGeoJsonPolygon(points, polygon);

bool _isMultiPointInGeoJsonPolygon(MultiPoint points, GeoJSONObject polygon) {
  final allPointsInsideThePolygon = points.coordinates.every(
    (point) => booleanPointInPolygon(
      point,
      polygon,
    ),
  );

  if (allPointsInsideThePolygon) {
    final onePointNotOnTheBorder = points.coordinates.any(
      (point) => booleanPointInPolygon(
        point,
        polygon,
        ignoreBoundary: true,
      ),
    );

    if (onePointNotOnTheBorder) {
      return true;
    }
  }
  return false;
}

bool isLineOnLine(LineString line1, LineString line2) {
  return line1.coordinates.every((point) {
    return booleanPointOnLine(
      Point(coordinates: point),
      line2,
    );
  });
}

bool isLineInPolygon(LineString line, Polygon polygon) =>
    _isLineInGeoJsonPolygon(line, polygon);

bool isLineInMultiPolygon(LineString line, MultiPolygon polygon) =>
    _isLineInGeoJsonPolygon(line, polygon);

bool _isLineInGeoJsonPolygon(LineString line, GeoJSONObject polygon) {
  final boundingBoxOfPolygon = bbox(polygon);
  final boundingBoxOfLine = bbox(line);

  if (!_doBBoxesOverlap(boundingBoxOfPolygon, boundingBoxOfLine)) {
    return false;
  }

  final allPointsInsideThePolygon = line.coordinates.every(
    (position) => booleanPointInPolygon(
      position,
      polygon,
    ),
  );

  if (allPointsInsideThePolygon) {
    if (_anyLinePointNotOnBoundary(line, polygon)) {
      return true;
    }

    if (_isLineCrossingThePolygon(line, polygon)) {
      return true;
    }
  }

  return false;
}

bool _anyLinePointNotOnBoundary(LineString line, GeoJSONObject polygon) {
  return line.coordinates.any(
    (position) => booleanPointInPolygon(
      position,
      polygon,
      ignoreBoundary: true,
    ),
  );
}

bool _isLineCrossingThePolygon(LineString line, GeoJSONObject polygon) {
  List<Position> midpoints = List.generate(
    line.coordinates.length - 1,
    (index) => _getMidpoint(
      line.coordinates[index],
      line.coordinates[index + 1],
    ),
  );

  return midpoints.any(
    (position) => booleanPointInPolygon(
      position,
      polygon,
      ignoreBoundary: true,
    ),
  );
}

bool _doBBoxesOverlap(BBox bbox1, BBox bbox2) {
  if (bbox1[0]! > bbox2[0]!) return false;
  if (bbox1[2]! < bbox2[2]!) return false;
  if (bbox1[1]! > bbox2[1]!) return false;
  if (bbox1[3]! < bbox2[3]!) return false;
  return true;
}

Position _getMidpoint(Position position1, Position position2) {
  return Position(
    (position1.lng + position2.lng) / 2,
    (position1.lat + position2.lat) / 2,
  );
}

bool isPolygonInPolygon(Polygon polygon1, Polygon polygon2) =>
    _isPolygonInGeoJsonPolygon(polygon1, polygon2);

bool isPolygonInMultiPolygon(Polygon polygon1, MultiPolygon polygon2) =>
    _isPolygonInGeoJsonPolygon(polygon1, polygon2);

bool _isPolygonInGeoJsonPolygon(
  Polygon polygon1,
  GeoJSONObject polygon2,
) {
  final boundingBoxOfPolygon1 = bbox(polygon1);
  final boundingBoxOfPolygon2 = bbox(polygon2);
  if (!_doBBoxesOverlap(boundingBoxOfPolygon2, boundingBoxOfPolygon1)) {
    return false;
  }

  final positions = polygon1.coordinates[0];
  final anyPointNotInPolygon = positions.any(
    (point) => !booleanPointInPolygon(point, polygon2),
  );

  if (anyPointNotInPolygon) {
    return false;
  }

  return true;
}

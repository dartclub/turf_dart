import 'package:turf/turf.dart';
import 'package:turf/bbox.dart' as b;
import 'package:turf/nearest_point.dart' as np;

/// Finds the tangents of a [Polygon] or [MultiPolygon] from a [Point].
///
/// This function calculates the two tangent points on the boundary of the given
/// polygon (or multipolygon) starting from the external [point]. If the point
/// lies within the polygon's bounding box, the nearest vertex is used as a
/// reference to determine the tangents.
///
/// Returns a [FeatureCollection] containing two [Point] features:
/// - The right tangent point.
/// - The left tangent point.
///
/// Example:
///
/// ```dart
/// // Create a polygon
/// final polygon = Feature<Polygon>(
///   geometry: Polygon(coordinates: [
///     [
///       Position.of([11, 0]),
///       Position.of([22, 4]),
///       Position.of([31, 0]),
///       Position.of([31, 11]),
///       Position.of([21, 15]),
///       Position.of([11, 11]),
///       Position.of([11, 0])
///     ]
///   ]),
///   properties: {},
/// );
///
/// // Create a point
/// final point = Point(coordinates: Position.of([61, 5]));
///
/// // Calculate tangents
/// final tangents = polygonTangents(point, polygon);
///
/// // The FeatureCollection 'tangents' now contains the two tangent points.
///

FeatureCollection polygonTangents(Point point, GeoJSONObject inputPolys) {
  final pointCoords = getCoord(point);
  final polyCoords = getCoords(inputPolys);

  Position rtan = Position.of([0, 0]);
  Position ltan = Position.of([0, 0]);
  double eprev = 0;
  final bbox = b.bbox(inputPolys);
  int nearestPtIndex = 0;
  Feature<Point>? nearest;

  // If the external point lies within the polygon's bounding box, find the nearest vertex.
  if (pointCoords[0]! > bbox[0]! &&
      pointCoords[0]! < bbox[2]! &&
      pointCoords[1]! > bbox[1]! &&
      pointCoords[1]! < bbox[3]!) {
    final nearestFeature =
        np.nearestPoint(Feature<Point>(geometry: point), explode(inputPolys));
    nearest = nearestFeature;
    nearestPtIndex = nearest.properties!['featureIndex'] as int;
  }

  geomEach(inputPolys, (GeometryType? geom, featureIndex, featureProperties,
      featureBBox, featureId) {
    switch (geom?.type) {
      case GeoJSONObjectType.polygon:
        rtan = polyCoords[0][nearestPtIndex];
        ltan = polyCoords[0][0];
        if (nearest != null) {
          if (nearest.geometry!.coordinates[1]! < pointCoords[1]!) {
            ltan = polyCoords[0][nearestPtIndex];
          }
        }
        eprev = isLeft(
          polyCoords[0][0],
          polyCoords[0][polyCoords[0].length - 1],
          pointCoords,
        ).toDouble();
        final processed = processPolygon(
          polyCoords[0],
          pointCoords,
          eprev,
          rtan,
          ltan,
        );
        rtan = processed[0];
        ltan = processed[1];
        break;
      case GeoJSONObjectType.multiPolygon:
        var closestFeature = 0;
        var closestVertex = 0;
        var verticesCounted = 0;
        for (int i = 0; i < polyCoords[0].length; i++) {
          closestFeature = i;
          var verticeFound = false;
          for (var j = 0; j < polyCoords[0][i].length; j++) {
            closestVertex = j;
            if (verticesCounted == nearestPtIndex) {
              verticeFound = true;
              break;
            }
            verticesCounted++;
          }
          if (verticeFound) break;
        }
        rtan = polyCoords[0][closestFeature][closestVertex];
        ltan = polyCoords[0][closestFeature][closestVertex];
        eprev = isLeft(
          polyCoords[0][0][0],
          polyCoords[0][0][polyCoords[0][0].length - 1],
          pointCoords,
        ).toDouble();
        polyCoords[0].forEach((polygon) {
          final processed = processPolygon(
            polygon,
            pointCoords,
            eprev,
            rtan,
            ltan,
          );
          rtan = processed[0];
          ltan = processed[1];
        });
        break;
      default:
        throw Exception("Unsupported geometry type: ${geom?.type}");
    }
  });

  return FeatureCollection(features: [
    Feature<Point>(geometry: Point(coordinates: rtan)),
    Feature<Point>(geometry: Point(coordinates: ltan)),
  ]);
}

/// Processes a polygon to determine the right and left tangents.
List<Position> processPolygon(List<Position> polygonCoords,
    Position pointCoords, double eprev, Position rtan, Position ltan) {
  for (int i = 0; i < polygonCoords.length; i++) {
    final currentCoords = polygonCoords[i];
    var nextCoords = polygonCoords[(i + 1) % polygonCoords.length];
    final enext = isLeft(currentCoords, nextCoords, pointCoords);
    if (eprev <= 0 && enext > 0) {
      if (!isBelow(pointCoords, currentCoords, rtan)) {
        rtan = currentCoords;
      }
    } else if (eprev > 0 && enext <= 0) {
      if (!isAbove(pointCoords, currentCoords, ltan)) {
        ltan = currentCoords;
      }
    } else if (eprev > 0 && enext <= 0) {
      if (!isAbove(pointCoords, currentCoords, ltan)) {
        ltan = currentCoords;
      }
    }
    eprev = enext.toDouble();
  }
  return [rtan, ltan];
}

/// Returns a positive value if [p3] is to the left of the line from [p1] to [p2],
/// negative if to the right, and 0 if collinear.
num isLeft(Position p1, Position p2, Position p3) {
  return ((p2[0]! - p1[0]!) * (p3[1]! - p1[1]!) -
      (p3[0]! - p1[0]!) * (p2[1]! - p1[1]!));
}

/// Returns true if [p3] is above the line from [p1] to [p2].
bool isAbove(Position p1, Position p2, Position p3) {
  return isLeft(p1, p2, p3) > 0;
}

/// Returns true if [p3] is below the line from [p1] to [p2].
bool isBelow(Position p1, Position p2, Position p3) {
  return isLeft(p1, p2, p3) < 0;
}

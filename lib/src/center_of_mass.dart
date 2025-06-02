import 'package:turf/meta.dart';
import 'centroid.dart';

// Takes a Feature and returns its center of mass using the Centroid of Polygon formula
// Link to formula: https://en.wikipedia.org/wiki/Centroid#Centroid_of_polygon
Feature<Point> centerOfMass(
  GeoJSONObject geoJson, {
  Map<String, dynamic>? properties = const {},
}) {
  List<Position> coords = [];

  coordEach(
    geoJson,
    (Position? currentCoord, int? coordIndex, int? featureIndex,
        int? multiFeatureIndex, int? geometryIndex) {
      if (currentCoord != null &&
          currentCoord[0] != null &&
          currentCoord[1] != null) {
        coords.add(currentCoord);
      }
    },
  );

  // Find centre of geoJSON object
  Feature<Point> centre = centroid(geoJson);
  Position translation = centre.geometry!.coordinates;

  // Set up areas with pre-defined variables
  double sx = 0;
  double sy = 0;
  double sArea = 0;

  List<Position> neutralizedPoints = coords.map((point) {
    return Position(point[0]! - translation[0]!, point[1]! - translation[1]!);
  }).toList();

  // Compute signed area and weighted sums
  for (int i = 0; i < neutralizedPoints.length - 1; i++) {
    Position pi = neutralizedPoints[i];
    Position pj = neutralizedPoints[i + 1];

    double xi = pi[0]!.toDouble(), yi = pi[1]!.toDouble();
    double xj = pj[0]!.toDouble(), yj = pj[1]!.toDouble();

    double a = xi * yj - xj * yi;
    sArea += a;
    sx += (xi + xj) * a;
    sy += (yi + yj) * a;
  }

  if (sArea == 0) {
    return centre;
  }

  double areaFactor = 1 / (6 * sArea);
  List<double> finalCoordinates = [
    translation[0]! + areaFactor * sx,
    translation[1]! + areaFactor * sy,
  ];
  // returns Point
  return Feature<Point>(
      geometry: Point(
          coordinates: Position(finalCoordinates[0], finalCoordinates[1])),
      properties: properties);
}

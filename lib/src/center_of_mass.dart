//import 'helpers.dart';
//import 'invariant.dart';
import 'package:turf/meta.dart';
import 'centroid.dart';

Feature<Point> centerOfMass(
  GeoJSONObject geoJson,
  {Map<String, dynamic>? properties = const {}, }) 

  {
  List<List<double>> coords =[];

  coordEach(
    geoJson,
    (Position? currentCoord, int? coordIndex, int? featureIndex, int? multiFeatureIndex, int? geometryIndex) {
      if (currentCoord != null && currentCoord[0] != null && currentCoord[1] != null) {
        coords.add([currentCoord[0]!.toDouble(), currentCoord[1]!.toDouble()]);
      }
    },
 );

  Feature<Point> centre = centroid(geoJson);
  Position translation = centre.geometry!.coordinates;

  double sx = 0;
  double sy = 0;
  double sArea = 0;

  List<List<double>> neutralizedPoints = coords.map((point) {
    return [point[0] - translation[0]!, point[1] - translation[1]!];
  }).toList();

  // Compute signed area and weighted sums
  for (int i = 0; i < neutralizedPoints.length - 1; i++) {
    List<double> pi = neutralizedPoints[i];
    List<double> pj = neutralizedPoints[i + 1];

    double xi = pi[0], yi = pi[1];
    double xj = pj[0], yj = pj[1];

    double a = xi * yj - xj * yi; // Compute factor
    sArea += a;                  // Accumulate signed area
    sx += (xi + xj) * a;         // Accumulate weighted sum of x-coordinates
    sy += (yi + yj) * a;         // Accumulate weighted sum of y-coordinates
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
    geometry: Point(coordinates: Position(finalCoordinates[0], finalCoordinates[1])),
    properties: properties
  );
}
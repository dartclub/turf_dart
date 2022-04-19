import 'bearing.dart';
import 'destination.dart';
import 'distance.dart';
import 'geojson.dart';

Position midpointRaw(Position point1, Position point2) {
  var dist = distanceRaw(point1, point2);
  var heading = bearingRaw(point1, point2);
  var midpoint = destinationRaw(point1, dist / 2, heading);

  return midpoint;
}

/// Takes two [Point]s and returns a point midway between them.
/// The midpoint is calculated geodesically, meaning the curvature of the earth is taken into account.
/// For example:
///
/// ```
/// var point1 = Point(coordinates: Position(-75.343, 39.984));
/// var point2 = Point(coordinates: Position((-75.543, 39.123));
///
/// var midpoint = midpoint(point1, point2);
///
/// //addToMap
/// var addToMap = [point1, point2, midpoint];
/// midpoint.properties['marker-color'] = '#f00';
/// ```
Point midpoint(Point point1, Point point2) => Point(
      coordinates: midpointRaw(point1.coordinates, point2.coordinates),
    );

import 'bearing.dart';
import 'destination.dart';
import 'distance.dart';
import 'geojson.dart';

Position midpointRaw(Position point1, Position point2) {
  var dist = distanceRaw(point1, point2);
  print(dist);
  var heading = bearingRaw(point1, point2);
  print(heading);
  var midpoint = destinationRaw(point1, dist / 2, heading);

  return midpoint;
}

Point midpoint(Point point1, Point point2) => Point(
      coordinates: midpointRaw(point1.coordinates, point2.coordinates),
    );

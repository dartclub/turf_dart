import 'bearing.dart';
import 'destination.dart';
import 'distance.dart';
import 'geojson.dart';

Position midpoint(Position point1, Position point2) {
  var dist = distance(point1, point2);
  var heading = bearing(point1, point2);
  var midpoint = destination(point1, dist / 2, heading);

  return midpoint;
}

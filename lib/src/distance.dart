import 'dart:math';

import 'geojson.dart';
import 'helpers.dart';

num distanceRaw(Position from, Position to, [Unit unit = Unit.kilometers]) {
  var dLat = degreesToRadians((to.lat! - from.lat!));
  var dLon = degreesToRadians((to.lng! - from.lng!));
  var lat1 = degreesToRadians(from.lat!);
  var lat2 = degreesToRadians(to.lat!);

  num a = pow(sin(dLat / 2), 2) + pow(sin(dLon / 2), 2) * cos(lat1) * cos(lat2);

  return radiansToLength(2 * atan2(sqrt(a), sqrt(1 - a)), unit);
}

num distance(Point from, Point to, [Unit unit = Unit.kilometers]) =>
    distanceRaw(from.coordinates, to.coordinates, unit);

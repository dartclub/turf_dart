import 'dart:math';

import 'package:turf/bearing.dart';
import 'package:turf/destination.dart';
import 'package:turf/helpers.dart';
import 'package:turf/length.dart';
import 'package:turf/src/distance.dart' as measure_distance;
import 'package:turf/src/invariant.dart';

/// Takes a [line] and returns a [Point] at a specified [distance] along the line.
///
/// If [distance] is less than 0, it will count distance along the line from end
///   to start of line. If negative [distance] overshoots the length of the line,
///   the start point of the line is returned.
/// If [distance] is larger than line length, the end point is returned
/// If [line] have no geometry or coordinates, an Exception is thrown
Point along(Feature<LineString> line, num distance,
    [Unit unit = Unit.kilometers]) {
  // Get Coords
  final coords = getCoords(line);
  if (coords.isEmpty) {
    throw Exception('line must contain at least one coordinate');
  }
  if (distance < 0) {
    distance = max(0, length(line, unit) + distance);
  }
  num travelled = 0;
  for (int i = 0; i < coords.length; i++) {
    if (distance >= travelled && i == coords.length - 1) {
      break;
    } else if (travelled >= distance) {
      final overshot = distance - travelled;
      if (overshot == 0) {
        return Point(coordinates: coords[i]);
      } else {
        final direction = bearing(Point(coordinates: coords[i]),
                Point(coordinates: coords[i - 1])) -
            180;
        final interpolated = destination(
          Point(coordinates: coords[i]),
          overshot,
          direction,
          unit,
        );
        return interpolated;
      }
    } else {
      travelled += measure_distance.distance(Point(coordinates: coords[i]),
          Point(coordinates: coords[i + 1]), unit);
    }
  }
  return Point(coordinates: coords[coords.length - 1]);
}

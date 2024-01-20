import 'package:turf/bearing.dart';
import 'package:turf/destination.dart';
import 'package:turf/helpers.dart';
import 'package:turf/src/distance.dart' as measure_distance;
import 'package:turf/src/invariant.dart';

/// Takes a [line] and returns a [Point] at a specified [distance] along the line.
///
/// If [distance] is less than 0, the line start point is returned
/// If [distance] is larger than line length, the end point is returned
Point? along(Feature<LineString> line, num distance, [Unit unit = Unit.kilometers]) {
  // Get Coords
  final coords = getCoords(line);
  if (distance < 0) {
    return coords.isNotEmpty ? Point(coordinates: coords.first) : null;
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

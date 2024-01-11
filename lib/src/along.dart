import 'package:turf/bearing.dart';
import 'package:turf/destination.dart';
import 'package:turf/helpers.dart';
import 'package:turf/src/distance.dart' as measure_distance;

/// Takes a [line] and returns a [Point] at a specified distance along the line.
Point? along(LineString line, num distance, [Unit unit = Unit.kilometers]) {
  // Get Coords
  final coords = line.coordinates;
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

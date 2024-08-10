import 'package:turf/bearing.dart';
import 'package:turf/destination.dart';
import 'package:turf/distance.dart';
import 'package:turf/helpers.dart';

/// Takes a [line], at a start distance [startDist] and a stop distance [stopDist]
/// and returns a subsection of the line in-between those distances.
///
/// If [startDist] and [stopDist] resolve to the same point on [line], null is returned
/// as the resolved line would only contain one point which isn't supported by LineString.
///
/// This can be useful for extracting only the part of a route between distances on the route.
LineString lineSliceAlongRaw(
  LineString line,
  double startDist,
  double stopDist, [
  Unit unit = Unit.kilometers,
]) {
  List<Position> coords = line.coordinates;
  var slice = <Position>[];

  var origCoordsLength = coords.length;
  double travelled = 0;
  double? overshot;
  double direction = 0;
  Position? interpolated;
  for (var i = 0; i < coords.length; i++) {
    if (startDist >= travelled && i == coords.length - 1) {
      break;
    } else if (travelled > startDist && slice.isEmpty) {
      overshot = startDist - travelled;
      if (overshot == 0) {
        slice.add(coords[i]);
        return LineString(coordinates: slice);
      }
      direction = bearingRaw(coords[i], coords[i - 1]) - 180;
      interpolated = destinationRaw(coords[i], overshot, direction, unit);
      slice.add(interpolated);
    }

    if (travelled >= stopDist) {
      overshot = stopDist - travelled;
      if (overshot == 0) {
        slice.add(coords[i]);
        return LineString(coordinates: slice);
      }
      direction = bearingRaw(coords[i], coords[i - 1]) - 180;
      interpolated = destinationRaw(coords[i], overshot, direction, unit);
      slice.add(interpolated);
      return LineString(coordinates: slice);
    }

    if (travelled >= startDist) {
      slice.add(coords[i]);
    }

    if (i == coords.length - 1) {
      return LineString(coordinates: slice);
    }

    travelled += distanceRaw(coords[i], coords[i + 1], unit);
  }

  if (travelled < startDist && coords.length == origCoordsLength) {
    throw Exception("Start position is beyond line");
  }

  final last = coords[coords.length - 1];
  return LineString(coordinates: [last, last]);
}

/// Takes a [line], at a start distance [startDist] and a stop distance [stopDist]
/// and returns a subsection of the line in-between those distances.
///
/// If [startDist] and [stopDist] resolve to the same point on [line], null is returned
/// as the resolved line would only contain one point which isn't supported by LineString.
///
/// This can be useful for extracting only the part of a route between distances on the route.
Feature<LineString> lineSliceAlong(
  Feature<LineString> line,
  double startDist,
  double stopDist, [
  Unit unit = Unit.kilometers,
]) {
  return Feature<LineString>(
    geometry: lineSliceAlongRaw(line.geometry!, startDist, stopDist, unit),
    properties: line.properties,
  );
}

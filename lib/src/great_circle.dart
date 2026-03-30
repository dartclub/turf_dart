import 'dart:math' as math;
import 'package:turf/turf.dart';

/// Calculates the great circle route between two points on a sphere
///
/// Useful link: https://en.wikipedia.org/wiki/Great-circle_distance
Feature<GeometryType> greatCircle(
  Position start,
  Position end, {
  Map<String, dynamic> properties = const {},
  int npoints = 100,
  int offset = 10,
}) {
  if (start.length != 2 || end.length != 2) {
    throw ArgumentError(
      "Both start and end coordinates should have two values - a latitude and longitude",
    );
  }

  if (start[0] == end[0] && start[1] == end[1]) {
    return Feature<LineString>(
      geometry: LineString(coordinates: []),
      properties: properties,
    );
  }

  if (start[0]! < -90) {
    throw ArgumentError(
      "Starting latitude (vertical) coordinate is less than -90. This is not a valid coordinate.",
    );
  }

  if (start[0]! > 90) {
    throw ArgumentError(
      "Starting latitude (vertical) coordinate is greater than 90. This is not a valid coordinate.",
    );
  }

  if (start[1]! < -180) {
    throw ArgumentError(
      'Starting longitude (horizontal) coordinate is less than -180. This is not a valid coordinate.',
    );
  }

  if (start[1]! > 180) {
    throw ArgumentError(
      'Starting longitude (horizontal) coordinate is greater than 180. This is not a valid coordinate.',
    );
  }

  if (end[0]! < -90) {
    throw ArgumentError(
      "Ending latitude (vertical) coordinate is less than -90. This is not a valid coordinate.",
    );
  }

  if (end[0]! > 90) {
    throw ArgumentError(
      "Ending latitude (vertical) coordinate is greater than 90. This is not a valid coordinate.",
    );
  }

  if (end[1]! < -180) {
    throw ArgumentError(
      'Ending longitude (horizontal) coordinate is less than -180. This is not a valid coordinate.',
    );
  }

  if (end[1]! > 180) {
    throw ArgumentError(
      'Ending longitude (horizontal) coordinate is greater than 180. This is not a valid coordinate.',
    );
  }


  final List<Position> line = [];

  final num lat1 = degreesToRadians(start[0]!);
  final num lng1 = degreesToRadians(start[1]!);
  final num lat2 = degreesToRadians(end[0]!);
  final num lng2 = degreesToRadians(end[1]!);

  for (int i = 0; i <= npoints; i++) {
    final double f = i / npoints;
    final double delta = 2 *
        math.asin(
          math.sqrt(
            math.pow(math.sin((lat2 - lat1) / 2), 2) +
                math.cos(lat1) *
                    math.cos(lat2) *
                    math.pow(math.sin((lng2 - lng1) / 2), 2),
          ),
        );

    final double a = math.sin((1 - f) * delta) / math.sin(delta);
    final double b = math.sin(f * delta) / math.sin(delta);
    final double x = a * math.cos(lat1) * math.cos(lng1) +
        b * math.cos(lat2) * math.cos(lng2);
    final double y = a * math.cos(lat1) * math.sin(lng1) +
        b * math.cos(lat2) * math.sin(lng2);
    final double z = a * math.sin(lat1) + b * math.sin(lat2);

    final double lat = math.atan2(z, math.sqrt(x * x + y * y));
    final double lng = math.atan2(y, x);

    line.add(Position(lng, lat));
  }

  final bool crossAntiMeridian = (lng1 - lng2).abs() > 180;

  if (crossAntiMeridian) {
    final List<List<Position>> multiLine = [];
    List<Position> currentLine = [];

    for (final point in line) {
      if ((point[0]! - line[0][0]!).abs() > 180) {
        multiLine.add(currentLine);
        currentLine = [];
      }
      currentLine.add(point);
    }
    multiLine.add(currentLine);

    return Feature<MultiLineString>(
      geometry: MultiLineString(coordinates: multiLine),
      properties: properties,
    );
  }

  return Feature<LineString>(
    geometry: LineString(coordinates: line),
    properties: properties,
  );
}
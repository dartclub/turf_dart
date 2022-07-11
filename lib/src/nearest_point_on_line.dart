import 'dart:math';

import 'bearing.dart';
import 'destination.dart';
import 'distance.dart';
import 'geojson.dart';
import 'helpers.dart';
import 'intersection.dart';

class _Nearest {
  final Point point;
  final num distance;
  final int index;
  final num location;

  _Nearest({
    required this.point,
    required this.distance,
    required this.index,
    required this.location,
  });

  Feature<Point> toFeature() {
    return Feature(
      geometry: point,
      properties: {
        'dist': distance,
        'index': index,
        'location': location,
      },
    );
  }
}

class _NearestMulti extends _Nearest {
  final int line;
  final int localIndex;

  _NearestMulti({
    required Point point,
    required num distance,
    required int index,
    required this.localIndex,
    required num location,
    required this.line,
  }) : super(
          point: point,
          distance: distance,
          index: index,
          location: location,
        );

  @override
  Feature<Point> toFeature() {
    return Feature(
      geometry: point,
      properties: {
        'dist': super.distance,
        'line': line,
        'index': super.index,
        'localIndex': localIndex,
        'location': super.location,
      },
    );
  }
}

_Nearest _nearestPointOnLine(
  LineString line,
  Point point, [
  Unit unit = Unit.kilometers,
]) {
  _Nearest? nearest;

  num length = 0;

  for (var i = 0; i < line.coordinates.length - 1; ++i) {
    final startCoordinates = line.coordinates[i];
    final stopCoordinates = line.coordinates[i + 1];

    final startPoint = Point(coordinates: startCoordinates);
    final stopPoint = Point(coordinates: stopCoordinates);

    final sectionLength = distance(startPoint, stopPoint, unit);

    final start = _Nearest(
      point: startPoint,
      distance: distance(point, startPoint, unit),
      index: i,
      location: length,
    );

    final stop = _Nearest(
      point: stopPoint,
      distance: distance(point, stopPoint, unit),
      index: i + 1,
      location: length + sectionLength,
    );

    final heightDistance = max(start.distance, stop.distance);
    final direction = bearing(startPoint, stopPoint);

    final perpendicular1 = destination(
      point,
      heightDistance,
      direction + 90,
      unit,
    );

    final perpendicular2 = destination(
      point,
      heightDistance,
      direction - 90,
      unit,
    );

    final intersectionPoint = intersects(
      LineString.fromPoints(points: [perpendicular1, perpendicular2]),
      LineString.fromPoints(points: [startPoint, stopPoint]),
    );

    _Nearest? intersection;

    if (intersectionPoint != null) {
      intersection = _Nearest(
        point: intersectionPoint,
        distance: distance(point, intersectionPoint, unit),
        index: i,
        location: length + distance(startPoint, intersectionPoint, unit),
      );
    }

    if (nearest == null || start.distance < nearest.distance) {
      nearest = start;
    }

    if (stop.distance < nearest.distance) {
      nearest = stop;
    }

    if (intersection != null && intersection.distance < nearest.distance) {
      nearest = intersection;
    }

    length += sectionLength;
  }

  /// A `LineString` is guaranteed to have at least two points and thus a
  /// nearest point has to exist.

  return nearest!;
}

_NearestMulti? _nearestPointOnMultiLine(
  MultiLineString lines,
  Point point, [
  Unit unit = Unit.kilometers,
]) {
  _NearestMulti? nearest;

  var globalIndex = 0;

  for (var i = 0; i < lines.coordinates.length; ++i) {
    final line = LineString(coordinates: lines.coordinates[i]);

    final candidate = _nearestPointOnLine(line, point);

    if (nearest == null || candidate.distance < nearest.distance) {
      nearest = _NearestMulti(
        point: candidate.point,
        distance: candidate.distance,
        index: globalIndex + candidate.index,
        localIndex: candidate.index,
        location: candidate.location,
        line: i,
      );
    }

    globalIndex += line.coordinates.length;
  }

  return nearest;
}

/// Takes a [Point] and a [LineString] and calculates the closest Point on the [LineString].
/// ```dart
/// var line = LineString(
///   coordinates: [
///     Position.of([-77.031669, 38.878605]),
///     Position.of([-77.029609, 38.881946]),
///     Position.of([-77.020339, 38.884084]),
///     Position.of([-77.025661, 38.885821]),
///     Position.of([-77.021884, 38.889563]),
///     Position.of([-77.019824, 38.892368)]
/// ]);
/// var pt = Point(coordinates: Position(lat: -77.037076, lng: 38.884017));
///
/// var snapped = nearestPointOnLine(line, pt, Unit.miles);
/// ```
///
Feature<Point> nearestPointOnLine(
  LineString line,
  Point point, [
  Unit unit = Unit.kilometers,
]) {
  return _nearestPointOnLine(line, point, unit).toFeature();
}

/// Takes a [Point] and a [MultiLineString] and calculates the closest Point on the [MultiLineString].
Feature<Point>? nearestPointOnMultiLine(
  MultiLineString lines,
  Point point, [
  Unit unit = Unit.kilometers,
]) {
  return _nearestPointOnMultiLine(lines, point, unit)?.toFeature();
}

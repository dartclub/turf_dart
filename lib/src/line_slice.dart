import 'package:geotypes/geotypes.dart';

import 'nearest_point_on_line.dart';
import 'invariant.dart';

/// Takes a [line], at a start point [startPt], and a stop point [stopPt]
/// and returns a subsection of the line in-between those points.
/// The start & stop points don't need to fall exactly on the line.
///
/// If [startPt] and [stopPt] resolve to the same point on [line], null is returned
/// as the resolved line would only contain one point which isn't supported by LineString.
///
/// This can be useful for extracting only the part of a route between waypoints.
Feature<LineString> lineSlice(
    Feature<Point> startPt, Feature<Point> stopPt, Feature<LineString> line) {
  final coords = line.geometry;
  final startPtGeometry = startPt.geometry;
  final stopPtGeometry = stopPt.geometry;
  if (coords == null) {
    throw Exception('line has no geometry');
  }
  if (startPtGeometry == null) {
    throw Exception('startPt has no geometry');
  }
  if (stopPtGeometry == null) {
    throw Exception('stopPt has no geometry');
  }

  final startVertex = nearestPointOnLine(coords, startPtGeometry);
  final stopVertex = nearestPointOnLine(coords, stopPtGeometry);
  late final List<Feature<Point>> ends;
  if (startVertex.properties!['index'] <= stopVertex.properties!['index']) {
    ends = [startVertex, stopVertex];
  } else {
    ends = [stopVertex, startVertex];
  }
  final List<Position> clipCoords = [getCoord(ends[0])];
  for (var i = ends[0].properties!['index'] + 1;
      i < ends[1].properties!['index'];
      i++) {
    clipCoords.add(coords.coordinates[i]);
  }
  clipCoords.add(getCoord(ends[1]));
  return Feature<LineString>(
    geometry: LineString(coordinates: clipCoords),
    properties: line.properties,
  );
}

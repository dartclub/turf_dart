import 'package:geotypes/geotypes.dart';
import 'package:turf/helpers.dart';
import 'package:turf/bbox.dart'; // for BBox
import 'package:turf/lineclip.dart'; // your polygonclip and lineclip implementations

Feature bboxClip(Feature feature, BBox bbox) {
  final geometry = feature.geometry;

  switch (geometry) {
    case LineString():
      final clippedLines = lineclip(geometry.coordinates, bbox);
      if (clippedLines.length == 1) {
        return Feature(
          geometry: LineString(clippedLines.first),
          properties: feature.properties,
        );
      }
      return Feature(
        geometry: MultiLineString(clippedLines),
        properties: feature.properties,
      );

    case MultiLineString():
      final List<List<Position>> resultLines = [];
      for (final line in geometry.coordinates) {
        lineclip(line, bbox, resultLines);
      }
      if (resultLines.length == 1) {
        return Feature(
          geometry: LineString(resultLines.first),
          properties: feature.properties,
        );
      }
      return Feature(
        geometry: MultiLineString(resultLines),
        properties: feature.properties,
      );

    case Polygon():
      final clippedRings = clipPolygon(geometry.coordinates, bbox);
      return Feature(
        geometry: Polygon(clippedRings),
        properties: feature.properties,
      );

    case MultiPolygon():
      final clippedPolygons = geometry.coordinates
          .map((rings) => clipPolygon(rings, bbox))
          .where((poly) => poly.isNotEmpty)
          .toList();

      return Feature(
        geometry: MultiPolygon(clippedPolygons),
        properties: feature.properties,
      );

    default:
      throw UnsupportedError('Geometry type ${geometry.runtimeType} not supported');
  }
}

List<List<Position>> clipPolygon(List<List<Position>> rings, BBox bbox) {
  final List<List<Position>> outRings = [];

  for (final ring in rings) {
    final clipped = polygonclip(ring, bbox);

    if (clipped.isNotEmpty) {
      // Ensure the ring is closed
      if (clipped.first != clipped.last) {
        clipped.add(clipped.first);
      }

      // Minimum 4 points to form a valid ring
      if (clipped.length >= 4) {
        outRings.add(clipped);
      }
    }
  }

  return outRings;
}

import 'package:turf/lineclip.dart';

Feature bboxClip(Feature feature, BBox bbox) {
  final geometry = feature.geometry;
  if (geometry == null) {
    throw UnsupportedError('Feature has no geometry');
  }

  if (geometry is LineString) {
    final clippedLines = lineclip(geometry.coordinates, bbox);
    if (clippedLines.length == 1) {
      return Feature(
        geometry: LineString(coordinates: clippedLines.first),
        properties: feature.properties,
      );
    }
    return Feature(
      geometry: MultiLineString(coordinates: clippedLines),
      properties: feature.properties,
    );
  } else if (geometry is MultiLineString) {
    final resultLines = <List<Position>>[];
    for (final line in geometry.coordinates) {
      lineclip(line, bbox, resultLines);
    }
    if (resultLines.length == 1) {
      return Feature(
        geometry: LineString(coordinates: resultLines.first),
        properties: feature.properties,
      );
    }
    return Feature(
      geometry: MultiLineString(coordinates: resultLines),
      properties: feature.properties,
    );
  } else if (geometry is Polygon) {
    final clippedRings = clipPolygon(geometry.coordinates, bbox);
    return Feature(
      geometry: Polygon(coordinates: clippedRings),
      properties: feature.properties,
    );
  } else if (geometry is MultiPolygon) {
    final clippedPolygons = geometry.coordinates
        .map((rings) => clipPolygon(rings, bbox))
        .where((poly) => poly.isNotEmpty)
        .toList();

    return Feature(
      geometry: MultiPolygon(coordinates: clippedPolygons),
      properties: feature.properties,
    );
  } else {
    throw UnsupportedError(
      'Geometry type ${geometry.runtimeType} not supported',
    );
  }
}

List<List<Position>> clipPolygon(List<List<Position>> rings, BBox bbox) {
  final outRings = <List<Position>>[];

  for (final ring in rings) {
    final clipped = polygonclip(ring, bbox);

    if (clipped.isNotEmpty) {
      if (clipped.first != clipped.last) {
        clipped.add(clipped.first);
      }

      if (clipped.length >= 4) {
        outRings.add(clipped);
      }
    }
  }

  return outRings;
}

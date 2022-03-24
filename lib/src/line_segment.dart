// TODO implement https://github.com/Turfjs/turf/blob/fcdaa939c905e6cfa80cca11a0e7cbb851ad1a47/packages/turf-meta/index.js#L886
// TODO implement https://github.com/Turfjs/turf/blob/fcdaa939c905e6cfa80cca11a0e7cbb851ad1a47/packages/turf-meta/index.js#L1001
import 'geojson.dart';
import 'invariant.dart';
import 'meta.dart';

// export default lineSegment;

/// Creates a [FeatureCollection] of 2-vertex [LineString] segments from a
/// [LineString] or [MultiLineString] or [Polygon] and [MultiPolygon]
/// Returns [FeatureCollection<LineString>] 2-vertex line segments
/// For example:
///
/// ```dart
/// var polygon = Polygon.fromJson({
///     'coordinates': [
///       [
///         [0, 0],
///         [1, 1],
///         [0, 1],
///         [0, 0],
///       ],
///     ];
/// var segments = lineSegment(polygon);
/// //addToMap
/// var addToMap = [polygon, segments]

FeatureCollection<LineString> lineSegment(GeoJSONObject geoJson) {
  List<Feature<LineString>> features = [];
  if (geoJson is Point || geoJson is MultiPoint) {
    throw Exception('Unsupported GeoJSONObject type');
  }

  flattenEach(
    geoJson,
    (Feature currentFeature, int featureIndex, int multiFeatureIndex) {
      if (currentFeature.geometry is! Point) {
        features.addAll(lineSegmentFeature(currentFeature));
      }
    },
  );

  return FeatureCollection(features: features);
}

List<Feature<LineString>> createSegments(List<Position> coords, properties) {
  List<Feature<LineString>> segments = [];

  coords.reduce((previousCoords, currentCoord) {
    Feature<LineString> segment = Feature<LineString>(
        geometry: LineString(coordinates: [previousCoords, currentCoord]),
        properties: properties,
        bbox: BBox.named(
            lat1: previousCoords.lat,
            lat2: currentCoord.lat,
            lng1: previousCoords.lng,
            lng2: currentCoord.lng));

    segments.add(segment);
    return currentCoord;
  });

  return segments;
}

List<Feature<LineString>> lineSegmentFeature(Feature feature) {
  List<Feature<LineString>> results = [];
  var geometry = feature.geometry;
  var coords = [];

  if (geometry != null) {
    if (geometry is Polygon) {
      coords = getCoords(geometry);
    }
    if (geometry is LineString) {
      coords.add(getCoords(geometry));
    }

    for (List<Position> coord in coords) {
      var segments = createSegments(coord, feature.properties);
      for (var segment in segments) {
        segment.id = results.length;
        results.add(segment);
      }
    }
  }
  return results;
}

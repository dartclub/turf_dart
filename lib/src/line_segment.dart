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

FeatureCollection<LineString> lineSegment(GeometryObject geoJson) {
  List<Feature<LineString>> features = [];
  if (geoJson is! LineString &&
      geoJson is! MultiLineString &&
      geoJson is! MultiPolygon &&
      geoJson is! Polygon &&
      geoJson is! Feature &&
      geoJson is! FeatureCollection) {
    throw Exception('Unsupported GeoJSONObject type');
  } else {
    flattenEach(geoJson,
        (Feature currentFeature, int featureIndex, int multiFeatureIndex) {
      lineSegmentFeature(geoJson, features); //
    });
  }
  return FeatureCollection(features: features);
}

createSegments(List<Position> coord, properties) {
  List<Feature<LineString>> segments = [];
  coord.reduce((previousCoords, currentCoords) {
    Feature<LineString> segment = Feature<LineString>(
        geometry: LineString(coordinates: [previousCoords, currentCoords]),
        properties: properties,
        bbox: BBox.named(
            lat1: previousCoords.lat,
            lat2: currentCoords.lat,
            lng1: previousCoords.lng,
            lng2: currentCoords.lng));

    segments.add(segment);
    return currentCoords;
  });
  return segments;
}

lineSegmentFeature(GeoJSONObject geoJson, List<Feature<LineString>> results) {
  var coords = [];
  bool isFeature = geoJson is Feature && geoJson is FeatureCollection;
  var geometry =
      isFeature ? geoJson.geometry : (geoJson as GeometryType).coordinates;
  if (geometry != null) {
    switch (geometry.type) {
      case GeoJSONObjectType.lineString:
        coords.add(getCoords(geometry));
        break;
      default:
        coords = getCoords(geometry);
        break;
    }
    for (List<Position> coord in coords) {
      var segments =
          createSegments(coord, isFeature ? geoJson.properties : null);
      segments.forEach((segment) {
        segment.id = results.length;
        results.add(segment);
      });
    }
  }
}

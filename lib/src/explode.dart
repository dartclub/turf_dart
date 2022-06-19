import 'package:turf/helpers.dart';
import 'package:turf/meta.dart';

/// Takes a feature or set of features and returns all positions as [Point]s.
/// Takes [GeoJSONObhect] input.
/// Returns [FeatureCollection<point>] representing the exploded input features
/// Throws [Exception] if it encounters an unknown geometry type
/// ```dart
/// var polygon = Polygon(coordinates:
/// [[
///   Position.of([-81, 41]),
///   Position.of([-88, 36]),
///   Position.of([-84, 31]),
///   Position.of([-80, 33]),
///   Position.of([-77, 39]),
///   Position.of([-81, 41]),
///  ]]);
///
/// FeatureCollection<Point> explode = explode(polygon);
///
/// //addToMap
/// var addToMap = [polygon, explode]

FeatureCollection<Point> explode(GeoJSONObject geojson) {
  var points = <Feature<Point>>[];
  if (geojson is FeatureCollection) {
    featureEach(geojson, (feature, id) {
      coordEach(feature, (Position? currentCoord, int? coordIndex,
          int? featureIndex, int? multiFeatureIndex, int? geometryIndex) {
        points.add(
          Feature(
            geometry: Point(coordinates: currentCoord!),
            properties: Map.of(feature.properties ?? {}),
          ),
        );
      });
    });
  } else if (geojson is Feature) {
    coordEach(geojson, (Position? currentCoord, int? coordIndex,
        int? featureIndex, int? multiFeatureIndex, int? geometryIndex) {
      points.add(
        Feature(
          geometry: Point(coordinates: currentCoord!),
          properties: Map.of(geojson.properties ?? {}),
        ),
      );
    });
  }
  return FeatureCollection(features: points);
}

import 'package:turf/helpers.dart';

import 'polygonize/config.dart';
import 'polygonize/polygonize.dart';

/// Converts a collection of LineString features to a collection of Polygon features.
///
/// Takes a [FeatureCollection<LineString>] and returns a [FeatureCollection<Polygon>].
/// The input features must be correctly noded, meaning they should only meet at their endpoints.
///
/// Example:
/// ```dart
/// var lines = FeatureCollection(features: [
///   Feature(geometry: LineString(coordinates: [
///     Position.of([0, 0]),
///     Position.of([10, 0])
///   ])),
///   Feature(geometry: LineString(coordinates: [
///     Position.of([10, 0]),
///     Position.of([10, 10])
///   ])),
///   Feature(geometry: LineString(coordinates: [
///     Position.of([10, 10]),
///     Position.of([0, 10])
///   ])),
///   Feature(geometry: LineString(coordinates: [
///     Position.of([0, 10]),
///     Position.of([0, 0])
///   ]))
/// ]);
///
/// var polygons = polygonize(lines);
/// ```
FeatureCollection<Polygon> polygonize(
  GeoJSONObject geoJSON, {
  PolygonizeConfig? config,
}) {
  return Polygonizer.polygonize(geoJSON, config: config);
}

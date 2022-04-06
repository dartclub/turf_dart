import 'package:turf/bbox.dart';
import 'package:turf/helpers.dart';

/// Takes a {@link Feature} or {@link FeatureCollection} and returns the absolute center point of all features.
///
/// @name center
/// @param {GeoJSON} geojson GeoJSON to be centered
/// @param {Object} [options={}] Optional parameters
/// @param {Object} [options.properties={}] Translate GeoJSON Properties to Point
/// @param {Object} [options.bbox={}] Translate GeoJSON BBox to Point
/// @param {Object} [options.id={}] Translate GeoJSON Id to Point
/// @returns {Feature<Point>} a Point feature at the absolute center point of all input features
/// @example
/// var features = turf.points([
///   [-97.522259, 35.4691],
///   [-97.502754, 35.463455],
///   [-97.508269, 35.463245]
/// ]);
///
/// var center = turf.center(features);
///
/// //addToMap
/// var addToMap = [features, center]
/// center.properties['marker-size'] = 'large';
/// center.properties['marker-color'] = '#000';
Feature<Point> center<P>(GeoJSONObject geoJSON, Map<String, dynamic> options) {
  final ext = bbox(geoJSON);
  final x = (ext[0]! + ext[2]!) / 2;
  final y = (ext[1]! + ext[3]!) / 2;

  return point(Position.named(lat: y, lng: x), options['properties'], options: options);
}

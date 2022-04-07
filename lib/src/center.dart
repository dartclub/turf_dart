import 'package:turf/bbox.dart';
import 'package:turf/helpers.dart';

/// Takes a Feature/FeatureCollection and returns the absolute center point of all features.
///
/// @param GeoJSONObject geojson GeoJSON to be centered
/// @param Map<String, dynamic options Optional parameters
/// @returns Feature<Point> point a Point feature at the absolute center point of all input features
Feature<Point> center<P>(GeoJSONObject geoJSON, Map<String, dynamic> options) {
  final ext = bbox(geoJSON);
  final x = (ext[0]! + ext[2]!) / 2;
  final y = (ext[1]! + ext[3]!) / 2;

  return point(Position.named(lat: y, lng: x), options['properties'], options: options);
}

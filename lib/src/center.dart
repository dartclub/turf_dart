import 'package:turf/bbox.dart';
import 'package:turf/helpers.dart';

/// Takes a [Feature]/[FeatureCollection] and returns the absolute center point of all features.
Feature<Point> center<P>(GeoJSONObject geoJSON, {Map<String, dynamic>? options}) {
  final ext = bbox(geoJSON);
  final x = (ext[0]! + ext[2]!) / 2;
  final y = (ext[1]! + ext[3]!) / 2;

  return Feature<Point>(
    id: options?['id'],
    bbox: options?['bbox'],
    properties: options?['properties'],
    geometry: Point(coordinates: Position.named(lat: y, lng: x)),
  );
}

import 'package:turf/bbox.dart' as t;
import 'package:turf/helpers.dart';

/// Takes a [Feature] or a [FeatureCollection] and returns the absolute center point of all feature(s).
Feature<Point> center(
  GeoJSONObject geoJSON, {
  dynamic id,
  BBox? bbox,
  Map<String, dynamic>? properties,
}) {
  final BBox ext = t.bbox(geoJSON);
  final double x = (ext[0]! + ext[2]!) / 2;
  final double y = (ext[1]! + ext[3]!) / 2;

  return Feature<Point>(
    id: id,
    bbox: bbox,
    properties: properties,
    geometry: Point(coordinates: Position.named(lat: y, lng: x)),
  );
}

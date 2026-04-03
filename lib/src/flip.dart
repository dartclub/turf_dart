import 'package:turf/turf.dart';
import 'package:turf/meta.dart';

/// Swap lat/lng of a Position
Position flipPosition(Position pos) => Position.named(
      lat: pos.lng,
      lng: pos.lat,
    );

/// Flip the coordinates of a Feature, with proper typing for each geometry
Feature<GeometryType> flip(Feature<GeometryType>? geojson) {
  if (geojson == null) {
    throw ArgumentError('geojson cannot be null');
  }

  final geometry = geojson.geometry;
  if (geometry == null) return geojson;

  if (geometry is Point) {
    geojson.geometry = Point(
      coordinates: flipPosition(geometry.coordinates),
    );
  } else if (geometry is MultiPoint) {
    geojson.geometry = MultiPoint(
      coordinates: geometry.coordinates.map(flipPosition).toList(),
    );
  } else if (geometry is LineString) {
    geojson.geometry = LineString(
      coordinates: geometry.coordinates.map(flipPosition).toList(),
    );
  } else if (geometry is MultiLineString) {
    geojson.geometry = MultiLineString(
      coordinates: geometry.coordinates
          .map((line) => line.map(flipPosition).toList())
          .toList(),
    );
  } else if (geometry is Polygon) {
    geojson.geometry = Polygon(
      coordinates: geometry.coordinates
          .map((ring) => ring.map(flipPosition).toList())
          .toList(),
    );
  } else if (geometry is MultiPolygon) {
    geojson.geometry = MultiPolygon(
      coordinates: geometry.coordinates
          .map(
            (polygon) => polygon
                .map((ring) => ring.map(flipPosition).toList())
                .toList(),
          )
          .toList(),
    );
  }

  return geojson;
}
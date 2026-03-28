import 'package:turf/turf.dart';
import 'package:turf/meta.dart';

// Takes a set of input Coordinate features and flips their Coordinates from Position(x,y) to Position(y, x) 

// Returns a GeoJSON FeatureCollection with the flipped Coordinates

Feature<GeometryType> flip(Feature<GeometryType>? geojson) {
  if (geojson == null) {
    throw ArgumentError('geojson cannot be null');
  }

  final geometry = geojson.geometry;

  if (geometry is Point) {
    geojson.geometry = Point(
      coordinates: Position.named(
        lat: geometry.coordinates.lng, // swap lat and lng
        lng: geometry.coordinates.lat,
      ),
    );
    return geojson;
  }

  if (geometry is Polygon) {
    final flippedCoords = geometry.coordinates.map((ring) {
      return ring.map((pos) => Position.named(
        lat: pos.lng,  // swap lat and lng
        lng: pos.lat,
      )).toList();
    }).toList();

    geojson.geometry = Polygon(coordinates: flippedCoords);
    return geojson;
  }

  return geojson;
}

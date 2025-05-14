import 'package:turf/turf.dart';
import 'package:turf/meta.dart';

// Takes a set of input Coordinate features and flips their Coordinates from Position(x,y) to Position(y, x) 

// Returns a GeoJSON FeatureCollection with the flipped Coordinates

Feature<GeometryType> flip(Feature<GeometryType>? geojson,
{Map<String,dynamic>? properties, }) {
  if (geojson == null) {
    throw ArgumentError('geojson cannot be null');
  }  

  coordEach(
    geojson,
    (Position? currentCoord, int? coordIndex, int? featureIndex, int? multiFeatureIndex, int? geometryIndex) {
      currentCoord = Position.named(lat: currentCoord!.lng, lng: currentCoord.lat);
    }
  );

  return geojson;
}

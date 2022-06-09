import 'package:turf/helpers.dart';
import 'package:turf/meta.dart';

/**
 * Takes a feature or set of features and returns all positions as {@link Point|points}.
 *
 * @name explode
 * @param {GeoJSON} geojson input features
 * @returns {FeatureCollection<point>} points representing the exploded input features
 * @throws {Error} if it encounters an unknown geometry type
 * @example
 * var polygon = turf.polygon([[[-81, 41], [-88, 36], [-84, 31], [-80, 33], [-77, 39], [-81, 41]]]);
 *
 * var explode = turf.explode(polygon);
 *
 * //addToMap
 * var addToMap = [polygon, explode]
 */
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

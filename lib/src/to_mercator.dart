import 'dart:math';
import '../meta.dart';

// EPSG:3857 / 900913 constants
const double _a = 6378137.0;
const double _maxExtent = 20037508.342789244;
const double _d2r = pi / 180;

/// Converts a single WGS84 [lonLat] position to Web Mercator (EPSG:3857).
/// Altitude (Z) is preserved unchanged.
Position _convertToMercator(Position lonLat) {
  final lngDouble = lonLat.lng.toDouble();
  final latDouble = lonLat.lat.toDouble();

  final adjusted =
      lngDouble.abs() <= 180 ? lngDouble : lngDouble - _sign(lngDouble) * 360;

  var x = _a * adjusted * _d2r;
  var y = _a * log(tan(pi * 0.25 + 0.5 * latDouble * _d2r));

  // If xy value is beyond maxExtent (e.g. near poles), clamp to maxExtent
  if (x > _maxExtent) x = _maxExtent;
  if (x < -_maxExtent) x = -_maxExtent;
  if (y > _maxExtent) y = _maxExtent;
  if (y < -_maxExtent) y = -_maxExtent;

  return lonLat.alt != null ? Position(x, y, lonLat.alt) : Position(x, y);
}

/// Returns the sign of [x]: -1, 0, or 1.
int _sign(double x) => x < 0 ? -1 : (x > 0 ? 1 : 0);

/// Converts a WGS84 GeoJSON object into Web Mercator (EPSG:3857 / 900913)
/// projection.
///
/// Supports [Point], [MultiPoint], [LineString], [MultiLineString],
/// [Polygon], [MultiPolygon], [GeometryCollection], [Feature], and
/// [FeatureCollection].
///
/// - [geojson]: The input GeoJSON object with WGS84 coordinates.
/// - [mutate]: If `true`, modifies [geojson] in place for a significant
///   performance increase. Defaults to `false`, which clones the input first.
///
/// Returns the projected GeoJSON in Web Mercator coordinates (metres).
///
/// Example:
/// ```dart
/// var pt = Feature(geometry: Point(coordinates: Position(-71, 41)));
/// var converted = geoToMercator(pt);
/// ```
GeoJSONObject geoToMercator(GeoJSONObject geojson, {bool mutate = false}) {
  final output = mutate ? geojson : geojson.clone();
  geomEach(
    output,
    (
      GeometryType? currentGeometry,
      int? featureIndex,
      Map<String, dynamic>? featureProperties,
      BBox? featureBBox,
      dynamic featureId,
    ) {
      if (currentGeometry == null) return;

      coordEach(
        currentGeometry,
        (
          Position? currentCoord,
          int? coordIndex,
          int? featureIndex,
          int? multiFeatureIndex,
          int? geometryIndex,
          int? localCoordIndex,
        ) {
          if (currentCoord == null) return;
          final converted = _convertToMercator(currentCoord);

          if (currentGeometry is Point) {
            currentGeometry.coordinates = converted;
          } else if (currentGeometry is LineString ||
              currentGeometry is MultiPoint) {
            currentGeometry.coordinates[localCoordIndex!] = converted;
          } else if (currentGeometry is Polygon) {
            currentGeometry.coordinates[geometryIndex!][localCoordIndex!] =
                converted;
          } else if (currentGeometry is MultiLineString) {
            currentGeometry.coordinates[multiFeatureIndex!][localCoordIndex!] =
                converted;
          } else if (currentGeometry is MultiPolygon) {
            currentGeometry.coordinates[multiFeatureIndex!][geometryIndex!]
                [localCoordIndex!] = converted;
          }
        },
      );
    },
  );

  return output;
}

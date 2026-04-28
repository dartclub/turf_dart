import 'dart:math';
import '../meta.dart';

// EPSG:3857 / 900913 constants
const double _a = 6378137.0;
const double _r2d = 180 / pi;

/// Converts a single Web Mercator [xy] position to WGS84.
/// Altitude (Z) is preserved unchanged.
Position _convertToWgs84(Position xy) {
  final lon = (xy.lng.toDouble() * _r2d) / _a;
  final lat = (pi * 0.5 - 2.0 * atan(exp(-xy.lat.toDouble() / _a))) * _r2d;

  return xy.alt != null ? Position(lon, lat, xy.alt) : Position(lon, lat);
}

/// Converts a Web Mercator (EPSG:3857 / 900913) GeoJSON object back into
/// WGS84 projection.
///
/// Supports [Point], [MultiPoint], [LineString], [MultiLineString],
/// [Polygon], [MultiPolygon], [GeometryCollection], [Feature], and
/// [FeatureCollection].
///
/// - [geojson]: The input GeoJSON object with Web Mercator coordinates.
/// - [mutate]: If `true`, modifies [geojson] in place for a significant
///   performance increase. Defaults to `false`, which clones the input first.
///
/// Returns the converted GeoJSON with WGS84 coordinates (degrees).
///
/// Example:
/// ```dart
/// var pt = Feature(
///   geometry: Point(coordinates: Position(-7903683.846322424, 5012341.663847514)),
/// );
/// var converted = geoToWgs84(pt);
/// ```
GeoJSONObject geoToWgs84(GeoJSONObject geojson, {bool mutate = false}) {
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
          final converted = _convertToWgs84(currentCoord);

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

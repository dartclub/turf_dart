import 'package:turf/helpers.dart';
import '../meta.dart';

/// Takes a [Feature] or [FeatureCollection] and truncates the precision of the geometry.
/// [precision] sets the coordinate decimal precision
/// [coordinates] sets the maximum number of coordinates (primarly used to remove z coordinates)
/// [mutate] allows [GeoJSONObject] input to be mutated (significant performance increase if true)
/// Returns [GeoJSONObject] layer with truncated geometry
/// example:
/// var point = Point(coordinates: Position.of([
///     70.46923055566859,
///     58.11088890802906,
///     1508
/// ]));
/// var truncated = truncate(point, precision: 3, coordinates: 2);
/// //=truncated.geometry.coordinates => [70.469, 58.111]
/// //addToMap
/// var addToMap = [truncated];
GeoJSONObject truncate(
  GeoJSONObject geojson, {
  int precision = 6,
  int coordinates = 3,
  bool mutate = false,
}) {
  GeoJSONObject newGeojson = mutate ? geojson : geojson.clone();

  // Truncate Coordinates
  if (coordAll(newGeojson).isNotEmpty) {
    _replaceCoords(precision, coordinates, newGeojson);
    return newGeojson;
  } else {
    return newGeojson;
  }
}

void _replaceCoords(int precision, int coordinates, GeoJSONObject geojson) {
  geomEach(
    geojson,
    (
      GeometryType? currentGeometry,
      int? featureIndex,
      Map<String, dynamic>? featureProperties,
      BBox? featureBBox,
      dynamic featureId,
    ) {
      coordEach(
        currentGeometry!,
        (
          Position? currentCoord,
          int? coordIndex,
          int? featureIndex,
          int? multiFeatureIndex,
          int? geometryIndex,
        ) {
          if (currentGeometry is Point) {
            currentGeometry.coordinates =
                _truncateCoords(currentCoord!, precision, coordinates);
          } else if (currentGeometry is LineString) {
            currentGeometry.coordinates[coordIndex!] =
                _truncateCoords(currentCoord!, precision, coordinates);
          } else if (currentGeometry is Polygon) {
            currentGeometry.coordinates[geometryIndex!][coordIndex!] =
                _truncateCoords(currentCoord!, precision, coordinates);
          } else if (currentGeometry is MultiLineString) {
            currentGeometry.coordinates[multiFeatureIndex!][coordIndex!] =
                _truncateCoords(currentCoord!, precision, coordinates);
          } else if (currentGeometry is MultiPolygon) {
            currentGeometry.coordinates[multiFeatureIndex!][geometryIndex!]
                    [coordIndex!] =
                _truncateCoords(currentCoord!, precision, coordinates);
          } else {
            (currentGeometry as GeometryCollection).geometries.forEach(
              (element) {
                _replaceCoords(precision, coordinates, geojson);
              },
            );
          }
        },
      );
    },
  );
}

/// Truncate Coordinates - Mutates coordinates in place
/// [factor] is the rounding factor for coordinate decimal precision
/// [coordinates] sets maximum number of coordinates (primarly used to remove z coordinates)
/// Returns mutated coordinates
Position _truncateCoords(Position coord, num factor, int coordinates) {
  // Remove extra coordinates (usually elevation coordinates and more)
  List<num> list = [];
  list.addAll([coord.lng, coord.lat]);
  if (coord.alt != null) {
    list.add(coord.alt!);
  }

  if (list.length > coordinates) {
    list = list.sublist(0, coordinates);
  }

  // Truncate coordinate decimals
  for (var i = 0; i < list.length; i++) {
    list[i] = round(list[i], factor);
  }
  return Position.of(list);
}

import 'dart:math';

import 'package:turf/helpers.dart';
import '../meta.dart';

/// Takes a [Feature] or [FeatureCollection] and truncates the precision of the geometry.
/// [precision=6] sets the coordinate decimal precision
/// [options.coordinates=3] sets the maximum number of coordinates (primarly used to remove z coordinates)
/// [options.mutate=false] allows [GeoJSONObject] input to be mutated (significant performance increase if true)
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
GeoJSONObject truncat(
  GeoJSONObject geojson, {
  int precision = 6,
  int coordinates = 3,
  bool mutate = false,
}) {
  // // prevent input mutation
  // if (mutate === false || mutate === undefined)
  //   geojson = JSON.parse(JSON.stringify(geojson));

  var factor = pow(10, precision);

  // Truncate Coordinates
  if (coordAll(geojson).isNotEmpty) {
    coordEach(
      geojson,
      (
        Position? currentCoord,
        int? coordIndex,
        int? featureIndex,
        int? multiFeatureIndex,
        int? geometryIndex,
      ) {
        currentCoord = _truncateCoords(currentCoord!, factor, coordinates);
      },
    );
    return geojson;
  } else {
    throw Exception("geojson has no coordinates");
  }
}

/// Truncate Coordinates - Mutates coordinates in place
/// [factor] is the rounding factor for coordinate decimal precision
/// @param {number} coordinates maximum number of coordinates (primarly used to remove z coordinates)
/// Returns [List] mutated coordinates
_truncateCoords(Position coord, num factor, int coordinates) {
  // Remove extra coordinates (usually elevation coordinates and more)
  List<num> list = [];
  list.addAll([coord.lat, coord.lng]);
  if (coord.alt != null) {
    list.add(coord.alt!);
  }

  if (list.length > coordinates) {
    list = list.sublist(0, coordinates - 1);
  }

  // Truncate coordinate decimals
  for (var i = 0; i < list.length; i++) {
    list[i] = round(list[i] * factor) / factor;
  }
  return Position.of(list);
}

import '../helpers.dart';

List<num> getCoord(dynamic coord) {
  if (coord is! Feature<Point> && coord is! Point && coord is! List<num>) {
    throw Exception('coord must be Feature<Point> | Point | List<num>');
  }

  if (coord is Feature<Point>) {
    return coord.geometry?.coordinates.toList().whereType<num>().toList() ?? [];
  } else if (coord is Point) {
    return coord.coordinates.whereType<num>().toList();
  } else if (coord is List<num> && coord.length >= 2) {
    return coord;
  }

  throw Exception('coord must be GeoJSON Point or an Array of numbers');
}

T? getGeom<T extends GeometryType>(dynamic geojson) {
  if (geojson is Feature<T>) {
    return geojson.geometry;
  } else if (geojson is T) {
    return geojson;
  } else {
    throw Exception('geojson must be T or a Feature<T>');
  }
}

import '../helpers.dart';

/// Converts a [Polygon] to [LineString] or [MultiLineString] or a [MultiPolygon]
/// to a [FeatureCollection] of [LineString] or [MultiLineString].
/// Returns [FeatureCollection] or [Feature<LineString>] or [Feature<MultiLinestring>]
/// example:
/// ```dart
/// var poly = Polygon(coordinates:
///  [
///   [
///   Position.of([125, -30]),
///   Position.of([145, -30]),
///   Position.of([145, -20]),
///   Position.of([125, -20]),
///   Position.of([125, -30])
///   ]
/// ]);
/// var line = polygonToLine(poly);
/// //addToMap
/// var addToMap = [line];
/// ```
GeoJSONObject polygonToLine(GeoJSONObject poly,
    {Map<String, dynamic>? properties}) {
  var geom = poly is Feature ? poly.geometry : poly;

  properties =
      properties ?? ((poly is Feature) ? poly.properties : <String, dynamic>{});

  if (geom is Polygon) {
    return _polygonToLine(geom, properties: properties);
  } else if (geom is MultiPolygon) {
    return _multiPolygonToLine(geom, properties: properties);
  } else {
    throw Exception("invalid poly");
  }
}

Feature _polygonToLine(Polygon geom, {Map<String, dynamic>? properties}) {
  var coords = geom.coordinates;
  properties = properties ?? <String, dynamic>{};

  return _coordsToLine(coords, properties);
}

FeatureCollection _multiPolygonToLine(MultiPolygon geom,
    {Map<String, dynamic>? properties}) {
  var coords = geom.coordinates;
  properties = properties ?? <String, dynamic>{};

  var lines = <Feature>[];
  for (var coord in coords) {
    lines.add(_coordsToLine(coord, properties));
  }
  return FeatureCollection(features: lines);
}

Feature _coordsToLine(
    List<List<Position>> coords, Map<String, dynamic>? properties) {
  if (coords.isEmpty) {
    throw RangeError("coordinates is empty");
  } else if (coords.length > 1) {
    return Feature(
        geometry: MultiLineString(coordinates: coords), properties: properties);
  }
  return Feature(
      geometry: LineString(coordinates: coords[0]), properties: properties);
}

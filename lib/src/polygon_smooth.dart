import 'package:turf/meta.dart';
import 'package:turf/turf.dart';

///
/// Smooths a [Polygon], [MultiPolygon], also inside [Feature]s, [FeatureCollection]s, or [GeometryCollection]. Based on [Chaikin's algorithm](http://graphics.cs.ucdavis.edu/education/CAGDNotes/Chaikins-Algorithm/Chaikins-Algorithm.html).
/// Warning: may create degenerate polygons.
/// The optional parameter [iterations] is the number of times to smooth the polygon. A higher value means a smoother polygon.
/// The functions returns a [FeatureCollection] of [Polygon]s and [MultiPolygon]s.
///
/// ```dart
/// var polygon = Polygon(coordinates: [
///     [
///         Position(11, 0),
///         Position(22, 4),
///         Position(31, 0),
///         Position(31, 11),
///         Position(21, 15),
///         Position(11, 11),
///         Position(11, 0),
///     ]
/// ]);
///
/// var smoothed = polygonSmooth(polygon, iterations: 3);
/// ```
FeatureCollection polygonSmooth(GeoJSONObject inputPolys,
    {int iterations = 1}) {
  var outPolys = <Feature>[];

  geomEach(inputPolys, (
    GeometryType? geom,
    int? geomIndex,
    Map<String, dynamic>? featureProperties,
    BBox? featureBBox,
    dynamic featureId,
  ) {
    dynamic outCoords;
    dynamic poly;
    dynamic tempOutput;

    switch (geom?.type) {
      case GeoJSONObjectType.polygon:
        outCoords = <List<Position>>[[]];
        for (var i = 0; i < iterations; i++) {
          tempOutput = <List<Position>>[[]];
          poly = geom;
          if (i > 0) poly = Polygon(coordinates: outCoords);
          _processPolygon(poly, tempOutput);
          outCoords = List<List<Position>>.of(tempOutput);
        }
        outPolys.add(Feature(
            geometry: Polygon(coordinates: outCoords),
            properties: featureProperties));
        break;
      case GeoJSONObjectType.multiPolygon:
        outCoords = [
          [<Position>[]]
        ];
        for (var y = 0; y < iterations; y++) {
          tempOutput = <List<List<Position>>>[
            [[]]
          ];
          poly = geom;
          if (y > 0) poly = MultiPolygon(coordinates: outCoords);
          _processMultiPolygon(poly, tempOutput);
          outCoords = List<List<List<Position>>>.of(tempOutput);
        }
        outPolys.add(Feature(
            geometry: MultiPolygon(coordinates: outCoords),
            properties: featureProperties));
        break;
      default:
        throw Exception("geometry is invalid, must be Polygon or MultiPolygon");
    }
  });
  return FeatureCollection(features: outPolys);
}

void _processPolygon(Polygon poly, List<List<Position>> tempOutput) {
  var prevGeomIndex = 0;
  var subtractCoordIndex = 0;

  coordEach(poly, (currentCoord, coordIndex, featureIndex, multiFeatureIndex,
      geometryIndex) {
    if (geometryIndex! > prevGeomIndex) {
      prevGeomIndex = geometryIndex;
      subtractCoordIndex = coordIndex!;
      tempOutput.add([]);
    }
    var realCoordIndex = coordIndex! - subtractCoordIndex;
    var p1 = poly.coordinates[geometryIndex][realCoordIndex + 1];
    var p0x = currentCoord!.lng;
    var p0y = currentCoord.lat;
    var p1x = p1.lng;
    var p1y = p1.lat;
    tempOutput[geometryIndex].add(Position(
      0.75 * p0x + 0.25 * p1x,
      0.75 * p0y + 0.25 * p1y,
    ));
    tempOutput[geometryIndex].add(Position(
      0.25 * p0x + 0.75 * p1x,
      0.25 * p0y + 0.75 * p1y,
    ));
  }, true);
  for (var ring in tempOutput) {
    ring.add(ring[0]);
  }
}

void _processMultiPolygon(poly, List<List<List<Position>>> tempOutput) {
  var prevGeomIndex = 0;
  var subtractCoordIndex = 0;
  var prevMultiIndex = 0;

  coordEach(poly, (currentCoord, coordIndex, featureIndex, multiFeatureIndex,
      geometryIndex) {
    if (multiFeatureIndex! > prevMultiIndex) {
      prevMultiIndex = multiFeatureIndex;
      subtractCoordIndex = coordIndex!;
      tempOutput.add([[]]);
    }
    if (geometryIndex! > prevGeomIndex) {
      prevGeomIndex = geometryIndex;
      subtractCoordIndex = coordIndex!;
      tempOutput[multiFeatureIndex].add([]);
    }
    var realCoordIndex = coordIndex! - subtractCoordIndex;
    if (realCoordIndex + 1 ==
        poly.coordinates[multiFeatureIndex][geometryIndex].length) {
      return;
    }
    var p1 =
        poly.coordinates[multiFeatureIndex][geometryIndex][realCoordIndex + 1];
    var p0x = currentCoord!.lng;
    var p0y = currentCoord.lat;
    var p1x = p1.lng;
    var p1y = p1.lat;
    tempOutput[multiFeatureIndex][geometryIndex].add(Position(
      0.75 * p0x + 0.25 * p1x,
      0.75 * p0y + 0.25 * p1y,
    ));
    tempOutput[multiFeatureIndex][geometryIndex].add(Position(
      0.25 * p0x + 0.75 * p1x,
      0.25 * p0y + 0.75 * p1y,
    ));
  }, true);

  for (var poly in tempOutput) {
    for (var ring in poly) {
      ring.add(ring[0]);
    }
  }
}

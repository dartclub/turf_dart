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
    var outCoords;
    var poly;
    var tempOutput;

    switch (geom?.type) {
      case GeoJSONObjectType.polygon:
        outCoords = [<Position>[]];
        for (var i = 0; i < iterations; i++) {
          tempOutput = [[]];
          poly = geom;
          if (i > 0) poly = Polygon(coordinates: outCoords);
          _processPolygon(poly, tempOutput);
          outCoords = tempOutput.slice(0);
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
          tempOutput = [
            [<Position>[]]
          ];
          poly = geom;
          if (y > 0) poly = Polygon(coordinates: outCoords);
          _processMultiPolygon(poly, tempOutput);
          outCoords = tempOutput.slice(0);
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

_processPolygon(Polygon poly, tempOutput) {
  var prevGeomIndex = 0;
  var subtractCoordIndex = 0;

  coordEach(poly, (currentCoord, coordIndex, featureIndex, multiFeatureIndex,
      geometryIndex) {
    if (geometryIndex! > prevGeomIndex) {
      prevGeomIndex = geometryIndex;
      subtractCoordIndex = coordIndex!;
      tempOutput.push([]);
    }
    var realCoordIndex = coordIndex! - subtractCoordIndex;
    var p1 = poly.coordinates[geometryIndex][realCoordIndex + 1];
    var p0x = currentCoord!.lng;
    var p0y = currentCoord.lat;
    var p1x = p1.lng;
    var p1y = p1.lat;
    tempOutput[geometryIndex].push(Position(
      0.75 * p0x + 0.25 * p1x,
      0.75 * p0y + 0.25 * p1y,
    ));
    tempOutput[geometryIndex].push(Position(
      0.25 * p0x + 0.75 * p1x,
      0.25 * p0y + 0.75 * p1y,
    ));
  }, true);
  tempOutput.forEach((ring) {
    ring.add(ring[0]);
  });
}

_processMultiPolygon(poly, tempOutput) {
  var prevGeomIndex = 0;
  var subtractCoordIndex = 0;
  var prevMultiIndex = 0;

  coordEach(poly, (currentCoord, coordIndex, featureIndex, multiFeatureIndex,
      geometryIndex) {
    if (multiFeatureIndex! > prevMultiIndex) {
      prevMultiIndex = multiFeatureIndex;
      subtractCoordIndex = coordIndex!;
      tempOutput.push([[]]);
    }
    if (geometryIndex! > prevGeomIndex) {
      prevGeomIndex = geometryIndex;
      subtractCoordIndex = coordIndex!;
      tempOutput[multiFeatureIndex].push([]);
    }
    var realCoordIndex = coordIndex! - subtractCoordIndex;
    var p1 =
        poly.coordinates[multiFeatureIndex][geometryIndex][realCoordIndex + 1];
    var p0x = currentCoord!.lng;
    var p0y = currentCoord.lat;
    var p1x = p1.lng;
    var p1y = p1.lat;
    tempOutput[multiFeatureIndex][geometryIndex].push(Position(
      0.75 * p0x + 0.25 * p1x,
      0.75 * p0y + 0.25 * p1y,
    ));
    tempOutput[multiFeatureIndex][geometryIndex].push(Position(
      0.25 * p0x + 0.75 * p1x,
      0.25 * p0y + 0.75 * p1y,
    ));
  }, true);

  tempOutput.forEach((poly) {
    poly.forEach((ring) {
      ring.add(ring[0]);
    });
  });
}

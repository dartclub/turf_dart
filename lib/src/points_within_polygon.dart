
import 'package:turf/meta.dart';
import 'package:turf/src/booleans/boolean_point_in_polygon.dart';

/// Returns every Point (or the subset of coordinates of
/// a MultiPoint) that falls inside at least one Polygon/MultiPolygon.
///
/// The geometry type of each returned feature matches
/// its input type:  Point ➜ Point,  MultiPoint ➜ trimmed MultiPoint.
FeatureCollection<GeometryObject> pointsWithinPolygon(
  GeoJSONObject points,
  GeoJSONObject polygons,
) {
  final List<Feature<GeometryObject>> results = [];

  // Iterate over each Point or MultiPoint feature
  featureEach(points, (Feature current, int? _) {
    bool contained = false;

    final geom = current.geometry;
    if (geom is Point) {
      // Check a single Point against every polygon
      geomEach(polygons, (poly, __, ___, ____, _____) {
        if (booleanPointInPolygon(geom.coordinates, poly as GeoJSONObject)) {
          contained = true;
        }
      });
      if (contained) results.add(current);
    }

    else if (geom is MultiPoint) {
      final inside = <Position>[];

      // Test every coordinate of the MultiPoint
      geomEach(polygons, (poly, __, ___, ____, _____) {
        for (final pos in geom.coordinates) {
          if (booleanPointInPolygon(pos, poly as GeoJSONObject)) {
            contained = true;
            inside.add(pos);
          }
        }
      });

      if (contained) {
        results.add(
          Feature<MultiPoint>(
            geometry: MultiPoint(coordinates: inside),
            properties: current.properties,
            id: current.id,
            bbox: current.bbox,
          ) as Feature<GeometryObject>,
        );
      }
    }

    else {
      throw ArgumentError('Input geometry must be Point or MultiPoint');
    }
  });

  return FeatureCollection<GeometryObject>(features: results);
}

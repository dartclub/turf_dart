import 'package:geotypes/geotypes.dart';
import 'package:turf/meta.dart';
import 'package:polyclip-dart/polyclip.dart'; // TSubject to change as per polyclip-dart changes

/* Takes a collection of input polygons and returns a combined polygon. If the
  input polygons are not contiguous, this function returns a multi-polygon
  feature.
 
  @param features input polygon features
  @param [properties={}] Optional Properties to assign to output feature
  @returns a combined polygon or multi-polygon feature, or null if there were no input polygons to combine
 
  @example
  var poly1 = polygon([
    [
      [-82.574787, 35.594087],
      [-82.574787, 35.615581],
      [-82.545261, 35.615581],
      [-82.545261, 35.594087],
      [-82.574787, 35.594087],
    ]
  ], properties: { 'fill': '#0f0' });
 
  var poly2 = polygon([
    [
      [-82.560024, 35.585153],
      [-82.560024, 35.602602],
      [-82.52964, 35.602602],
      [-82.52964, 35.585153],
      [-82.560024, 35.585153],
    ]
  ]);
 
 var union = turf.union(featureCollection([poly1, poly2]));
 */
Feature<dynamic>? union(FeatureCollection features,
    {Map<String, dynamic>? properties}) {
  final geoms = <List<dynamic>>[];

  // Extract geometries from features
  geomEach(features,
      (geom, featureIndex, featureProperties, featureBBox, featureId) {
    if (geom != null && geom.coordinates != null) {
      geoms.add(geom.coordinates as List<dynamic>);
    }
  });

  if (geoms.length < 2) {
    throw Exception('Must have at least 2 geometries');
  }

  // Use polyclip library to find union
  final unioned = Polyclip.union(geoms[0], [...geoms.sublist(1)]);

  if (unioned.isEmpty) {
    return null;
  }

  if (unioned.length == 1) {
    // Create a polygon feature
    final polygonGeometry =
        Polygon(coordinates: unioned[0] as List<List<Position>>);
    return Feature(geometry: polygonGeometry, properties: properties ?? {});
  }

  // Create a multipolygon feature
  final multiPolygonGeometry =
      MultiPolygon(coordinates: unioned as List<List<List<Position>>>);
  return Feature(geometry: multiPolygonGeometry, properties: properties ?? {});
}

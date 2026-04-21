import 'package:geotypes/geotypes.dart';
import 'package:turf/meta.dart';
import 'package:polyclip-dart/polyclip.dart'; // Polyclip-dart import (to be fixed)

// Coded the same as intersect on turf.js. Subject to change based on how polyclip-dart will read geojson objects.

/* Takes [Polygon] or [MultiPolygon] geometries and
 finds their polygonal intersection. If they don't intersect, returns null.

 @param features the features to intersect
 @param [properties={}] Optional Properties to translate to Feature
 @returns returns a feature representing the area they share (either a [Polygon] or
 [MultiPolygon]). If they do not share any area, returns `null`.

 @example
 ```dart
 var poly1 = polygon([
   [
     [-122.801742, 45.48565],
     [-122.801742, 45.60491],
     [-122.584762, 45.60491],
     [-122.584762, 45.48565],
     [-122.801742, 45.48565]
   ]
 ]);

 var poly2 = polygon([
   [
     [-122.520217, 45.535693],
     [-122.64038, 45.553967],
     [-122.720031, 45.526554],
     [-122.669906, 45.507309],
     [-122.723464, 45.446643],
     [-122.532577, 45.408574],
     [-122.487258, 45.477466],
     [-122.520217, 45.535693]
   ]
 ]);

 var intersection = intersect(featureCollection([poly1, poly2]));
*/
Feature<dynamic>? intersect(FeatureCollection features, {Map<String, dynamic>? properties}) {
  final geoms = <List<dynamic>>[];
  
  // Extract geometries from features
  geomEach(features, (geom, featureIndex, featureProperties, featureBBox, featureId) {
    if (geom != null && geom.coordinates != null) {
      geoms.add(geom.coordinates as List<dynamic>);
    }
  });
  
  if (geoms.length < 2) {
    throw Exception('Must specify at least 2 geometries');
  }
  
  // Use polyclip library to find intersection
  final intersection = Polyclip.intersection(geoms[0], [...geoms.sublist(1)]);
  
  if (intersection.isEmpty) {
    return null;
  }
  
  if (intersection.length == 1) {
    // Create a polygon feature
    final polygonGeometry = Polygon(coordinates: intersection[0] as List<List<Position>>);
    return Feature(geometry: polygonGeometry, properties: properties ?? {});
  }
  
  // Create a multipolygon feature
  final multiPolygonGeometry = MultiPolygon(
    coordinates: intersection as List<List<List<Position>>>
  );
  return Feature(geometry: multiPolygonGeometry, properties: properties ?? {});
}
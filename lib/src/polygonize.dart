/// Implementation of the polygonize algorithm that converts a collection of
/// LineString features to a collection of Polygon features.
/// 
/// This implementation follows RFC 7946 (GeoJSON) standards for ring orientation:
/// - Exterior rings are counter-clockwise (CCW)
/// - Interior rings (holes) are clockwise (CW)
///
/// The algorithm includes:
/// 1. Building a planar graph of all line segments
/// 2. Finding rings using the right-hand rule for consistent traversal
/// 3. Classifying rings as exterior or holes based on containment
/// 4. Creating proper polygon geometries with correct orientation

import 'package:turf/helpers.dart';
import 'package:turf/src/invariant.dart';

import 'polygonize/polygonize.dart';

/// Converts a collection of LineString features to a collection of Polygon features.
///
/// Takes a [FeatureCollection<LineString>] and returns a [FeatureCollection<Polygon>].
/// The input features must be correctly noded, meaning they should only meet at their endpoints.
///
/// Example:
/// ```dart
/// var lines = FeatureCollection(features: [
///   Feature(geometry: LineString(coordinates: [
///     Position.of([0, 0]),
///     Position.of([10, 0])
///   ])),
///   Feature(geometry: LineString(coordinates: [
///     Position.of([10, 0]),
///     Position.of([10, 10])
///   ])),
///   Feature(geometry: LineString(coordinates: [
///     Position.of([10, 10]),
///     Position.of([0, 10])
///   ])),
///   Feature(geometry: LineString(coordinates: [
///     Position.of([0, 10]),
///     Position.of([0, 0])
///   ]))
/// ]);
///
/// var polygons = polygonize(lines);
/// ```
FeatureCollection<Polygon> polygonize(GeoJSONObject geoJSON) {
  return Polygonizer.polygonize(geoJSON);
}

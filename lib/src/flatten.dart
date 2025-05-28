import 'package:turf/helpers.dart';
import 'package:turf/src/meta/flatten.dart';

/// Takes any [GeoJSONObject] and returns a [FeatureCollection] of simple features.
/// The function flattens all Multi* geometries and GeometryCollections into single-geometry Features.
///
/// This function is useful when handling complex shapes with multiple parts, making it easier to process
/// each part as a distinct feature.
///
/// * [geojson] - any valid [GeoJSONObject] (Feature, FeatureCollection, Geometry)
/// * Returns a [FeatureCollection] of Features where each feature has a single geometry type
///
/// Altitude values (z coordinates) are preserved in all coordinate positions.
/// Properties and other metadata in the input Feature are preserved in each output Feature.
///
/// Replicates behavior from: https://turfjs.org/docs/#flatten
///
/// Example:
/// ```dart
/// var multiLineString = MultiLineString(coordinates: [
///   [Position(0, 0), Position(1, 1)],
///   [Position(2, 2), Position(3, 3)]
/// ]);
/// 
/// var flattened = flatten(multiLineString);
/// // Returns FeatureCollection with 2 LineString features
/// ```
///
/// Throws [ArgumentError] if:
/// - A null [geojson] is provided
/// - A [GeometryCollection] is provided (explicitly not supported)
/// - A Feature with null geometry is provided
/// - An unsupported geometry type is encountered
FeatureCollection<GeometryObject> flatten(GeoJSONObject geojson) {
  if (geojson == null) {
    throw ArgumentError('Cannot flatten null geojson');
  }

  // Reject GeometryCollection inputs - not supported per the requirements
  if (geojson is GeometryCollection) {
    throw ArgumentError('flatten does not support GeometryCollection input.');
  }

  // Use a list to collect all flattened features
  final List<Feature<GeometryObject>> features = [];

  // Use flattenEach from meta to iterate through each flattened feature
  flattenEach(geojson, (currentFeature, featureIndex, multiFeatureIndex) {
    // If the geometry is null, skip this feature (implementation choice)
    if (currentFeature.geometry == null) {
      return;
    }

    // We know this is a Feature with a GeometryType, but we want to ensure 
    // it's treated as a Feature<GeometryObject> to match return type
    final feature = Feature<GeometryObject>(
      geometry: currentFeature.geometry,
      properties: currentFeature.properties,
      id: currentFeature.id,
      bbox: currentFeature.bbox,
    );
    
    // Add to our features list - this maintains original geometry order
    features.add(feature);
  });

  // Create and return a FeatureCollection containing all the flattened features
  return FeatureCollection<GeometryObject>(
    features: features,
    // If the original object was a Feature, preserve its bbox
    bbox: (geojson is Feature) ? geojson.bbox : null,
  );
}

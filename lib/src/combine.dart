import 'package:turf/meta.dart';

/// Combines a [FeatureCollection] of Point, LineString or Polygon features
/// into a single MultiPoint, MultiLineString or MultiPolygon feature.
///
/// The [collection] must be a FeatureCollection of the same geometry type.
/// Supported types are Point, LineString, and Polygon.
///
/// Returns a [Feature] with a Multi* geometry containing all coordinates from the input collection.
/// Throws [ArgumentError] if features have inconsistent geometry types or unsupported types.
///
/// If [mergeProperties] is true, properties from the first feature will be preserved.
/// Otherwise, properties will be empty by default.
///
/// See: https://turfjs.org/docs/#combine
Feature combine(
  FeatureCollection collection, {
  bool mergeProperties = false,
}) {
  // Validate that the collection is not empty
  if (collection.features.isEmpty) {
    throw ArgumentError('FeatureCollection must contain at least one feature');
  }

  // Get the geometry type of the first feature to validate consistency
  final firstFeature = collection.features.first;
  final geometryType = firstFeature.geometry?.runtimeType;
  if (geometryType == null) {
    throw ArgumentError('Feature must have a geometry');
  }
  
  final firstGeometry = firstFeature.geometry!;

  // Ensure all features have the same geometry type
  for (final feature in collection.features) {
    final geometry = feature.geometry;
    if (geometry == null) {
      throw ArgumentError('All features must have a geometry');
    }
    
    if (geometry.runtimeType != firstGeometry.runtimeType) {
      throw ArgumentError(
        'All features must have the same geometry type. '
        'Found: ${geometry.type}, expected: ${firstGeometry.type}',
      );
    }
  }

  // Set of properties to include in result if mergeProperties is true
  final properties = mergeProperties && firstFeature.properties != null 
      ? Map<String, dynamic>.from(firstFeature.properties!)
      : <String, dynamic>{};

  // Create the appropriate geometry based on type
  GeometryObject resultGeometry;
  
  if (firstGeometry is Point) {
    // Combine all Point coordinates into a single MultiPoint
    final coordinates = <Position>[];
    for (final feature in collection.features) {
      final point = feature.geometry as Point;
      coordinates.add(point.coordinates);
    }
    
    resultGeometry = MultiPoint(coordinates: coordinates);
  } else if (firstGeometry is LineString) {
    // Combine all LineString coordinate arrays into a MultiLineString
    final coordinates = <List<Position>>[];
    for (final feature in collection.features) {
      final line = feature.geometry as LineString;
      coordinates.add(line.coordinates);
    }
    
    resultGeometry = MultiLineString(coordinates: coordinates);
  } else if (firstGeometry is Polygon) {
    // Combine all Polygon coordinate arrays into a MultiPolygon
    final coordinates = <List<List<Position>>>[];
    for (final feature in collection.features) {
      final polygon = feature.geometry as Polygon;
      coordinates.add(polygon.coordinates);
    }
    
    resultGeometry = MultiPolygon(coordinates: coordinates);
  } else {
    // Throw if unsupported geometry type is encountered
    throw ArgumentError(
      'Unsupported geometry type: ${firstGeometry.type}. '
      'Only Point, LineString, and Polygon are supported.',
    );
  }

  // Create the Feature result
  final result = Feature(
    geometry: resultGeometry,
    properties: properties,
  );
  
  // Apply otherMembers from the first feature to preserve GeoJSON compliance
  final resultJson = result.toJson();
  final firstFeatureJson = firstFeature.toJson();
  
  // Copy any non-standard GeoJSON fields (otherMembers)
  firstFeatureJson.forEach((key, value) {
    if (key != 'type' && key != 'geometry' && key != 'properties' && key != 'id') {
      resultJson[key] = value;
    }
  });
  
  // Return the result with otherMembers preserved
  return Feature.fromJson(resultJson);
}

import 'package:turf/helpers.dart';

/// Callback for featureEach
typedef FeatureEachCallback = dynamic Function(
  Feature currentFeature,
  int featureIndex,
);

/// Iterates over features in any [geoJSONObject], calling [callback] on each
/// iteration. Similar to [Iterable.forEach].
/// For example:
///
/// ```dart
/// FeatureCollection featureCollection = FeatureCollection(
///   features: [
///     point1,
///     point2,
///     point3,
///   ],
/// );
/// featureEach(featureCollection, (currentFeature, featureIndex) {
///   someOperationOnEachFeature(currentFeature);
/// });
/// ```
void featureEach(GeoJSONObject geoJSON, FeatureEachCallback callback) {
  if (geoJSON is Feature) {
    callback(geoJSON, 0);
  } else if (geoJSON is FeatureCollection) {
    for (var i = 0; i < geoJSON.features.length; i++) {
      if (callback(geoJSON.features[i], i) == false) break;
    }
  } else {
    throw Exception('Unknown Feature/FeatureCollection Type');
  }
}

/// Callback for featureReduce
///
/// The first time the callback function is called, the values provided as arguments depend
/// on whether the reduce method has an initialValue argument.
///
/// If an initialValue is provided to the reduce method:
///  - The previousValue argument is initialValue.
///  - The currentValue argument is the value of the first element present in the List.
///
/// If an initialValue is not provided:
///  - The previousValue argument is the value of the first element present in the List.
///  - The currentValue argument is the value of the second element present in the List.
///
/// FeatureReduceCallback
/// [previousValue] is the accumulated value previously returned in the last invocation
/// of the callback, or [initialValue], if supplied.
/// currentFeature is the current [Feature] being processed.
/// [featureIndex] is the current index of the [Feature] being processed.

typedef FeatureReduceCallback<T> = T? Function(
  T? previousValue, // todo or Feature ?
  Feature currentFeature,
  int featureIndex,
);

/// Reduces features in any GeoJSONObject, similar to [Iterable.reduce].
///
/// Takes [FeatureCollection], [Feature], or [GeometryObject],
/// a [FeatureReduceCallback] method that takes (previousValue, currentFeature, featureIndex), and
/// an [initialValue] Value to use as the first argument to the first call of the callback.
/// Returns the value that results from the reduction.
/// For example:
///
/// ```dart
/// var features = FeatureCollection(features: [
///   Feature(geometry: Point(coordinates: Position.of([26, 37])), properties: {'foo': 'bar'}),
///   Feature(geometry: Point(coordinates: Position.of([36, 53])), properties: {'foo': 'bar'})
/// ]);
///
/// featureReduce(features, (previousValue, currentFeature, featureIndex) {
///   //=previousValue
///   //=currentFeature
///   //=featureIndex
///   return currentFeature
/// });
/// ```

T? featureReduce<T>(
  GeoJSONObject geojson,
  FeatureReduceCallback<T> callback,
  T? initialValue,
) {
  T? previousValue = initialValue;
  featureEach(geojson, (currentFeature, featureIndex) {
    if (featureIndex == 0 && initialValue == null && currentFeature is T) {
      previousValue = currentFeature.clone() as T;
    } else {
      previousValue = callback(previousValue, currentFeature, featureIndex);
    }
  });
  return previousValue;
}

/// Extension on [Feature] that adds copyWith functionality similar to the turf.js implementation.
extension FeatureExtension on Feature {
  /// Creates a copy of this [Feature] with the specified options overridden.
  /// 
  /// This allows creating a modified copy of the [Feature] without changing the original instance.
  /// The implementation follows the pattern used in turf.js, enabling a familiar and
  /// consistent API across the Dart and JavaScript implementations.
  /// 
  /// Type parameter [G] extends [GeometryObject] and specifies the type of geometry for the
  /// returned Feature. This should typically match the original geometry type or be compatible
  /// with it. The method includes runtime type checking to help prevent type errors.
  /// 
  /// Parameters:
  /// - [id]: Optional new id for the feature. If not provided, the original id is retained.
  /// - [properties]: Optional new properties for the feature. If not provided, the original 
  ///   properties are retained. Note that this completely replaces the properties object.
  /// - [geometry]: Optional new geometry for the feature. If not provided, the original geometry 
  ///   is retained. Must be an instance of [G] or null.
  /// - [bbox]: Optional new bounding box for the feature. If not provided, the original bbox is retained.
  ///
  /// Returns a new [Feature<G>] instance with the specified properties overridden.
  /// 
  /// Throws an [ArgumentError] if the geometry parameter is provided but is not compatible
  /// with the specified generic type [G].
  /// 
  /// Example:
  /// ```dart
  /// final feature = Feature<Point>(
  ///   id: 'point-1',
  ///   geometry: Point(coordinates: Position(0, 0)),
  ///   properties: {'name': 'Original'}
  /// );
  /// 
  /// // Create a copy with the same geometry type
  /// final modifiedFeature = feature.copyWith<Point>(
  ///   properties: {'name': 'Modified', 'category': 'landmark'},
  ///   geometry: Point(coordinates: Position(10, 20)),
  /// );
  /// 
  /// // If changing geometry type, be explicit about the new type
  /// final polygonFeature = feature.copyWith<Polygon>(
  ///   geometry: Polygon(coordinates: [[
  ///     Position(0, 0),
  ///     Position(1, 0),
  ///     Position(1, 1),
  ///     Position(0, 0),
  ///   ]]),
  /// );
  /// ```
  Feature<G> copyWith<G extends GeometryObject>({
    dynamic id,
    Map<String, dynamic>? properties,
    G? geometry,
    BBox? bbox,
  }) {
    // Runtime type checking for geometry
    if (geometry != null && geometry is! G) {
      throw ArgumentError('Provided geometry must be of type $G');
    }
    
    // If we're not changing the geometry and the current geometry is not null,
    // verify it's compatible with the target type G
    final currentGeometry = this.geometry;
    if (geometry == null && currentGeometry != null && currentGeometry is! G) {
      throw ArgumentError(
          'Current geometry of type ${currentGeometry.runtimeType} is not compatible with target type $G. '
          'Please provide a geometry parameter of type $G.');
    }
    
    return Feature<G>(
      id: id ?? this.id,
      properties: properties ?? this.properties,
      geometry: geometry ?? (currentGeometry as G?),
      bbox: bbox ?? this.bbox,
    );
  }
}

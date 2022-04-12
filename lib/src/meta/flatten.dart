import 'package:turf/helpers.dart';
import 'package:turf/src/meta/geom.dart';
import 'package:turf/src/meta/short_circuit.dart';

/// Callback for flattenEach
typedef FlattenEachCallback = dynamic Function(
  Feature<GeometryType> currentFeature,
  int featureIndex,
  int multiFeatureIndex,
);

/// Iterates over flattened features in any [geoJSONObject], similar to
/// [Iterate.forEach], calling [callback] on each flattened feature
///```dart
/// flattenEach(featureCollection, (currentFeature, featureIndex, multiFeatureIndex) {
///   someOperationOnEachFeature(currentFeature);
/// });
/// ```
void flattenEach(GeoJSONObject geoJSON, FlattenEachCallback callback) {
  try {
    geomEach(geoJSON, (GeometryType? currentGeomObject, featureIndex,
        featureProperties, featureBBox, featureId) {
      if (currentGeomObject == null ||
          currentGeomObject is Point ||
          currentGeomObject is LineString ||
          currentGeomObject is Polygon) {
        _callFlattenEachCallback(callback, currentGeomObject as GeometryType,
            featureProperties, featureIndex, 0);
      } else {
        _forEachFeatureOfMultiFeature(
            currentGeomObject, callback, featureProperties, featureIndex);
      }
    });
  } on ShortCircuit {
    return;
  }
}

void _forEachFeatureOfMultiFeature(
    GeoJSONObject currentGeomObject,
    FlattenEachCallback callback,
    Map<String, dynamic>? featureProperties,
    int? featureIndex) {
  if (currentGeomObject is GeometryType) {
    for (int multiFeatureIndex = 0;
        multiFeatureIndex < currentGeomObject.coordinates.length;
        multiFeatureIndex++) {
      GeometryType geom;
      if (currentGeomObject is MultiPoint) {
        geom = Point(
            coordinates: currentGeomObject.coordinates[multiFeatureIndex]);
      } else if (currentGeomObject is MultiLineString) {
        geom = LineString(
            coordinates: currentGeomObject.coordinates[multiFeatureIndex]);
      } else if (currentGeomObject is MultiPolygon) {
        geom = Polygon(
            coordinates: currentGeomObject.coordinates[multiFeatureIndex]);
      } else {
        throw Exception('Unsupported Geometry type');
      }
      _callFlattenEachCallback(
          callback, geom, featureProperties, featureIndex, multiFeatureIndex);
    }
  }
}

void _callFlattenEachCallback(
    FlattenEachCallback callback,
    GeometryType<dynamic> geom,
    Map<String, dynamic>? featureProperties,
    int? featureIndex,
    int multiFeatureIndex) {
  if (callback(
          Feature<GeometryType>(
            geometry: geom,
            properties: featureProperties,
          ),
          featureIndex ?? 0,
          multiFeatureIndex) ==
      false) {
    throw ShortCircuit();
  }
}

/// Callback for flattenReduce
/// The first time the callback function is called, the values provided as
/// arguments depend on whether the reduce method has an [initialValue] argument.
/// If an [initialValue] is provided to the reduce method:
///  - The [previousValue] argument is initialValue.
///  - The [currentValue] argument is the value of the first element present in the
/// [List].
/// If an [initialValue] is not provided:
///  - The [previousValue] argument is the value of the first element present in
/// the [List].
///  - The [currentValue] argument is the value of the second element present in
/// the [List].
///
/// flattenReduceCallback
/// [previousValue] is the accumulated value previously returned in the
/// last invocation of the callback, or [initialValue], if supplied.
/// [currentFeature] is the current Feature being processed.
/// [featureIndex] is the current index of the Feature being processed.
/// [multiFeatureIndex] is the current index of the Multi-Feature being
/// processed.
typedef FlattenReduceCallback<T> = T? Function(T? previousValue,
    Feature currentFeature, int featureIndex, int multiFeatureIndex);

/// Reduces flattened features in any [GeoJSONObject], similar to [Iterable.reduce].
/// Takes a [FeatureCollection], [Feature], or [Geometry]
/// a [FlattenReduceCallback] method that takes (previousValue, currentFeature, featureIndex, multiFeatureIndex),
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
/// flattenReduce(features, (previousValue, currentFeature, featureIndex, multiFeatureIndex) {
///   //=previousValue
///   //=currentFeature
///   //=featureIndex
///   //=multiFeatureIndex
///   return currentFeature
/// });
/// ```

T? flattenReduce<T>(
  GeoJSONObject geojson,
  FlattenReduceCallback<T> callback,
  T? initialValue,
) {
  T? previousValue = initialValue;
  flattenEach(geojson, (currentFeature, featureIndex, multiFeatureIndex) {
    if (featureIndex == 0 &&
        multiFeatureIndex == 0 &&
        initialValue == null &&
        currentFeature is T) {
      previousValue = currentFeature.clone() as T;
    } else {
      previousValue = callback(
          previousValue, currentFeature, featureIndex, multiFeatureIndex);
    }
  });
  return previousValue;
}

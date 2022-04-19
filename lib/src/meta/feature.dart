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

import 'package:turf/helpers.dart';

/// Callback for propEach
typedef PropEachCallback = dynamic Function(
  Map<String, dynamic>? currentProperties,
  int featureIndex,
);

/// Iterates over properties in any [geoJSON] object, calling [callback] on each
/// iteration. Similar to [Iterable.forEach]
///
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
/// propEach(featureCollection, (currentProperties, featureIndex) {
///   someOperationOnEachProperty(currentProperties);
/// });
/// ```
void propEach(GeoJSONObject geoJSON, PropEachCallback callback) {
  if (geoJSON is FeatureCollection) {
    for (var i = 0; i < geoJSON.features.length; i++) {
      if (callback(geoJSON.features[i].properties, i) == false) break;
    }
  } else if (geoJSON is Feature) {
    callback(geoJSON.properties, 0);
  } else {
    throw Exception('Unknown Feature/FeatureCollection Type');
  }
}

/// Callback for propReduce
///
/// The first time the callback function is called, the values provided as arguments depend
/// on whether the reduce method has an [initialValue] argument.
///
/// If an [initialValue] is provided to the reduce method:
///  - The [previousValue] argument is initialValue.
///  - The [currentValue] argument is the value of the first element present in the [List].
///
/// If an [initialValue] is not provided:
///  - The [previousValue] argument is the value of the first element present in the [List].
///  - The [currentValue] argument is the value of the second element present in the [List].
///
/// propReduceCallback
/// [previousValue] The accumulated value previously returned in the last invocation
/// of the callback, or [initialValue], if supplied.
/// [currentProperties] The current Properties being processed.
/// [featureIndex] The current index of the Feature being processed.
typedef PropReduceCallback<T> = T? Function(
  T? previousValue, // todo: or 'Map<String, dynamic>?'?
  Map<String, dynamic>? currentProperties,
  int featureIndex,
);

/// Reduces properties in any [GeoJSONObject] into a single value,
/// similar to how [Iterable.reduce] works. However, in this case we lazily run
/// the reduction, so List of all properties is unnecessary.
///
/// Takes any [FeatureCollection] or [Feature], a [PropReduceCallback], an [initialValue]
/// to be used as the first argument to the first call of the callback.
/// Returns the value that results from the reduction.
/// For example:
///
/// ```dart
/// var features = FeatureCollection(features: [
///   Feature(geometry: Point(coordinates: Position.of([26, 37])), properties: {'foo': 'bar'}),
///   Feature(geometry: Point(coordinates: Position.of([36, 53])), properties: {'foo': 'bar'})
/// ]);
///
/// propReduce(features, (previousValue, currentProperties, featureIndex) {
///   //=previousValue
///   //=currentProperties
///   //=featureIndex
///   return currentProperties
/// });
/// ```

T? propReduce<T>(
  GeoJSONObject geojson,
  PropReduceCallback<T> callback,
  T? initialValue,
) {
  T? previousValue = initialValue;
  propEach(geojson, (currentProperties, featureIndex) {
    if (featureIndex == 0 && initialValue == null) {
      previousValue = currentProperties != null
          ? Map<String, dynamic>.of(currentProperties) as T
          : null;
    } else {
      previousValue = callback(previousValue, currentProperties, featureIndex);
    }
  });
  return previousValue;
}

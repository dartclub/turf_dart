import 'package:turf/helpers.dart';
import 'package:turf/src/meta/short_circuit.dart';

typedef GeomEachCallback = dynamic Function(
  GeometryType? currentGeometry,
  int? featureIndex,
  Map<String, dynamic>? featureProperties,
  BBox? featureBBox,
  dynamic featureId,
);

/// Iterates over each geometry in [geoJSON], calling [callback] on each
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
/// geomEach(featureCollection, (currentGeometry, featureIndex, featureProperties, featureBBox, featureId) {
///   someOperationOnEachPoint(currentGeometry);
/// });
/// ```
void geomEach(GeoJSONObject geoJSON, GeomEachCallback callback) {
  try {
    if (geoJSON is FeatureCollection) {
      _forEachGeomInFeatureCollection(geoJSON, callback);
    } else if (geoJSON is Feature) {
      _forEachGeomInFeature(geoJSON, callback, 0);
    } else if (geoJSON is GeometryObject) {
      _forEachGeomInGeometryObject(geoJSON, callback, {}, null, null, 0);
    } else {
      throw Exception('Unknown Geometry Type');
    }
  } on ShortCircuit {
    return;
  }
}

void _forEachGeomInFeatureCollection(
    FeatureCollection featureCollection, GeomEachCallback callback) {
  int featuresLength = featureCollection.features.length;
  for (int featureIndex = 0; featureIndex < featuresLength; featureIndex++) {
    _forEachGeomInFeature(
        featureCollection.features[featureIndex], callback, featureIndex);
  }
}

void _forEachGeomInFeature(Feature<GeometryObject> feature,
    GeomEachCallback callback, int featureIndex) {
  _forEachGeomInGeometryObject(feature.geometry, callback, feature.properties,
      feature.bbox, feature.id, featureIndex);
}

void _forEachGeomInGeometryObject(
    GeometryObject? geometryObject,
    GeomEachCallback callback,
    Map<String, dynamic>? featureProperties,
    BBox? featureBBox,
    dynamic featureId,
    int featureIndex) {
  if (geometryObject is GeometryType) {
    if (callback(
          geometryObject,
          featureIndex,
          featureProperties,
          featureBBox,
          featureId,
        ) ==
        false) {
      throw ShortCircuit();
    }
  } else if (geometryObject is GeometryCollection) {
    int geometryCollectionLength = geometryObject.geometries.length;

    for (int geometryIndex = 0;
        geometryIndex < geometryCollectionLength;
        geometryIndex++) {
      _forEachGeomInGeometryObject(
        geometryObject.geometries[geometryIndex],
        callback,
        featureProperties,
        featureBBox,
        featureId,
        featureIndex,
      );
    }
  } else {
    throw Exception('Unknown Geometry Type');
  }
}

/// Callback for geomReduce
///
/// The first time the callback function is called, the values provided as arguments depend
/// on whether the reduce method has an [initialValue] argument.
///
/// If an initialValue is provided to the reduce method:
///  - The [previousValue] argument is [initialValue].
///  - The [currentValue] argument is the value of the first element present in the [List].
///
/// If an [initialValue] is not provided:
///  - The [previousValue] argument is the value of the first element present in the [List].
///  - The [currentGeometry] argument is the value of the second element present in the [List].
typedef GeomReduceCallback<T> = T? Function(
  T? previousValue,
  GeometryType? currentGeometry,
  int? featureIndex,
  Map<String, dynamic>? featureProperties,
  BBox? featureBBox,
  dynamic featureId,
);

/// Reduces geometry in any [GeoJSONObject], similar to [Iterable.reduce].
///
/// Takes [FeatureCollection], [Feature] or [GeometryObject], a [GeomReduceCallback] method
/// that takes (previousValue, currentGeometry, featureIndex, featureProperties, featureBBox, featureId) and
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
/// geomReduce(features, (previousValue, currentGeometry, featureIndex, featureProperties, featureBBox, featureId) {
///   //=previousValue
///   //=currentGeometry
///   //=featureIndex
///   //=featureProperties
///   //=featureBBox
///   //=featureId
///   return currentGeometry
/// });
/// ```

T? geomReduce<T>(
  GeoJSONObject geoJSON,
  GeomReduceCallback<T> callback,
  T? initialValue,
) {
  T? previousValue = initialValue;
  geomEach(
    geoJSON,
    (
      currentGeometry,
      featureIndex,
      featureProperties,
      featureBBox,
      featureId,
    ) {
      if (previousValue == null && featureIndex == 0 && currentGeometry is T) {
        previousValue = currentGeometry?.clone() as T;
      } else {
        previousValue = callback(
          previousValue,
          currentGeometry,
          featureIndex,
          featureProperties,
          featureBBox,
          featureId,
        );
      }
    },
  );
  return previousValue;
}

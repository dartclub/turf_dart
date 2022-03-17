import 'geojson.dart';

typedef GeomEachCallback = dynamic Function(
  GeometryType? currentGeometry,
  int? featureIndex,
  Map<String, dynamic>? featureProperties,
  BBox? featureBBox,
  dynamic featureId,
);

/// A simple class to manage short circuiting from *Each functions while still
/// allowing an Exception to be thrown and raised
class _ShortCircuit {
  _ShortCircuit();
}

/// Iterate over each geometry in [geoJSON], calling [callback] on each
/// iteration. Similar to[ List.forEach()]
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
  } on _ShortCircuit {
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
      throw _ShortCircuit();
    }
  } else if (geometryObject is GeometryCollection) {
    num geometryCollectionLength = geometryObject.geometries.length;

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
/// on whether the reduce method has an initialValue argument.
///
/// If an initialValue is provided to the reduce method:
///  - The previousValue argument is initialValue.
///  - The currentValue argument is the value of the first element present in the [List].
///
/// If an initialValue is not provided:
///  - The previousValue argument is the value of the first element present in the [List].
///  - The currentValue argument is the value of the second element present in the [List].
typedef GeomReduceCallback<T> = T? Function(
  T? previousValue,
  GeometryType? currentGeometry,
  int? featureIndex,
  Map<String, dynamic>? featureProperties,
  BBox? featureBBox,
  dynamic featureId,
);

/// Reduce geometry in any [GeoJSONObject], similar to [iterable.reduce()].
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
      if (previousValue == null && featureIndex == 0) {
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

/// Callback for propEach
typedef PropEachCallback = dynamic Function(
    Map<String, dynamic>? currentProperties, num featureIndex);

/// Iterate over properties in any [geoJSON] object, calling [callback] on each
/// iteration. Similar to [Iterable.forEach()]
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

/// Callback for featureEach
typedef FeatureEachCallback = dynamic Function(
    Feature currentFeature, num featureIndex);

/// Iterate over features in any [geoJSON] object, calling [callback] on each
/// iteration. Similar to [Iterable.forEach()].
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
///
typedef PropReduceCallback = dynamic Function(
    dynamic previousValue, // todo: or 'Map<String, dynamic>?'?
    Map<String, dynamic>? currentProperties,
    num featureIndex);

/// Reduce properties in any [GeoJSONObject] into a single value,
/// similar to how [Iterable.reduce()] works. However, in this case we lazily run
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
/// ````

Map<String, dynamic>? propReduce(GeoJSONObject geojson,
    PropReduceCallback callback, Map<String, dynamic>? initialValue) {
  var previousValue = initialValue;
  propEach(geojson, (currentProperties, featureIndex) {
    if (featureIndex == 0 && initialValue == null) {
      previousValue = currentProperties;
    } else {
      previousValue = callback(previousValue, currentProperties, featureIndex);
    }
  });
  return previousValue;
}

/// Callback for featureReduce
///
/// The first time the callback function is called, the values provided as arguments depend
/// on whether the reduce method has an initialValue argument.
///
/// If an initialValue is provided to the reduce method:
///  - The previousValue argument is initialValue.
///  - The currentValue argument is the value of the first element present in the array.
///
/// If an initialValue is not provided:
///  - The previousValue argument is the value of the first element present in the array.
///  - The currentValue argument is the value of the second element present in the array.
///
/// FeatureReduceCallback
/// [previousValue] is the accumulated value previously returned in the last invocation
/// of the callback, or [initialValue], if supplied.
/// currentFeature is the current [Feature] being processed.
/// [featureIndex] is the current index of the [Feature] being processed.

typedef FeatureReduceCallback = dynamic Function(
    dynamic previousValue, // todo or Feature ?
    Feature currentFeature,
    num featureIndex);

/// Reduce features in any GeoJSONObject, similar to [List.reduce()].
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

featureReduce(
    GeometryObject geojson, FeatureReduceCallback callback, initialValue) {
  var previousValue = initialValue;
  featureEach(geojson, (currentFeature, featureIndex) {
    if (featureIndex == 0 && initialValue == null) {
      previousValue = currentFeature;
    } else {
      previousValue = callback(previousValue, currentFeature, featureIndex);
    }
  });
  return previousValue;
}

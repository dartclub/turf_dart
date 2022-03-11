import 'geojson.dart';

typedef GeomEachCallback = dynamic Function(
  GeometryObject? currentGeometry,
  int? featureIndex,
  Map<String, dynamic>? featureProperties, // what about fields?
  BBox? featureBBox,
  dynamic featureId,
);

/// A simple class to manage short circuiting from *Each functions while still
/// allowing an Exception to be thrown and raised
class _ShortCircuit {
  _ShortCircuit();
}

/// Iterates over each geometry in [geoJSON], calling [callback] on each
/// iteration. Similar to Iterable.forEach()
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

/// Callback for propEach
typedef PropEachCallback = dynamic Function(
    Map<String, dynamic>? currentProperties, int featureIndex);

/// Iterate over properties in any [geoJSONObject], calling [callback] on each
/// iteration. Similar to [Iterable].forEach()
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

/// Callback for flattenEach
typedef FlattenEachCallback = dynamic Function(
    Feature currentFeature, int featureIndex, int multiFeatureIndex);

/// Iterates over flattened features in any [GeoJSONObject], similar to
/// [Iterable.forEach()].
///
/// Gets [FeatureCollection], [Feature], [GeometryType], [GeoJSONObject]
/// and a [FlattenEachCallback] a method that takes (currentFeature, featureIndex, multiFeatureIndex)
/// For example:
///
/// ```dart
/// var features = turf.featureCollection([
///     turf.point([26, 37], {foo: 'bar'}),
///     turf.multiPoint([[40, 30], [36, 53]], {hello: 'world'})
/// ]);
///
/// flattenEach(features, function (currentFeature, featureIndex, multiFeatureIndex) {
///   //=currentFeature
///   //=featureIndex
///   //=multiFeatureIndex
/// });
/// ```
void flattenEach(GeoJSONObject geojson, GeomEachCallback callback) {
  geomEach(geojson, callback);
}

/// Callback for featureEach
typedef FeatureEachCallback = dynamic Function(
    Feature currentFeature, int featureIndex);

/// Iterate over features in any [GeoJSONObject], calling [callback] on each
/// iteration. Similar to Array.forEach.
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

/// Callback for flattenReduce
///
/// Gets [previousValue] The accumulated value previously returned in the last invocation
/// of the callback, or [initialValue], if supplied.
/// /**
/// * Callback for flattenReduce
/// *
/// * The first time the callback function is called, the values provided as arguments depend
/// * on whether the reduce method has an initialValue argument.
/// *
/// * If an initialValue is provided to the reduce method:
/// *  - The previousValue argument is initialValue.
/// *  - The currentValue argument is the value of the first element present in the array.
/// *
/// * If an initialValue is not provided:
/// *  - The previousValue argument is the value of the first element present in the array.
/// *  - The currentValue argument is the value of the second element present in the array.
/// */
/// [Feature] currentFeature The current Feature being processed.
/// [int] featureIndex The current index of the [Feature] being processed.
/// [int] multiFeatureIndex The current index of the Multi-Feature being processed.
 @TODO: //armantorkzaban // needs to be of type GeomEachCallback
/* typedef FlattenReduceCallback = Function(
    dynamic previousValue, // or an initialValue
    Feature currentFeature,
    int featureIndex,
    int multiFeatureIndex);

 
*/ 
/// Reduce flattened features in any [GeoJSONObject], similar to [Iterable.reduce()].
///
/// Gets a [FeatureCollection], [Feature],[GeometryType], [GeoJSONObject],
/// an optional [initialValue] Value to use as the first argument to the first
/// call of the [FlattenReduceCallback], calls this [FlattenReduceCallback] method and
/// returns a dynamic value that results from the reduction.
/// For example:
///
/// ```dart
/// var features = FeatureCollection([
///     Feature(geometry: Point(coordiantes: Position.from([26, 37])), properties: {foo: 'bar'}),
///     Feature(geommetry: MultiPoint(coordinates: [Position.from([40, 30])), Position.from([36, 53], {hello: 'world'})
/// ]);
///
/// flattenReduce(features, function (previousValue, currentFeature, featureIndex, multiFeatureIndex) {
///   //=previousValue
///   //=currentFeature
///   //=featureIndex
///   //=multiFeatureIndex
///   return currentFeature
/// });
/// ```
///
Feature flattenReduce(GeometryObject geojson, GeomEachCallback callback,
    [dynamic initialValue]) {
  var previousValue = initialValue;
  flattenEach(geojson, (
    GeometryObject? currentGeometry,
    int? featureIndex,
    Map<String, dynamic>? featureProperties, // what about fields?
    BBox? featureBBox,
    dynamic featureId,
  ) {
    if (featureIndex == 0 &&
        // multiFeatureIndex == 0 &&
        initialValue == null) {
      previousValue = currentGeometry;
    } else {
      previousValue = callback(currentGeometry,
          previousValue, featureIndex, null, null);
    }
  });
  return previousValue;
}

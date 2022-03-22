import 'geojson.dart';

typedef CoordEachCallback = dynamic Function(
  Position? currentCoord,
  int? coordIndex,
  int? featureIndex,
  int? multiFeatureIndex,
  int? geometryIndex,
);

/// Iterates over coordinates in any [geoJSON] object, similar to [Iterable.forEach]
///
/// For example:
///
/// ```dart
/// var features = FeatureCollection(features: [
///   Feature(geometry: Point(coordinates: Position.of([26, 37])), properties: {'foo': 'bar'}),
///   Feature(geometry: Point(coordinates: Position.of([36, 53])), properties: {'foo': 'bar'})
/// ]);
///
/// coordEach(features, (currentCoord, coordIndex, featureIndex, multiFeatureIndex, geometryIndex) {
///  //=currentCoord
///  //=coordIndex
///  //=featureIndex
///  //=multiFeatureIndex
///  //=geometryIndex
/// });
/// ```
void coordEach(GeoJSONObject geoJSON, CoordEachCallback callback,
    [bool excludeWrapCoord = false]) {
  _IndexCounter indexCounter = _IndexCounter();
  try {
    geomEach(
      geoJSON,
      (
        GeometryType? currentGeometry,
        int? featureIndex,
        featureProperties,
        featureBBox,
        featureId,
      ) {
        if (currentGeometry == null) return;

        indexCounter.featureIndex = featureIndex ?? 0;

        _forEachCoordInGeometryObject(
            currentGeometry, callback, excludeWrapCoord, indexCounter);
      },
    );
  } on _ShortCircuit {
    return;
  }
}

void _forEachCoordInGeometryObject(
    GeometryType geometry,
    CoordEachCallback callback,
    bool excludeWrapCoord,
    _IndexCounter indexCounter) {
  GeoJSONObjectType geomType = geometry.type;
  int wrapShrink = excludeWrapCoord &&
          (geomType == GeoJSONObjectType.polygon ||
              geomType == GeoJSONObjectType.multiLineString)
      ? 1
      : 0;
  indexCounter.multiFeatureIndex = 0;

  var coords = geometry.coordinates;
  if (geomType == GeoJSONObjectType.point) {
    _forEachCoordInPoint(coords, callback, indexCounter);
  } else if (geomType == GeoJSONObjectType.lineString ||
      geomType == GeoJSONObjectType.multiPoint) {
    _forEachCoordInCollection(coords, geomType, callback, indexCounter);
  } else if (geomType == GeoJSONObjectType.polygon ||
      geomType == GeoJSONObjectType.multiLineString) {
    _forEachCoordInNestedCollection(
        coords, geomType, wrapShrink, callback, indexCounter);
  } else if (geomType == GeoJSONObjectType.multiPolygon) {
    _forEachCoordInMultiNestedCollection(
        coords, geomType, wrapShrink, callback, indexCounter);
  } else {
    throw Exception('Unknown Geometry Type');
  }
}

void _forEachCoordInMultiNestedCollection(coords, GeoJSONObjectType geomType,
    int wrapShrink, CoordEachCallback callback, _IndexCounter indexCounter) {
  for (var j = 0; j < coords.length; j++) {
    int geometryIndex = 0;
    for (var k = 0; k < coords[j].length; k++) {
      for (var l = 0; l < coords[j][k].length - wrapShrink; l++) {
        if (callback(
                coords[j][k][l],
                indexCounter.coordIndex,
                indexCounter.featureIndex,
                indexCounter.multiFeatureIndex,
                geometryIndex) ==
            false) {
          throw _ShortCircuit();
        }
        indexCounter.coordIndex++;
      }
      geometryIndex++;
    }
    indexCounter.multiFeatureIndex++;
  }
}

void _forEachCoordInNestedCollection(coords, GeoJSONObjectType geomType,
    int wrapShrink, CoordEachCallback callback, _IndexCounter indexCounter) {
  for (var j = 0; j < coords.length; j++) {
    for (var k = 0; k < coords[j].length - wrapShrink; k++) {
      if (callback(
              coords[j][k],
              indexCounter.coordIndex,
              indexCounter.featureIndex,
              indexCounter.multiFeatureIndex,
              indexCounter.geometryIndex) ==
          false) {
        throw _ShortCircuit();
      }
      indexCounter.coordIndex++;
    }
    if (geomType == GeoJSONObjectType.multiLineString) {
      indexCounter.multiFeatureIndex++;
    }
    if (geomType == GeoJSONObjectType.polygon) {
      indexCounter.geometryIndex++;
    }
  }
  if (geomType == GeoJSONObjectType.polygon) {
    indexCounter.multiFeatureIndex++;
  }
}

void _forEachCoordInCollection(coords, GeoJSONObjectType geomType,
    CoordEachCallback callback, _IndexCounter indexCounter) {
  for (var j = 0; j < coords.length; j++) {
    if (callback(coords[j], indexCounter.coordIndex, indexCounter.featureIndex,
            indexCounter.multiFeatureIndex, indexCounter.geometryIndex) ==
        false) {
      throw _ShortCircuit();
    }
    indexCounter.coordIndex++;
    if (geomType == GeoJSONObjectType.multiPoint) {
      indexCounter.multiFeatureIndex++;
    }
  }
  if (geomType == GeoJSONObjectType.lineString) {
    indexCounter.multiFeatureIndex++;
  }
}

void _forEachCoordInPoint(
    Position coords, CoordEachCallback callback, _IndexCounter indexCounter) {
  if (callback(coords, indexCounter.coordIndex, indexCounter.featureIndex,
          indexCounter.multiFeatureIndex, indexCounter.geometryIndex) ==
      false) {
    throw _ShortCircuit();
  }
  indexCounter.coordIndex++;
  indexCounter.multiFeatureIndex++;
}

/// A simple class to manage counters from CoordinateEach functions
class _IndexCounter {
  int coordIndex = 0;
  int geometryIndex = 0;
  int multiFeatureIndex = 0;
  int featureIndex = 0;
}

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

/// Callback for featureEach
typedef FeatureEachCallback = dynamic Function(
  Feature currentFeature,
  int featureIndex,
);

/// Iterates over features in any [geoJSONObject], calling [callback] on each
/// iteration. Similar to [Iterable.forEach].
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

/// Callback for flattenEach
typedef FlattenEachCallback = dynamic Function(
  Feature currentFeature,
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
  } on _ShortCircuit {
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
          Feature(
            geometry: geom,
            properties: featureProperties,
          ),
          featureIndex ?? 0,
          multiFeatureIndex) ==
      false) {
    throw _ShortCircuit();
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
typedef PropReduceCallback<T> = T? Function(
  T? previousValue, // todo: or 'Map<String, dynamic>?'?
  Map<String, dynamic>? currentProperties,
  num featureIndex,
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
  num featureIndex,
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
  GeometryObject geojson,
  FeatureReduceCallback<T> callback,
  T? initialValue,
) {
  // todo: type of the initialValue?
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

//Todo: @armantorkzaban implement tests please.
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

/// Callback for coordReduce
///
/// The first time the callback function is called, the values provided as arguments depend
/// on whether the reduce method has an initialValue argument.
///
/// If an [initialValue] is provided to the reduce method:
///  - The [previousValue] argument is initialValue.
///  - The [currentValue] argument is the value of the first element present in the [List].
///
/// If an [initialValue] is not provided:
///  - The [previousValue] argument is the value of the first element present in the [List].
///  - The [currentValue] argument is the value of the second element present in the [List].
///
/// Takes [previousValue], the accumulated value previously returned in the last invocation
/// of the callback, or [initialValue], if supplied,
/// [Position][currentCoord] The current coordinate being processed, [coordIndex]
/// The current index of the coordinate being processed. Starts at index 0, if an
/// initialValue is provided, and at index 1 otherwise, [featureIndex] The current
/// index of the Feature being processed, [multiFeatureIndex], the current index
/// of the Multi-Feature being processed., and [geometryIndex], the current index of the Geometry being processed.
typedef CoordReduceCallback<T> = T? Function(
  T? previousValue, // todo: change to CoordType
  Position? currentCoord,
  int? coordIndex,
  int? featureIndex,
  int? multiFeatureIndex,
  int? geometryIndex,
);

/// Reduces coordinates in any [GeoJSONObject], similar to [Iterable.reduce]
///
/// Takes [FeatureCollection], [GeometryObject], or a [Feature],
/// a [CoordReduceCallback] method that takes (previousValue, currentCoord, coordIndex), an
/// [initialValue] Value to use as the first argument to the first call of the callback,
/// and a boolean [excludeWrapCoord=false] for whether or not to include the final coordinate
/// of LinearRings that wraps the ring in its iteration.
/// Returns the value that results from the reduction.
/// For example:
///
/// ```dart
/// var features = FeatureCollection(features: [
///   Feature(geometry: Point(coordinates: Position.of([26, 37])), properties: {'foo': 'bar'}),
///   Feature(geometry: Point(coordinates: Position.of([36, 53])), properties: {'foo': 'bar'})
/// ]);
///
/// coordReduce(features, (previousValue, currentCoord, coordIndex, featureIndex, multiFeatureIndex, geometryIndex) {
///   //=previousValue
///   //=currentCoord
///   //=coordIndex
///   //=featureIndex
///   //=multiFeatureIndex
///   //=geometryIndex
///   return currentCoord;
/// });

T? coordReduce<T>(
  GeoJSONObject geojson,
  CoordReduceCallback<T> callback,
  T? initialValue, [
  bool excludeWrapCoord = false,
]) {
  var previousValue = initialValue;
  coordEach(geojson, (currentCoord, coordIndex, featureIndex, multiFeatureIndex,
      geometryIndex) {
    if (coordIndex == 0 && initialValue == null && currentCoord is T) {
      previousValue = currentCoord?.clone() as T;
    } else {
      previousValue = callback(previousValue, currentCoord, coordIndex,
          featureIndex, multiFeatureIndex, geometryIndex);
    }
  }, excludeWrapCoord);
  return previousValue;
}

/// Gets all coordinates from any [GeoJSONObject].
/// Receives any [GeoJSONObject]
/// Returns [List<Position>]
/// For example:
///
/// ```dart
/// var featureColl = FeatureCollection(features:
/// [Feature(geometry: Point(coordinates: Position(13,15)))
/// ,Feature(geometry: LineString(coordinates: [Position(1, 2),
/// Position(67, 50)]))]);
///
/// var coords = coordAll(features);
/// //= [Position(13,15), Position(1, 2), Position(67, 50)]
///
List<Position?> coordAll(GeoJSONObject geojson) {
  List<Position?> coords = [];
  coordEach(geojson, (
    Position? currentCoord,
    int? coordIndex,
    int? featureIndex,
    int? multiFeatureIndex,
    int? geometryIndex,
  ) {
    coords.add(currentCoord);
    return true;
  });
  return coords;
}

import 'geojson.dart';

typedef CoordEachCallback = dynamic Function(
  Position? currentCoord,
  int? coordIndex,
  int? featureIndex,
  int? multiFeatureIndex,
  int? geometryIndex,
);

///
/// Iterate over coordinates in any [geoJSON] object, similar to [Iterable.forEach()]
///
/// For example:
///
/// ```dart
/// //TODO add example
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

/// Callback for propEach
typedef PropEachCallback = dynamic Function(
    Map<String, dynamic>? currentProperties, int featureIndex);

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
    Feature currentFeature, int featureIndex);

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

/// Callback for flattenEach
typedef FlattenEachCallback = dynamic Function(
    Feature currentFeature, int featureIndex, int multiFeatureIndex);

/// Iterate over flattened features in any [geoJSON] object, similar to
/// [Iterable.forEach], calling [callback] on each flattened feature

///
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
  });
  return coords;
}

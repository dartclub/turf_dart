import 'geojson.dart';

typedef CoordEachCallback = dynamic Function(
  Position? currentCoord,
  int? coordIndex,
  int? featureIndex,
  int? multiFeatureIndex,
  int? geometryIndex,
);

///
/// Iterate over coordinates in any [geoJSON] object, similar to Array.forEach()
///
/// For example:
///
/// ```dart
/// //TODO add example
/// ```
void coordEach(GeoJSONObject geoJSON, CoordEachCallback callback,
    [bool excludeWrapCoord = false]) {
  dynamic coords;
  dynamic geometry;
  int stopG;
  GeoJSONObject? geometryMaybeCollection;
  int wrapShrink = 0;
  int coordIndex = 0;
  bool isGeometryCollection;
  bool isFeatureCollection = geoJSON is FeatureCollection;
  bool isFeature = geoJSON is Feature;
  int stop = isFeatureCollection ? geoJSON.features.length : 1;

  try {
    for (var featureIndex = 0; featureIndex < stop; featureIndex++) {
      geometryMaybeCollection = isFeatureCollection
          ? geoJSON.features[featureIndex].geometry
          : isFeature
              ? geoJSON.geometry
              : geoJSON;

      isGeometryCollection = geometryMaybeCollection != null
          ? geometryMaybeCollection is GeometryCollection
          : false;

      stopG =
          isGeometryCollection ? geometryMaybeCollection.geometries.length : 1;

      for (int geomIndex = 0; geomIndex < stopG; geomIndex++) {
        int multiFeatureIndex = 0;
        int geometryIndex = 0;
        geometry = isGeometryCollection
            ? geometryMaybeCollection.geometries[geomIndex]
            : geometryMaybeCollection;

        // Handles null Geometry -- Skips this geometry
        if (geometry == null) {
          continue;
        }
        coords = geometry.coordinates as Iterable;
        GeoJSONObjectType geomType = geometry.type;

        wrapShrink = excludeWrapCoord &&
                (geomType == GeoJSONObjectType.polygon ||
                    geomType == GeoJSONObjectType.multiLineString)
            ? 1
            : 0;

        if (geomType == GeoJSONObjectType.point) {
          if (callback(coords, coordIndex, featureIndex, multiFeatureIndex,
                  geometryIndex) ==
              false) {
            throw _ShortCircuit();
          }
          coordIndex++;
          multiFeatureIndex++;
          break;
        } else if (geomType == GeoJSONObjectType.lineString ||
            geomType == GeoJSONObjectType.multiPoint) {
          for (var j = 0; j < coords.length; j++) {
            if (callback(coords[j], coordIndex, featureIndex, multiFeatureIndex,
                    geometryIndex) ==
                false) {
              throw _ShortCircuit();
            }
            coordIndex++;
            if (geomType == GeoJSONObjectType.multiPoint) {
              multiFeatureIndex++;
            }
          }
          if (geomType == GeoJSONObjectType.lineString) {
            multiFeatureIndex++;
          }
        } else if (geomType == GeoJSONObjectType.polygon ||
            geomType == GeoJSONObjectType.multiLineString) {
          for (var j = 0; j < coords.length; j++) {
            for (var k = 0; k < coords[j].length - wrapShrink; k++) {
              if (callback(coords[j][k], coordIndex, featureIndex,
                      multiFeatureIndex, geometryIndex) ==
                  false) {
                throw _ShortCircuit();
              }
              coordIndex++;
            }
            if (geomType == GeoJSONObjectType.multiLineString) {
              multiFeatureIndex++;
            }
            if (geomType == GeoJSONObjectType.polygon) {
              geometryIndex++;
            }
          }
          if (geomType == GeoJSONObjectType.polygon) {
            multiFeatureIndex++;
          }
        } else if (geomType == GeoJSONObjectType.multiPolygon) {
          for (var j = 0; j < coords.length; j++) {
            geometryIndex = 0;
            for (var k = 0; k < coords[j].length; k++) {
              for (var l = 0; l < coords[j][k].length - wrapShrink; l++) {
                if (callback(coords[j][k][l], coordIndex, featureIndex,
                        multiFeatureIndex, geometryIndex) ==
                    false) {
                  throw _ShortCircuit();
                }
                coordIndex++;
              }
              geometryIndex++;
            }
            multiFeatureIndex++;
          }
        } else if (geomType == GeoJSONObjectType.geometryCollection) {
          for (var j = 0; j < geometry.geometries.length; j++) {
            try {
              coordEach(geometry.geometries[j], callback, excludeWrapCoord);
            } on _ShortCircuit {
              rethrow;
            }
          }
        } else {
          throw Exception('Unknown Geometry Type');
        }
      }
    }
  } on _ShortCircuit {
    return;
  }
}

typedef GeomEachCallback = dynamic Function(
  GeometryObject? currentGeometry,
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
/// iteration. Similar to Array.forEach()
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
    Map<String, dynamic>? currentProperties, num featureIndex);

/// Iterate over properties in any [geoJSON] object, calling [callback] on each
/// iteration. Similar to Array.forEach()
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

/// Gets all coordinates from any [GeoJSONObject].
/// Receives any [GeoJSONObject]
/// Returns List<Position>
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

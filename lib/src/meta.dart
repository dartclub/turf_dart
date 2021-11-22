import 'geojson.dart';

typedef GeomEachCallback = dynamic Function(
  GeometryObject? currentGeometry,
  int? featureIndex,
  Map<String, dynamic> featureProperties,
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
  _forEachGeomInGeometryObject(feature.geometry!, callback, feature.properties!,
      feature.bbox, feature.id, featureIndex);
}

void _forEachGeomInGeometryObject(
    GeometryObject geometryObject,
    GeomEachCallback callback,
    Map<String, dynamic> featureProperties,
    BBox? featureBBox,
    dynamic featureId,
    int featureIndex) {
  GeometryType currentGeometry;
  num geometryCollectionLength = _getGeometryCollectionLength(geometryObject);
  for (int geometryIndex = 0;
      geometryIndex < geometryCollectionLength;
      geometryIndex++) {
    currentGeometry = _getGeometry(geometryObject, geometryIndex);
    _runGeomEachCallbacks(currentGeometry, callback, featureIndex,
        featureProperties, featureBBox, featureId);
  }
}

void _runGeomEachCallbacks(
    GeometryType<dynamic> currentGeometry,
    GeomEachCallback callback,
    int featureIndex,
    Map<String, dynamic> featureProperties,
    BBox? featureBBox,
    dynamic featureId) {
  switch (currentGeometry.type) {
    case GeoJSONObjectTypes.point:
    case GeoJSONObjectTypes.lineString:
    case GeoJSONObjectTypes.multiPoint:
    case GeoJSONObjectTypes.polygon:
    case GeoJSONObjectTypes.multiLineString:
    case GeoJSONObjectTypes.multiPolygon:
      if (callback(
            currentGeometry,
            featureIndex,
            featureProperties,
            featureBBox,
            featureId,
          ) ==
          false) {
        throw _ShortCircuit();
      }
      break;
    case GeoJSONObjectTypes.geometryCollection:
      for (int j = 0;
          j < (currentGeometry as GeometryCollection).geometries.length;
          j++) {
        if (callback(
              (currentGeometry as GeometryCollection).geometries[j],
              featureIndex,
              featureProperties,
              featureBBox,
              featureId,
            ) ==
            false) {
          throw _ShortCircuit();
        }
      }
      break;
    default:
      throw Exception('Unknown Geometry Type');
  }
}

int _getGeometryCollectionLength(GeometryObject geometryObject) {
  return geometryObject is GeometryCollection
      ? geometryObject.geometries.length
      : 1;
}

GeometryType _getGeometry(GeometryObject geometryObject, int index) {
  return geometryObject is GeometryCollection
      ? geometryObject.geometries[index]
      : geometryObject as GeometryType;
}

import 'geojson.dart';

typedef GeomEachCallback = dynamic Function(
  Geometry currentGeometry,
  int featureIndex,
  Map<String, dynamic> featureProperties,
  BBox featureBBox,
  dynamic featureId,
);

/// Iterate over each geometry in any GeoJSON object, similar to Array.forEach()
void geomEach(dynamic geoJSON, GeomEachCallback callback) {
  dynamic geometry;
  var stopG;
  dynamic geometryMaybeCollection;
  bool isGeometryCollection;
  Map<String, dynamic> featureProperties;
  BBox featureBBox;
  var featureId;
  num featureIndex = 0;
  bool isFeatureCollection =
      geoJSON.type == GeoJSONObjectTypes.featureCollection;
  bool isFeature = geoJSON.type == GeoJSONObjectTypes.feature;
  var stop = isFeatureCollection ? geoJSON.features.length : 1;
  // This logic may look a little weird. The reason why it is that way
  // is because it's trying to be fast. GeoJSON supports multiple kinds
  // of objects at its root: FeatureCollection, Features, Geometries.
  // This function has the responsibility of handling all of them, and that
  // means that some of the `for` loops you see below actually just don't apply
  // to certain inputs. For instance, if you give this just a
  // Point geometry, then both loops are short-circuited and all we do
  // is gradually rename the input until it's called 'geometry'.
  //
  // This also aims to allocate as few resources as possible: just a
  // few numbers and booleans, rather than any temporary arrays as would
  // be required with the normalization approach.
  for (var i = 0; i < stop; i++) {
    geometryMaybeCollection = (isFeatureCollection
        ? geoJSON.features[i].geometry
        : (isFeature ? geoJSON.geometry : geoJSON));
    featureProperties = (isFeatureCollection
        ? geoJSON.features[i].properties
        : (isFeature ? geoJSON.properties : {}));
    featureBBox = (isFeatureCollection
        ? geoJSON.features[i].bbox
        : (isFeature ? geoJSON.bbox : null));
    featureId = (isFeatureCollection
        ? geoJSON.features[i].id
        : (isFeature ? geoJSON.id : null));
    isGeometryCollection = (geometryMaybeCollection != null)
        ? geometryMaybeCollection.type == GeoJSONObjectTypes.geometryCollection
        : false;
    stopG =
        isGeometryCollection ? geometryMaybeCollection.geometries.length : 1;

    for (var g = 0; g < stopG; g++) {
      geometry = isGeometryCollection
          ? geometryMaybeCollection.geometries[g]
          : geometryMaybeCollection;
      if (geometry == null) {
        if (callback(
              null,
              featureIndex,
              featureProperties,
              featureBBox,
              featureId,
            ) ==
            false) {
          return;
        }
        continue;
      }
      switch (geometry.type) {
        case GeoJSONObjectTypes.point:
        case GeoJSONObjectTypes.lineString:
        case GeoJSONObjectTypes.multiPoint:
        case GeoJSONObjectTypes.polygon:
        case GeoJSONObjectTypes.multiLineString:
        case GeoJSONObjectTypes.multiPolygon:
          if (callback(
                geometry,
                featureIndex,
                featureProperties,
                featureBBox,
                featureId,
              ) ==
              false) {
            return;
          }
          break;
        case GeoJSONObjectTypes.geometryCollection:
          for (var j = 0; j < geometry.geometries.length; j++) {
            if (callback(
                  geometry.geometries[j],
                  featureIndex,
                  featureProperties,
                  featureBBox,
                  featureId,
                ) ==
                false) {
              return;
            }
          }
          break;
        default:
          throw ('Unknown Geometry Type');
      }
    }
    // Only increase `featureIndex` per each feature
    featureIndex++;
  }
}

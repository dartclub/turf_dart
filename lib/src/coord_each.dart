import 'package:turf/helpers.dart';

coordEach(GeoJSONObject? geoJson, Function(Position, int coordIndex, int featureIndex, int multiFeatureINdex, int geometryIndex) callback,
    {bool excludeWrapCoord = false}) {
  if (geoJson == null) return;

  int j;
  int k;
  int l;
  int stopG;
  var coords, geometry, geometryMaybeCollection;
  bool isGeometryCollection;
  int wrapShrink = 0;
  int coordIndex = 0;
  bool isFeatureCollection = geoJson is FeatureCollection;
  bool isFeature = geoJson is Feature;
  int stop = isFeatureCollection ? geoJson.features.length : 1;

  for (var featureIndex = 0; featureIndex < stop; featureIndex++) {
    geometryMaybeCollection = isFeatureCollection
        ? geoJson.features[featureIndex].geometry
        : isFeature
            ? geoJson.geometry
            : geoJson;
    isGeometryCollection = geometryMaybeCollection != null ? geometryMaybeCollection is GeometryCollection : false;
    stopG = isGeometryCollection ? geometryMaybeCollection.geometries.length : 1;

    for (var geomIndex = 0; geomIndex < stopG; geomIndex++) {
      var multiFeatureIndex = 0;
      var geometryIndex = 0;
      geometry = isGeometryCollection ? geometryMaybeCollection.geometries[geomIndex] : geometryMaybeCollection;

      // Handles null Geometry -- Skips this geometry
      if (geometry == null) continue;
      coords = geometry.coordinates;
      var geomType = geometry;

      wrapShrink = excludeWrapCoord && (geomType is Polygon || geomType is MultiPolygon) ? 1 : 0;

      print('GeomType: $geomType');
      switch (geomType.runtimeType) {
        case Point:
          if (callback(coords, coordIndex, featureIndex, multiFeatureIndex, geometryIndex) == false) return false;
          coordIndex++;
          multiFeatureIndex++;
          break;
        case LineString:
        case MultiPoint:
          for (j = 0; j < coords.length; j++) {
            if (callback(coords[j], coordIndex, featureIndex, multiFeatureIndex, geometryIndex) == false) return false;
            coordIndex++;
            if (geomType is MultiPoint) multiFeatureIndex++;
          }
          if (geomType is LineString) multiFeatureIndex++;
          break;
        case Polygon:
        case MultiLineString:
          for (j = 0; j < coords.length; j++) {
            for (k = 0; k < coords[j].length - wrapShrink; k++) {
              if (callback(coords[j][k], coordIndex, featureIndex, multiFeatureIndex, geometryIndex) == false) return false;
              coordIndex++;
            }
            if (geomType is MultiLineString) multiFeatureIndex++;
            if (geomType is Polygon) geometryIndex++;
          }
          if (geomType is Polygon) multiFeatureIndex++;
          break;
        case MultiPolygon:
          for (j = 0; j < coords.length; j++) {
            geometryIndex = 0;
            for (k = 0; k < coords[j].length; k++) {
              for (l = 0; l < coords[j][k].length - wrapShrink; l++) {
                if (callback(coords[j][k][l], coordIndex, featureIndex, multiFeatureIndex, geometryIndex) == false) return false;
                coordIndex++;
              }
              geometryIndex++;
            }
            multiFeatureIndex++;
          }
          break;
        case GeometryCollection:
          for (j = 0; j < geometry.geometries.length; j++) {
            if (coordEach(geometry.geometries[j], callback, excludeWrapCoord: true) == false) {
              return false;
            }
          }
          break;
        default:
          throw new Exception("Unknown Geometry Type");
      }
    }
  }
}

import 'package:turf/src/meta.dart';

import '../helpers.dart';

extension GeomEachGeoJSONObject on GeoJSONObject {
  void geomEachImpl2(GeomEachCallback callback) {
    if (this is GeometryObject) {
      (this as GeometryObject).geomEachImpl2(callback);
    } else if (this is Feature) {
      (this as Feature).geomEachImpl2(callback);
    } else if (this is FeatureCollection) {
      (this as FeatureCollection).geomEachImpl2(callback);
    } else {
      throw Exception('Unknown GeoJSON Type');
    }
  }
}

extension GeomEachGeometryObject on GeometryObject {
  void geomEachImpl2(
    GeomEachCallback callback, {
    Map<String, dynamic>? featureProperties,
    BBox? featureBBox,
    dynamic featureId,
    int? featureIndex,
  }) {
    if (this is GeometryType) {
      (this as GeometryType).geomEachImpl2(
        callback,
        featureBBox: featureBBox,
        featureId: featureId,
        featureIndex: featureIndex,
        featureProperties: featureProperties,
      );
    } else if (this is GeometryCollection) {
      (this as GeometryCollection).geomEachImpl2(
        callback,
        featureBBox: featureBBox,
        featureId: featureId,
        featureIndex: featureIndex,
        featureProperties: featureProperties,
      );
    } else {
      throw Exception('Unknown Geometry Type');
    }
  }
}

extension GeomEachGeometryType on GeometryType {
  void geomEachImpl2(
    GeomEachCallback callback, {
    Map<String, dynamic>? featureProperties,
    BBox? featureBBox,
    dynamic featureId,
    int? featureIndex,
  }) {
    if (callback(
          this,
          featureIndex,
          featureProperties,
          featureBBox,
          featureId,
        ) ==
        false) {
      throw ShortCircuit();
    }
  }
}

extension GeomEachGeometryCollection on GeometryCollection {
  void geomEachImpl2(
    GeomEachCallback callback, {
    Map<String, dynamic>? featureProperties,
    BBox? featureBBox,
    featureId,
    int? featureIndex,
  }) {
    for (var geom in geometries) {
      geom.geomEachImpl2(
        callback,
        featureProperties: featureProperties,
        featureBBox: featureBBox,
        featureId: featureId,
        featureIndex: featureIndex,
      );
    }
  }
}

extension GeomEachFeature on Feature {
  void geomEachImpl2(GeomEachCallback callback, {int? featureIndex}) {
    if (geometry != null) {
      (geometry as GeometryObject).geomEachImpl2(
        callback,
        featureBBox: bbox,
        featureId: id,
        featureIndex: featureIndex,
        featureProperties: properties,
      );
    }
  }
}

extension GeomEachFeatureCollection on FeatureCollection {
  void geomEachImpl2(GeomEachCallback callback) {
    int featuresLength = features.length;
    for (int featureIndex = 0; featureIndex < featuresLength; featureIndex++) {
      features[featureIndex]
          .geomEachImpl2(callback, featureIndex: featureIndex);
    }
  }
}

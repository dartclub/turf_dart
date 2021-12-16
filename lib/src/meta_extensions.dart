import 'package:turf/src/meta.dart' as meta;

import '../helpers.dart';

extension GeomEachGeoJSONObject on GeoJSONObject {
  void geomEach(meta.GeomEachCallback callback) {
    meta.geomEach(this, callback);
  }
}

extension GeomEachGeometryObject on GeometryObject {
  void geomEach(
    meta.GeomEachCallback callback, {
    Map<String, dynamic>? featureProperties,
    BBox? featureBBox,
    dynamic featureId,
    int? featureIndex,
  }) {
    try {
      meta.forEachGeomInGeometryObject(
        this,
        callback,
        featureProperties,
        featureBBox,
        featureId,
        featureIndex ?? 0,
      );
    } on meta.ShortCircuit {
      return;
    }
  }
}

extension GeomEachFeature on Feature {
  void geomEach(meta.GeomEachCallback callback, [int? featureIndex]) {
    try {
      meta.forEachGeomInFeature(
        this,
        callback,
        featureIndex ?? 0,
      );
    } on meta.ShortCircuit {
      return;
    }
  }
}

extension GeomEachFeatureCollection on FeatureCollection {
  void geomEach(meta.GeomEachCallback callback) {
    try {
      meta.forEachGeomInFeatureCollection(this, callback);
    } on meta.ShortCircuit {
      return;
    }
  }
}

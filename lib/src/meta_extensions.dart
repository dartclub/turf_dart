import 'package:turf/src/meta.dart' as meta;

import '../helpers.dart';

extension GeoJSONObjectMetaExtension on GeoJSONObject {
  void geomEach(meta.GeomEachCallback callback) {
    meta.geomEach(this, callback);
  }

  void propEach(meta.PropEachCallback callback) {
    meta.propEach(this, callback);
  }

  void featureEach(meta.FeatureEachCallback callback) {
    meta.featureEach(this, callback);
  }
}

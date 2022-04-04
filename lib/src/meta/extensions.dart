import 'package:turf/helpers.dart';
import 'package:turf/meta.dart' as meta;

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

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

  void coordEach(meta.CoordEachCallback callback) {
    meta.coordEach(this, callback);
  }

  void flattenEach(meta.FlattenEachCallback callback) {
    meta.flattenEach(this, callback);
  }

  void segmentEach(meta.SegmentEachCallback callback) {
    meta.segmentEach(this, callback);
  }
}

extension FeatureCollectionMetaExtension on FeatureCollection {
  void clusterEach(dynamic property, meta.ClusterEachCallback callback) {
    meta.clusterEach(this, property, callback);
  }
}

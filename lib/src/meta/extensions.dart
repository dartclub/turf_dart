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

  List<Position?> coordAll() {
    return meta.coordAll(this);
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

  FeatureCollection getCluster(dynamic filter) {
    return meta.getCluster(this, filter);
  }
}

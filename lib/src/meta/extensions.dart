import 'package:turf/helpers.dart';
import 'package:turf/meta.dart' as meta;

extension GeoJSONObjectMetaExtension on GeoJSONObject {
  void geomEach(meta.GeomEachCallback callback) {
    meta.geomEach(this, callback);
  }

  T? geomReduce<T>(meta.GeomReduceCallback<T> callback, T? initialValue) {
    return meta.geomReduce<T>(
      this,
      callback,
      initialValue,
    );
  }

  void propEach(meta.PropEachCallback callback) {
    meta.propEach(this, callback);
  }

  T? propReduce<T>(
    meta.PropReduceCallback<T> callback,
    T? initialValue,
  ) {
    return meta.propReduce<T>(
      this,
      callback,
      initialValue,
    );
  }

  void featureEach(meta.FeatureEachCallback callback) {
    meta.featureEach(this, callback);
  }

  T? featureReduce<T>(
    meta.FeatureReduceCallback<T> callback,
    T? initialValue,
  ) {
    return meta.featureReduce<T>(
      this,
      callback,
      initialValue,
    );
  }

  void coordEach(meta.CoordEachCallback callback) {
    meta.coordEach(this, callback);
  }

  T? coordReduce<T>(
    meta.CoordReduceCallback<T> callback,
    T? initialValue, [
    bool excludeWrapCoord = false,
  ]) {
    return meta.coordReduce<T>(
      this,
      callback,
      initialValue,
      excludeWrapCoord,
    );
  }

  List<Position?> coordAll() {
    return meta.coordAll(this);
  }

  void flattenEach(meta.FlattenEachCallback callback) {
    meta.flattenEach(this, callback);
  }

  T? flattenReduce<T>(
    meta.FlattenReduceCallback<T> callback,
    T? initialValue,
  ) {
    return meta.flattenReduce<T>(
      this,
      callback,
      initialValue,
    );
  }

  void segmentEach(meta.SegmentEachCallback callback) {
    meta.segmentEach(this, callback);
  }

  T? segmentReduce<T>(
    meta.SegmentReduceCallback<T> callback,
    T? initialValue, {
    bool combineNestedGeometries = true,
  }) {
    return meta.segmentReduce<T>(
      this,
      callback,
      initialValue,
      combineNestedGeometries: combineNestedGeometries,
    );
  }
}

extension FeatureCollectionMetaExtension on FeatureCollection {
  void clusterEach(
    dynamic property,
    meta.ClusterEachCallback callback,
  ) {
    meta.clusterEach(this, property, callback);
  }

  FeatureCollection getCluster(dynamic filter) {
    return meta.getCluster(this, filter);
  }

  T? clusterReduce<T>(
    dynamic property,
    meta.ClusterReduceCallback<T> callback,
    dynamic initialValue,
  ) {
    return meta.clusterReduce<T>(
      this,
      property,
      callback,
      initialValue,
    );
  }
}

import '../meta.dart';
import '../helpers.dart';

/// Get Cluster
/// Takes a [FeatureCollection<Feature>] and a [dynamic] [filter] used on GeoJSON properties
/// to get Cluster.
/// Returns a [FeatureCollection] single cluster filtered by GeoJSON Properties
/// For example:
///
/// ```dart
/// var geojson = FeatureCollection<Point>(features: [
///    Feature(
///      geometry: Point(coordinates: Position.of([10, 10])),
///      properties: {'marker-symbol': 'circle'},
///    ),
///    Feature(
///      geometry: Point(coordinates: Position.of([20, 20])),
///      properties: {'marker-symbol': 'circle'},
///    ),
///    Feature(
///      geometry: Point(coordinates: Position.of([30, 30])),
///      properties: {'marker-symbol': 'square'},
///    ),
///    Feature(
///      geometry: Point(coordinates: Position.of([40, 40])),
///      properties: {'marker-symbol': 'triangle'},
///    ),
///  ]);
///
/// // Creates a cluster using K-Means (adds `cluster` to GeoJSON properties)
/// var clustered = clustersKmeans(geojson);
///
/// // Retrieves first cluster (0)
/// var cluster = getCluster(clustered, {cluster: 0});
/// //= cluster
///
/// // Retrieves cluster based on custom properties
/// getCluster(clustered, {'marker-symbol': 'circle'}).length;
/// //= 2
/// getCluster(clustered, {'marker-symbol': 'square'}).length;
/// //= 1
/// ```

FeatureCollection getCluster(FeatureCollection geojson, dynamic filter) {
  // Filter Features
  List<Feature> features = [];
  featureEach(geojson, (feature, i) {
    if (applyFilter(feature.properties, filter)) features.add(feature);
  });
  return FeatureCollection(features: features);
}

/// ClusterEachCallback
/// Takes a [FeatureCollection], the cluster being processed, a [clusterValue]
/// used to create cluster being processed, and the [currentIndex], the index of
/// current element being processed in the [List]. Starts at index 0
/// Returns void.
typedef ClusterEachCallback = dynamic Function(
  FeatureCollection? cluster,
  dynamic clusterValue,
  int? currentIndex,
);

/// clusterEach
/// Takes a [FeatureCollection], a dynamic [property] key/value used to create clusters,
/// and a [ClusterEachCallback] method that takes (cluster, clusterValue, currentIndex) and
/// Returns void.
/// For example:
///
/// ```dart
/// var geojson = FeatureCollection<Point>(features: [
///    Feature(
///      geometry: Point(coordinates: Position.of([10, 10])),
///    ),
///    Feature(
///      geometry: Point(coordinates: Position.of([20, 20])),
///    ),
///    Feature(
///      geometry: Point(coordinates: Position.of([30, 30])),
///    ),
///    Feature(
///      geometry: Point(coordinates: Position.of([40, 40])),
///    ),
///  ]);
///
/// // Create a cluster using K-Means (adds `cluster` to [GeoJSONObject]'s properties)
/// var clustered = clustersKmeans(geojson);
///
/// // Iterates over each cluster
/// clusterEach(clustered, 'cluster', (cluster, clusterValue, currentIndex) {
///     //= cluster
///     //= clusterValue
///     //= currentIndex
/// })
///
/// // Calculates the total number of clusters
/// var total = 0
/// clusterEach(clustered, 'cluster', function () {
///     total++;
/// });
///
/// // Creates [List] of all the values retrieved from the 'cluster' property
/// var values = []
/// clusterEach(clustered, 'cluster', (cluster, clusterValue) {
///     values.add(clusterValue);
/// });
/// ```

void clusterEach(
    FeatureCollection geojson, dynamic property, ClusterEachCallback callback) {
  if (property == null) {
    throw Exception("property is required");
  }

  // Creates clusters based on property values
  var bins = createBins(geojson, property);
  var values = bins.keys.toList();
  for (var index = 0; index < values.length; index++) {
    var value = values[index];
    List<int> bin = bins[value]!;
    List<Feature> features = [];
    for (var i = 0; i < bin.length; i++) {
      features.add(geojson.features[bin[i]]);
    }
    callback(FeatureCollection(features: features), value, index);
  }
}

/// ClusterReduceCallback
/// The first time the callback function is called, the values provided as arguments depend
/// on whether the reduce method has an [initialValue] argument.
///
/// If an [initialValue] is provided to the reduce method:
///  - The [previousValue] argument is [initialValue].
///  - The [currentValue] argument is the value of the first element present in the [List].
///
/// If an [initialValue] is not provided:
///  - The [previousValue] argument is the value of the first element present in the [List].
///  - The [currentValue] argument is the value of the second element present in the [List].
///
/// Takes a [previousValue], the accumulated value previously returned in the last invocation
/// of the callback, or [initialValue], if supplied, a [FeatureCollection] [cluster], the current
/// cluster being processed, a [clusterValue] used to create cluster being processed and a
/// [currentIndex], the index of the current element being processed in the
/// [List].
/// Starts at index 0, if an [initialValue] is provided, and at index 1 otherwise.
typedef ClusterReduceCallback<T> = T? Function(
  T? previousValue,
  FeatureCollection? cluster,
  dynamic clusterValue,
  int? currentIndex,
);

/// Reduces clusters in Features, similar to [Iterable.reduce]
/// Takes a [FeatureCollection][geojson], a dynamic [porperty], a [GeoJSONObject]'s property key/value
/// used to create clusters, a [ClusterReduceCallback] method, and an [initialValue] to
/// use as the first argument to the first call of the callback.
/// Returns the value that results from the reduction.
/// For example:
///
/// ```dart
/// var geojson = FeatureCollection<Point>(features: [
///    Feature(
///      geometry: Point(coordinates: Position.of([10, 10])),
///    ),
///    Feature(
///      geometry: Point(coordinates: Position.of([20, 20])),
///    ),
///    Feature(
///      geometry: Point(coordinates: Position.of([30, 30])),
///    ),
///    Feature(
///      geometry: Point(coordinates: Position.of([40, 40])),
///    ),
///  ]);
///
/// // Creates a cluster using K-Means (adds `cluster` to GeoJSON properties)
/// var clustered = clustersKmeans(geojson);
///
/// // Iterates over each cluster and perform a calculation
/// var initialValue = 0
/// clusterReduce(clustered, 'cluster', (previousValue, cluster, clusterValue, currentIndex) {
///     //=previousValue
///     //=cluster
///     //=clusterValue
///     //=currentIndex
///     return previousValue++;
/// }, initialValue);
///
/// // Calculates the total number of clusters
/// var total = clusterReduce(clustered, 'cluster', function (previousValue) {
///     return previousValue++;
/// }, 0);
///
/// // Creates a [List] of all the values retrieved from the 'cluster' property.
/// var values = clusterReduce(clustered, 'cluster', (previousValue, cluster, clusterValue){
///     return previousValue.addAll(clusterValue);
/// }, []);
/// ```

T? clusterReduce<T>(
  FeatureCollection geojson,
  dynamic property,
  ClusterReduceCallback<T> callback,
  dynamic initialValue,
) {
  var previousValue = initialValue;
  clusterEach(geojson, property, (cluster, clusterValue, currentIndex) {
    if (currentIndex == 0 && initialValue == null) {
      previousValue = cluster;
    } else {
      previousValue =
          callback(previousValue, cluster, clusterValue, currentIndex);
    }
  });
  return previousValue;
}

/// createBins
/// Takes a [FeatureCollection] geojson, and dynamic [property] key whose
/// corresponding values of the [Feature]s will be used to create bins.
/// Returns Map<String, List<int>> bins with Feature IDs
/// For example
///
/// ```dart
/// var geojson = FeatureCollection<Point>(features: [
///    Feature(
///      geometry: Point(coordinates: Position.of([10, 10])),
///      properties:{'cluster': 0, 'foo': 'null'},
///    ),
///    Feature(
///      geometry: Point(coordinates: Position.of([20, 20])),
///      properties: {'cluster': 1, 'foo': 'bar'},
///    ),
///    Feature(
///      geometry: Point(coordinates: Position.of([30, 30])),
///      properties: {'0': 'foo'},
///    ),
///    Feature(
///      geometry: Point(coordinates: Position.of([40, 40])),
///      properties: {'cluster': 1},
///    ),
///  ]);
/// createBins(geojson, 'cluster');
/// //= { '0': [ 0 ], '1': [ 1, 3 ] }
/// ```

Map<dynamic, List<int>> createBins(
    FeatureCollection geojson, dynamic property) {
  Map<dynamic, List<int>> bins = {};

  featureEach(geojson, (feature, i) {
    var properties = feature.properties ?? {};
    if (properties.containsKey(property)) {
      var value = properties[property];
      if (bins.containsKey(value)) {
        bins[value]!.add(i);
      } else {
        bins[value] = [i];
      }
    }
  });
  return bins;
}

/// applyFilter
/// Takes a [Map] [properties] and a [filter],
/// Returns a [bool] indicating filter is applied to the properties.

bool applyFilter(Map? properties, dynamic filter) {
  if (properties == null) return false;
  if (filter is! List && filter is! Map && filter is! String) {
    throw Exception("filter('s) key must be String");
  }
  if (filter is String) {
    return properties.containsKey(filter);
  }
  if (filter is List) {
    for (var i = 0; i < filter.length; i++) {
      if (!applyFilter(properties, filter[i])) return false;
    }
    return true;
  }
  if (filter is Map) {
    return propertiesContainsFilter(properties, filter);
  }
  return false;
}

/// Properties contains filter (does not apply deepEqual operations)
/// Takes a [Map] [properties] value, and a [Map] filter and
/// Returns [bool] if filter does equal the [properties]
/// For example
///
/// ```dart
/// propertiesContainsFilter({foo: 'bar', cluster: 0}, {cluster: 0})
/// //= true
/// propertiesContainsFilter({foo: 'bar', cluster: 0}, {cluster: 1})
/// //= false
/// ```
bool propertiesContainsFilter(Map properties, Map filter) {
  var keys = filter.keys.toList();
  for (var i = 0; i < keys.length; i++) {
    var key = keys[i];
    if (properties[key] != filter[key]) return false;
  }
  return true;
}

/// filterProperties
/// Takes [Map<String, dynamic>] [properties], and [List<String>] [keys] used to
/// filter Properties.
/// Returns [Map<String, dynamic>] filtered Properties
/// For example:
///
/// ```dart
/// filterProperties({foo: 'bar', cluster: 0}, ['cluster'])
/// //= {cluster: 0}
/// ```

Map<String, dynamic> filterProperties(
    Map<String, dynamic> properties, List<String>? keys) {
  if (keys == null || keys.isEmpty) return {};

  Map<String, dynamic> newProperties = {};
  for (var i = 0; i < keys!.length; i++) {
    var key = keys[i];
    if (properties.containsKey(key)) {
      newProperties[key] = properties[key];
    }
  }
  return newProperties;
}

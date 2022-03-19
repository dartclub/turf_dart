import '../meta.dart';
import '../helpers.dart';

///
/// Get Cluster
///
/// @name getCluster
/// @param {FeatureCollection} geojson GeoJSON Features
/// @param {*} filter Filter used on GeoJSON properties to get Cluster
/// @returns {FeatureCollection} Single Cluster filtered by GeoJSON Properties
/// @example
/// var geojson = turf.featureCollection([
///     turf.point([0, 0], {'marker-symbol': 'circle'}),
///     turf.point([2, 4], {'marker-symbol': 'star'}),
///     turf.point([3, 6], {'marker-symbol': 'star'}),
///     turf.point([5, 1], {'marker-symbol': 'square'}),
///     turf.point([4, 2], {'marker-symbol': 'circle'})
/// ]);
///
/// // Create a cluster using K-Means (adds `cluster` to GeoJSON properties)
/// var clustered = turf.clustersKmeans(geojson);
///
/// // Retrieve first cluster (0)
/// var cluster = turf.getCluster(clustered, {cluster: 0});
/// //= cluster
///
/// // Retrieve cluster based on custom properties
/// turf.getCluster(clustered, {'marker-symbol': 'circle'}).length;
/// //= 2
/// turf.getCluster(clustered, {'marker-symbol': 'square'}).length;
/// //= 1
///

FeatureCollection getCluster(FeatureCollection geojson, dynamic filter) {
  // Filter Features
  List<Feature> features = [];
  featureEach(geojson, (feature, i) {
    if (applyFilter(feature.properties, filter)) features.add(feature);
  });
  return FeatureCollection(features: features);
}

/**
 * clusterEach
 *
 * @name clusterEach
 * @param {FeatureCollection} geojson GeoJSON Features
 * @param {string|number} property GeoJSON property key/value used to create clusters
 * @param {Function} callback a method that takes (cluster, clusterValue, currentIndex)
 * @returns {void}
 * @example
 * var geojson = turf.featureCollection([
 *     turf.point([0, 0]),
 *     turf.point([2, 4]),
 *     turf.point([3, 6]),
 *     turf.point([5, 1]),
 *     turf.point([4, 2])
 * ]);
 *
 * // Create a cluster using K-Means (adds `cluster` to GeoJSON properties)
 * var clustered = turf.clustersKmeans(geojson);
 *
 * // Iterate over each cluster
 * turf.clusterEach(clustered, 'cluster', function (cluster, clusterValue, currentIndex) {
 *     //= cluster
 *     //= clusterValue
 *     //= currentIndex
 * })
 *
 * // Calculate the total number of clusters
 * var total = 0
 * turf.clusterEach(clustered, 'cluster', function () {
 *     total++;
 * });
 *
 * // Create an Array of all the values retrieved from the 'cluster' property
 * var values = []
 * turf.clusterEach(clustered, 'cluster', function (cluster, clusterValue) {
 *     values.push(clusterValue);
 * });
 */

///
/// Callback for clusterEach
///
/// @callback clusterEachCallback
/// @param {FeatureCollection} [cluster] The current cluster being processed.
/// @param {*} [clusterValue] Value used to create cluster being processed.
/// @param {number} [currentIndex] The index of the current element being processed in the array.Starts at index 0
/// @returns {void}
///

typedef ClusterEachCallback = dynamic Function(
  FeatureCollection? cluster,
  dynamic clusterValue,
  int? currentIndex,
);

void clusterEach(
    FeatureCollection geojson, dynamic property, ClusterEachCallback callback) {
  if (property != null) {
    throw Exception("property is required");
  }

  // Create clusters based on property values
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

/**
 * Callback for clusterReduce
 *
 * The first time the callback function is called, the values provided as arguments depend
 * on whether the reduce method has an initialValue argument.
 *
 * If an initialValue is provided to the reduce method:
 *  - The previousValue argument is initialValue.
 *  - The currentValue argument is the value of the first element present in the array.
 *
 * If an initialValue is not provided:
 *  - The previousValue argument is the value of the first element present in the array.
 *  - The currentValue argument is the value of the second element present in the array.
 *
 * @callback clusterReduceCallback
 * @param {*} [previousValue] The accumulated value previously returned in the last invocation
 * of the callback, or initialValue, if supplied.
 * @param {FeatureCollection} [cluster] The current cluster being processed.
 * @param {*} [clusterValue] Value used to create cluster being processed.
 * @param {number} [currentIndex] The index of the current element being processed in the
 * array. Starts at index 0, if an initialValue is provided, and at index 1 otherwise.
 */

///
/// Reduce clusters in GeoJSON Features, similar to Array.reduce()
///
/// @name clusterReduce
/// @param {FeatureCollection} geojson GeoJSON Features
/// @param {string|number} property GeoJSON property key/value used to create clusters
/// @param {Function} callback a method that takes (previousValue, cluster, clusterValue, currentIndex)
/// @param {*} [initialValue] Value to use as the first argument to the first call of the callback.
/// @returns {*} The value that results from the reduction.
/// @example
/// var geojson = turf.featureCollection([
///     turf.point([0, 0]),
///     turf.point([2, 4]),
///     turf.point([3, 6]),
///     turf.point([5, 1]),
///     turf.point([4, 2])
/// ]);
///
/// // Create a cluster using K-Means (adds `cluster` to GeoJSON properties)
/// var clustered = turf.clustersKmeans(geojson);
///
/// // Iterate over each cluster and perform a calculation
/// var initialValue = 0
/// turf.clusterReduce(clustered, 'cluster', function (previousValue, cluster, clusterValue, currentIndex) {
///     //=previousValue
///     //=cluster
///     //=clusterValue
///     //=currentIndex
///     return previousValue++;
/// }, initialValue);
///
/// // Calculate the total number of clusters
/// var total = turf.clusterReduce(clustered, 'cluster', function (previousValue) {
///     return previousValue++;
/// }, 0);
///
/// // Create an Array of all the values retrieved from the 'cluster' property
/// var values = turf.clusterReduce(clustered, 'cluster', function (previousValue, cluster, clusterValue) {
///     return previousValue.concat(clusterValue);
/// }, []);
///

typedef ClusterReduceCallback<T> = T? Function(
  T? previousValue,
  FeatureCollection? cluster,
  dynamic clusterValue,
  int? currentIndex,
);

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

///
/// Create Bins
///
/// @private
/// @param {FeatureCollection} geojson GeoJSON Features
/// @param {string|number} property Property values are used to create bins
/// @returns {Object} bins with Feature IDs
/// @example
/// var geojson = turf.featureCollection([
///     turf.point([0, 0], {cluster: 0, foo: 'null'}),
///     turf.point([2, 4], {cluster: 1, foo: 'bar'}),
///     turf.point([5, 1], {0: 'foo'}),
///     turf.point([3, 6], {cluster: 1}),
/// ]);
/// createBins(geojson, 'cluster');
/// //= { '0': [ 0 ], '1': [ 1, 3 ] }
///

Map<String, List<int>> createBins(FeatureCollection geojson, dynamic property) {
  Map<String, List<int>> bins = {};

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

///
/// Apply Filter
///
/// @private
/// @param {*} properties Properties
/// @param {*} filter Filter
/// @returns {boolean} applied Filter to properties
///

bool applyFilter(Map? properties, dynamic filter) {
  if (properties == null) return false;
  if (filter is num || filter is String) {
    return properties.containsKey(filter);
  } else if (filter is List) {
    for (var i = 0; i < filter.length; i++) {
      if (!applyFilter(properties, filter[i])) return false;
    }
    return true;
  } else {
    return propertiesContainsFilter(properties, filter);
  }
}

///
/// Properties contains filter (does not apply deepEqual operations)
///
/// @private
/// @param {*} properties Properties
/// @param {Object} filter Filter
/// @returns {boolean} does filter equal Properties
/// @example
/// propertiesContainsFilter({foo: 'bar', cluster: 0}, {cluster: 0})
/// //= true
/// propertiesContainsFilter({foo: 'bar', cluster: 0}, {cluster: 1})
/// //= false
///
bool propertiesContainsFilter(Map properties, Map filter) {
  var keys = filter.keys.toList();
  for (var i = 0; i < keys.length; i++) {
    var key = keys[i];
    if (properties[key] != filter[key]) return false;
  }
  return true;
}

///
/// Filter Properties
///
/// @private
/// @param {*} properties Properties
/// @param {Array<string>} keys Used to filter Properties
/// @returns {*} filtered Properties
/// @example
/// filterProperties({foo: 'bar', cluster: 0}, ['cluster'])
/// //= {cluster: 0}
///

Map<String, dynamic> filterProperties(
    Map<String, dynamic> properties, List<String> keys) {
  if (keys.isEmpty) return {};

  Map<String, dynamic> newProperties = {};
  for (var i = 0; i < keys.length; i++) {
    var key = keys[i];
    if (properties.containsKey(key)) {
      newProperties[key] = properties[key];
    }
  }
  return newProperties;
}

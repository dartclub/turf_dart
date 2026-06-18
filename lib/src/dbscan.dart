import 'package:turf/clone.dart';
import 'package:turf/distance.dart';
import 'package:turf/bbox.dart' as turf_bbox;
import 'package:rbush/rbush.dart';

// DBSCAN (Density-Based Spatial Clustering of Applications with Noise) is a data clustering algorithm.
// Given a set of points in some space, it groups together points that are closely packed together
// (points with many nearby neighbors), marking as outliers points that lie alone in low-density regions.

// A wrapper class to make GeoJSON features compatible with RBush spatial indexing.
class SpatialFeature extends RBushElement<Feature<Point>> {
    final Feature<Point> feature;

    SpatialFeature(this.feature)
        : assert(feature.bbox != null && feature.bbox!.length >= 4, 'Feature must have a bbox'),
          super(
            minX: feature.bbox![0]!.toDouble(),
            minY: feature.bbox![1]!.toDouble(),
            maxX: feature.bbox![2]!.toDouble(),
            maxY: feature.bbox![3]!.toDouble(),
            data: feature,
          );
}

FeatureCollection<Point> dbscan(
    FeatureCollection<Point> points,
    int maxClusterLength,
    int minPoints,
    double maxRadius, {
    bool mutableInput = true,
  }) {
    if (minPoints <= 0) {
      throw ArgumentError('minPoints must be greater than 0');
    }
    if (maxRadius < 0) {
      throw ArgumentError('maxRadius must be greater than or equal to 0');
    }

    final numberOfPoints = points.features.length;
    final clustered = mutableInput ? points : clone(points);
    final visited = List<bool>.filled(numberOfPoints, false);
    final noise = List<bool>.filled(numberOfPoints, false);
    int clusterId = 0;

    // Ensure all features have a bounding box
    for (final feature in clustered.features) {
      if (feature.geometry != null && feature.bbox == null) {
        feature.bbox = turf_bbox.bbox(feature);
      }
    }

    // Build an R-tree index for efficient neighbor searching
    final tree = RBush<Feature<Point>>();
    for (int i = 0; i < numberOfPoints; i++) {
      final feature = clustered.features[i];
      if (feature.geometry != null && feature.bbox != null) {
        tree.insert(SpatialFeature(feature));
      }
    }

    // Function to find neighbors within a given radius
    List<int> getNeighbors(int pointIndex) {
        final neighbors = <int>[];
        final targetPoint = clustered.features[pointIndex];
        if (targetPoint.geometry == null || targetPoint.bbox == null) {
            return neighbors;
        }

        final envelope = RBushBox(
            minX: targetPoint.bbox![0] - maxRadius,
            minY: targetPoint.bbox![1] - maxRadius,
            maxX: targetPoint.bbox![2] + maxRadius,
            maxY: targetPoint.bbox![3] + maxRadius,
        );

        final potentialNeighbors = tree.search(envelope);
      for (final wrapped in potentialNeighbors) {
          final spatialFeature = wrapped as SpatialFeature;
          final neighborFeature = spatialFeature.feature;
          final neighborIndex = clustered.features.indexOf(neighborFeature);
          if (pointIndex != neighborIndex) {
            final dist = distance(targetPoint.geometry!, neighborFeature.geometry!);
            if (dist <= maxRadius) {
              neighbors.add(neighborIndex);
            }
          }
        }
        return neighbors;
      }

  // Expand the cluster recursively
  void expandCluster(int pointIndex, List<int> neighbors) {
      visited[pointIndex] = true;
      clustered.features[pointIndex].properties['cluster'] = clusterId;

      int i = 0;
      while (i < neighbors.length) {
          final neighborIndex = neighbors[i];
          if (!visited[neighborIndex]) {
              visited[neighborIndex] = true;
              clustered.features[neighborIndex].properties['cluster'] = clusterId;
              final newNeighbors = getNeighbors(neighborIndex);
              if (newNeighbors.length >= minPoints) {
                  neighbors.addAll(newNeighbors.where((n) => !neighbors.contains(n)));
              }
          }
          i++;
        }
      }

  // Iterate through each point
  for (int i = 0; i < numberOfPoints; i++) {
      if (!visited[i]) {
          final neighbors = getNeighbors(i);
          if (neighbors.length < minPoints) {
              noise[i] = true;
          } else {
              expandCluster(i, neighbors);
              clusterId++;
              if (clusterId > maxClusterLength) {
                  throw ArgumentError(
                    'Cluster exceeded maxClusterLength ($maxClusterLength)');
              }
          }
      }
  }

    // Mark noise points with null cluster
    for (int i = 0; i < numberOfPoints; i++) {
        if (noise[i]) {
            clustered.features[i].properties['cluster'] = null;
        }
    }

    return clustered;
}
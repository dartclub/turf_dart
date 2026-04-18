import 'package:turf/helpers.dart';
import 'position_utils.dart';

/// Utility for clustering points into groups based on proximity
class PointClustering {
  /// Cluster points from feature collection into groups based on proximity
  static List<List<Position>> clusterPointsByProximity(List<Feature> features) {
    // Extract all unique points from features
    final allPoints = <Position>[];
    final visited = <String>{};

    for (final feature in features) {
      if (feature.geometry is LineString) {
        final coords = (feature.geometry as LineString).coordinates;
        for (final coord in coords) {
          final key = '${coord[0]},${coord[1]}';
          if (!visited.contains(key)) {
            visited.add(key);
            allPoints.add(coord);
          }
        }
      } else if (feature.geometry is MultiLineString) {
        final multiCoords = (feature.geometry as MultiLineString).coordinates;
        for (final coords in multiCoords) {
          for (final coord in coords) {
            final key = '${coord[0]},${coord[1]}';
            if (!visited.contains(key)) {
              visited.add(key);
              allPoints.add(coord);
            }
          }
        }
      }
    }

    // If there are less than 4 points, we can't form a polygon
    if (allPoints.length < 4) {
      return [allPoints]; // Just return all points as one group
    }

    // Try clustering by x coordinates
    final xClusters = _clusterByXCoordinate(allPoints);
    if (xClusters.length > 1) return xClusters;

    // Try clustering by y coordinates
    final yClusters = _clusterByYCoordinate(allPoints);
    if (yClusters.length > 1) return yClusters;

    // Try clustering by distance from centroid (for concentric shapes like polygons with holes)
    final distanceClusters = _clusterByDistanceFromCentroid(allPoints);
    if (distanceClusters.length > 1) return distanceClusters;

    // If we couldn't split the points, return them all as one group
    return [allPoints];
  }

  static List<List<Position>> _clusterByMetric(
    List<Position> points,
    double Function(Position) metric,
    double gapFactor,
  ) {
    if (points.length < 2) return [points];

    final sortedPoints = List<Position>.from(points)
      ..sort((a, b) => metric(a).compareTo(metric(b)));

    final values = sortedPoints.map(metric).toList();
    final gaps = <double>[];

    for (int i = 0; i < values.length - 1; i++) {
      gaps.add(values[i + 1] - values[i]);
    }

    if (gaps.isEmpty) return [points];

    final averageGap = gaps.reduce((a, b) => a + b) / gaps.length;
    final clusters = <List<Position>>[];
    var currentCluster = <Position>[sortedPoints[0]];

    for (int i = 0; i < gaps.length; i++) {
      if (gaps[i] > averageGap * gapFactor) {
        clusters.add(currentCluster);
        currentCluster = <Position>[sortedPoints[i + 1]];
      } else {
        currentCluster.add(sortedPoints[i + 1]);
      }
    }

    clusters.add(currentCluster);
    return clusters;
  }

  /// Cluster points by their X coordinate
  static List<List<Position>> _clusterByXCoordinate(List<Position> points) {
    return _clusterByMetric(points, (point) => point[0]!.toDouble(), 2);
  }

  /// Cluster points by their Y coordinate
  static List<List<Position>> _clusterByYCoordinate(List<Position> points) {
    return _clusterByMetric(points, (point) => point[1]!.toDouble(), 2);
  }

  /// Cluster points by distance from centroid (for concentric shapes)
  static List<List<Position>> _clusterByDistanceFromCentroid(
      List<Position> points) {
    if (points.length < 8)
      return [points]; // Not enough points for meaningful clustering

    // Calculate centroid
    final centroidX =
        points.fold<num>(0, (sum, p) => sum + (p[0] ?? 0)) / points.length;
    final centroidY =
        points.fold<num>(0, (sum, p) => sum + (p[1] ?? 0)) / points.length;

    // Calculate distance from centroid for each point
    final pointsWithDistance = points.map((p) {
      final dx = (p[0] ?? 0) - centroidX;
      final dy = (p[1] ?? 0) - centroidY;
      final distanceSquared = dx * dx + dy * dy;
      return PointWithDistance(p, distanceSquared);
    }).toList();

    // Sort by distance
    pointsWithDistance
        .sort((a, b) => a.distanceSquared.compareTo(b.distanceSquared));

    // Check if points form two distinct groups by distance
    num totalDist = 0;
    for (int i = 1; i < pointsWithDistance.length; i++) {
      totalDist += (pointsWithDistance[i].distanceSquared -
          pointsWithDistance[i - 1].distanceSquared);
    }
    final avgDistGap = totalDist / (pointsWithDistance.length - 1);

    // Find significant gap in distances
    int? splitIdx;
    for (int i = 1; i < pointsWithDistance.length; i++) {
      final gap = pointsWithDistance[i].distanceSquared -
          pointsWithDistance[i - 1].distanceSquared;
      if (gap > avgDistGap * 3) {
        // Significant gap
        splitIdx = i;
        break;
      }
    }

    // If we found a significant gap, split into inner and outer points
    if (splitIdx != null) {
      final innerPoints = pointsWithDistance
          .sublist(0, splitIdx)
          .map((p) => p.position)
          .toList();
      final outerPoints =
          pointsWithDistance.sublist(splitIdx).map((p) => p.position).toList();
      return [
        outerPoints,
        innerPoints
      ]; // Outer ring first, then inner ring (hole)
    }

    return [points]; // Return a single group if no significant gaps found
  }
}

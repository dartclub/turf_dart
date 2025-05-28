import 'package:turf/helpers.dart';
import 'dart:math';

/// Utility functions for working with Position objects
class PositionUtils {
  /// Create a new Position from an existing one, preserving altitude if present
  static Position createPosition(Position source) {
    if (source.length > 2 && source[2] != null) {
      return Position.of([
        source[0]!,
        source[1]!,
        source[2]!,
      ]);
    } else {
      return Position.of([
        source[0]!,
        source[1]!,
      ]);
    }
  }

  /// Get a sample point from a list of positions (for containment tests)
  static Position getSamplePointFromPositions(List<Position> positions) {
    // Use points from different parts of the polygon for more reliable sampling
    final p1 = positions[0];
    final p2 = positions[positions.length ~/ 3];
    final p3 = positions[positions.length * 2 ~/ 3];
    
    // Calculate the centroid
    final x = (p1[0]! + p2[0]! + p3[0]!) / 3;
    final y = (p1[1]! + p2[1]! + p3[1]!) / 3;
    
    return Position.of([x, y]);
  }

  /// Sort nodes in clockwise order around their centroid
  static List<Position> sortNodesClockwise(List<Position> nodes) {
    if (nodes.isEmpty) return [];
    
    // Calculate the centroid of all nodes
    num sumX = 0;
    num sumY = 0;
    for (final node in nodes) {
      sumX += node[0] ?? 0;
      sumY += node[1] ?? 0;
    }
    final centroidX = sumX / nodes.length;
    final centroidY = sumY / nodes.length;
    
    // Sort nodes by angle from centroid
    final nodesCopy = List<Position>.from(nodes);
    nodesCopy.sort((a, b) {
      final angleA = atan2(a[1]! - centroidY, a[0]! - centroidX);
      final angleB = atan2(b[1]! - centroidY, b[0]! - centroidX);
      return angleA.compareTo(angleB);
    });
    
    return nodesCopy;
  }

  /// Sort nodes in counter-clockwise order around their centroid (for RFC 7946 compliance)
  static List<Position> sortNodesCounterClockwise(List<Position> nodes) {
    if (nodes.isEmpty) return [];
    
    // Calculate the centroid of all nodes
    num sumX = 0;
    num sumY = 0;
    for (final node in nodes) {
      sumX += node[0] ?? 0;
      sumY += node[1] ?? 0;
    }
    final centroidX = sumX / nodes.length;
    final centroidY = sumY / nodes.length;
    
    // Sort nodes by angle from centroid (counter-clockwise)
    final nodesCopy = List<Position>.from(nodes);
    nodesCopy.sort((a, b) {
      final angleA = atan2(a[1]! - centroidY, a[0]! - centroidX);
      final angleB = atan2(b[1]! - centroidY, b[0]! - centroidX);
      return angleB.compareTo(angleA); // Reversed comparison for CCW
    });
    
    return nodesCopy;
  }
}

/// Helper class for point distance calculations
class PointWithDistance {
  final Position position;
  final num distanceSquared;
  
  PointWithDistance(this.position, this.distanceSquared);
}

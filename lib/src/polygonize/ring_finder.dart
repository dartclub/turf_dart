import 'package:turf/helpers.dart';
import '../bearing.dart';
import 'graph.dart';

/// Responsible for finding rings in a planar graph of edges
class RingFinder {
  final Graph graph;

  RingFinder(this.graph);

  /// Find all rings in the graph
  List<List<Position>> findRings() {
    // Create a copy of all edges
    final allEdges = Map<String, Edge>.from(graph.edges);
    final rings = <List<Position>>[];

    // Process edges until none are left
    while (allEdges.isNotEmpty) {
      // Take the first available edge
      final edgeKey = allEdges.keys.first;
      final edge = allEdges.remove(edgeKey)!;

      // Try to find a ring starting with this edge
      final ring = _findRing(edge, allEdges);
      if (ring != null && ring.length >= 3) {
        rings.add(ring);
      }
    }

    return rings;
  }

  /// Find a ring starting from the given edge, removing used edges from the availableEdges map
  List<Position>? _findRing(Edge startEdge, Map<String, Edge> availableEdges) {
    final ring = <Position>[];
    Position currentPos = startEdge.from;
    Position targetPos = startEdge.to;

    // Previous edge to track incoming direction
    Edge? previousEdge = startEdge;

    // Add the first point
    ring.add(currentPos);

    // Continue until we either complete the ring or determine it's not possible
    while (true) {
      // Move to the next position
      currentPos = targetPos;
      ring.add(currentPos);

      // If we've reached the starting point, we've found a ring
      if (currentPos[0] == ring[0][0] && currentPos[1] == ring[0][1]) {
        return ring;
      }

      // Find the next edge that continues the path using the right-hand rule
      Edge? nextEdge =
          _findNextEdgeByAngle(currentPos, previousEdge, availableEdges);

      // If no more edges, this is not a ring
      if (nextEdge == null) {
        return null;
      }

      // Save the previous edge for angle calculation
      previousEdge = Edge(currentPos, nextEdge.to);

      // Remove the edge from available edges
      final nextEdgeKey = _createEdgeKey(nextEdge.from, nextEdge.to);
      availableEdges.remove(nextEdgeKey);

      // Set the next target
      targetPos = nextEdge.to;
    }
  }

  /// Find the next edge with the smallest clockwise angle from the incoming edge
  Edge? _findNextEdgeByAngle(Position currentPos, Edge? previousEdge,
      Map<String, Edge> availableEdges) {
    final candidates = <EdgeWithBearing>[];
    final currentKey = '${currentPos[0]},${currentPos[1]}';

    // Calculate incoming bearing if we have a previous edge
    num incomingBearing = 0;
    if (previousEdge != null) {
      // Reverse the bearing (opposite direction)
      incomingBearing =
          (bearingRaw(previousEdge.to, previousEdge.from).toDouble() + 180) %
              360;
    }

    // Use the precomputed edge index from the graph
    final outgoingEdges = graph.edgesByVertex[currentKey] ?? [];

    // Find available outgoing edges
    for (final edgeWithBearing in outgoingEdges) {
      // Check if this edge is still available (not used yet)
      final edgeKey = edgeWithBearing.edge.directedKey;
      if (availableEdges.containsKey(edgeKey)) {
        candidates.add(edgeWithBearing);
      } else {
        // Also check the canonical key since we store edges canonically
        final canonicalKey = edgeWithBearing.edge.key;
        if (availableEdges.containsKey(canonicalKey)) {
          candidates.add(edgeWithBearing);
        }
      }
    }

    if (candidates.isEmpty) {
      return null;
    }

    // Sort edges by smallest clockwise angle from the incoming direction
    candidates.sort((a, b) {
      final angleA = (a.bearing - incomingBearing + 360) % 360;
      final angleB = (b.bearing - incomingBearing + 360) % 360;
      return angleA.compareTo(angleB);
    });

    // Return the edge with the smallest clockwise angle (right-hand rule)
    return candidates.first.edge;
  }

  /// Create a canonical edge key
  String _createEdgeKey(Position from, Position to) {
    final fromKey = '${from[0]},${from[1]}';
    final toKey = '${to[0]},${to[1]}';
    return fromKey.compareTo(toKey) < 0 ? '$fromKey|$toKey' : '$toKey|$fromKey';
  }
}

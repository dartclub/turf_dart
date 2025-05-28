import 'dart:math';
import 'package:turf/helpers.dart';

/// Edge representation for the graph
class Edge {
  final Position from;
  final Position to;
  bool visited = false;
  String? label;

  Edge(this.from, this.to);

  @override
  String toString() => '$from -> $to';

  /// Get canonical edge key (ordered by coordinates)
  String get key {
    return from.toString().compareTo(to.toString()) <= 0 
        ? '${from.toString()}|${to.toString()}' 
        : '${to.toString()}|${from.toString()}';
  }

  /// Get the key as directed edge
  String get directedKey => '${from.toString()}|${to.toString()}';

  /// Create a reversed edge
  Edge reversed() => Edge(to, from);
}

/// Helper class to associate an edge with its bearing
class EdgeWithBearing {
  final Edge edge;
  final num bearing;
  
  EdgeWithBearing(this.edge, this.bearing);
}

/// Node in the graph, representing a vertex with its edges
class Node {
  final Position position;
  final List<Edge> edges = [];

  Node(this.position);

  void addEdge(Edge edge) {
    edges.add(edge);
  }

  /// Get string representation for use as a map key
  String get key => position.toString();
}

/// Graph representing a planar graph of edges and nodes
class Graph {
  final Map<String, Node> nodes = {};
  final Map<String, Edge> edges = {};
  final Map<String, List<EdgeWithBearing>> edgesByVertex = {};

  /// Add an edge to the graph
  void addEdge(Position from, Position to) {
    // Skip edges with identical start and end points
    if (from[0] == to[0] && from[1] == to[1]) {
      return;
    }

    // Create a canonical edge key to avoid duplicates
    final edgeKey = _createEdgeKey(from, to);

    // Skip duplicate edges
    if (edges.containsKey(edgeKey)) {
      return;
    }

    // Create and store the edge
    final edge = Edge(from, to);
    edges[edgeKey] = edge;

    // Add from node if it doesn't exist
    final fromKey = from.toString();
    if (!nodes.containsKey(fromKey)) {
      nodes[fromKey] = Node(from);
    }
    nodes[fromKey]!.addEdge(edge);

    // Add to node if it doesn't exist
    final toKey = to.toString();
    if (!nodes.containsKey(toKey)) {
      nodes[toKey] = Node(to);
    }
    nodes[toKey]!.addEdge(Edge(to, from));
    
    // Add to edge-by-vertex index for efficient lookup
    _addToEdgesByVertex(from, to);
    _addToEdgesByVertex(to, from);
  }
  
  /// Add edge to the index for efficient lookup by vertex
  void _addToEdgesByVertex(Position from, Position to) {
    final fromKey = from.toString();
    if (!edgesByVertex.containsKey(fromKey)) {
      edgesByVertex[fromKey] = [];
    }
    
    // Calculate bearing for the edge
    final bearing = _calculateBearing(from, to);
    edgesByVertex[fromKey]!.add(EdgeWithBearing(Edge(from, to), bearing));
  }
  
  /// Calculate bearing between two positions
  num _calculateBearing(Position start, Position end) {
    num lng1 = _degreesToRadians(start[0]!);
    num lng2 = _degreesToRadians(end[0]!);
    num lat1 = _degreesToRadians(start[1]!);
    num lat2 = _degreesToRadians(end[1]!);
    num a = sin(lng2 - lng1) * cos(lat2);
    num b = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(lng2 - lng1);

    // Convert to azimuth (0-360°, clockwise from north)
    num bearing = _radiansToDegrees(atan2(a, b));
    return (bearing % 360 + 360) % 360; // Normalize to 0-360
  }
  
  /// Create a canonical edge key
  String _createEdgeKey(Position from, Position to) {
    final fromKey = from.toString();
    final toKey = to.toString();
    return fromKey.compareTo(toKey) < 0 ? '$fromKey|$toKey' : '$toKey|$fromKey';
  }
  
  /// Convert degrees to radians
  num _degreesToRadians(num degrees) {
    return degrees * pi / 180;
  }
  
  /// Convert radians to degrees
  num _radiansToDegrees(num radians) {
    return radians * 180 / pi;
  }
}

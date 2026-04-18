import 'package:turf/helpers.dart';
import 'package:turf/src/meta/flatten.dart';
import 'package:turf/src/booleans/boolean_clockwise.dart';
import 'package:turf/src/invariant.dart';

import 'config.dart';
import 'graph.dart';
import 'ring_finder.dart';
import 'ring_classifier.dart';
import 'position_utils.dart';

/// Implementation of the polygonize function, which converts a set of lines
/// into a set of polygons based on closed ring detection.
class Polygonizer {
  /// Converts a collection of LineString features to a collection of Polygon features.
  ///
  /// Takes a [FeatureCollection<LineString>] or [FeatureCollection<MultiLineString>]
  /// and returns a [FeatureCollection<Polygon>].
  ///
  /// The input features must be correctly noded, meaning they should only meet at
  /// their endpoints to form rings that can be converted to polygons.
  ///
  /// Example:
  /// ```dart
  /// var lines = FeatureCollection(features: [
  ///   Feature(geometry: LineString(coordinates: [
  ///     Position.of([0, 0]),
  ///     Position.of([10, 0])
  ///   ])),
  ///   Feature(geometry: LineString(coordinates: [
  ///     Position.of([10, 0]),
  ///     Position.of([10, 10])
  ///   ])),
  ///   Feature(geometry: LineString(coordinates: [
  ///     Position.of([10, 10]),
  ///     Position.of([0, 10])
  ///   ])),
  ///   Feature(geometry: LineString(coordinates: [
  ///     Position.of([0, 10]),
  ///     Position.of([0, 0])
  ///   ]))
  /// ]);
  ///
  /// var polygons = polygonize(lines);
  /// ```
  static FeatureCollection<Polygon> polygonize(GeoJSONObject geoJSON,
      {PolygonizeConfig? config}) {
    // Start the polygonization process

    // Create a planar graph from all segments
    final graph = Graph();

    // Process all LineString and MultiLineString features and add them to the graph
    flattenEach(geoJSON, (currentFeature, featureIndex, multiFeatureIndex) {
      final geometry = currentFeature.geometry!;

      if (geometry is LineString) {
        final coords = getCoords(geometry) as List<Position>;
        _addLineToGraph(graph, coords);
      } else if (geometry is MultiLineString) {
        final multiCoords = getCoords(geometry) as List<List<Position>>;
        for (final coords in multiCoords) {
          _addLineToGraph(graph, coords);
        }
      } else {
        throw ArgumentError(
            'Input must be a LineString, MultiLineString, or a FeatureCollection of these types, but got ${geometry.type}');
      }
    });

    // Find rings in the graph
    final ringFinder = RingFinder(graph);
    final rings = ringFinder.findRings();

    // If no rings were found, try fallback approach
    if (rings.isEmpty) {
      // Extract nodes and try to form a ring
      final nodes = graph.nodes.values.map((node) => node.position).toList();
      if (nodes.length >= 4) {
        // Sort nodes and form a ring
        final sortedNodes = PositionUtils.sortNodesCounterClockwise(nodes);
        final ring = List<Position>.from(sortedNodes);

        // Close the ring
        if (ring.isNotEmpty &&
            (ring.first[0] != ring.last[0] || ring.first[1] != ring.last[1])) {
          ring.add(PositionUtils.createPosition(ring.first));
        }

        if (ring.length >= 4) {
          // Create a polygon from the ring
          final polygon = Polygon(coordinates: [ring]);
          return FeatureCollection<Polygon>(
              features: [Feature<Polygon>(geometry: polygon)]);
        }
      }
    }

    // Classify rings as exterior shells or holes
    final classifier = RingClassifier();
    final classifiedRings = classifier.classifyRings(rings);

    // Convert classified rings to polygons
    final outputFeatures = <Feature<Polygon>>[];
    for (final polygonRings in classifiedRings) {
      final polygon = Polygon(coordinates: polygonRings);
      outputFeatures.add(Feature<Polygon>(geometry: polygon));
    }

    return FeatureCollection<Polygon>(features: outputFeatures);
  }

  /// Add a line segment to the graph
  static void _addLineToGraph(Graph graph, List<Position> coords) {
    if (coords.length < 2) return;

    for (var i = 0; i < coords.length - 1; i++) {
      graph.addEdge(coords[i], coords[i + 1]);
    }
  }
}

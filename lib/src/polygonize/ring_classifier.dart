import 'package:turf/helpers.dart';
import 'package:turf/src/booleans/boolean_clockwise.dart';
import 'package:turf/src/booleans/boolean_point_in_polygon.dart';
import 'package:turf/src/area.dart';
import 'position_utils.dart';

/// Data structure to track ring classification information
class RingData {
  final List<Position> ring;
  final num area;
  bool isHole;
  int? parent;
  
  RingData({
    required this.ring,
    required this.area,
    required this.isHole,
    this.parent,
  });
}

/// Responsible for classifying rings as exterior shells or holes
/// and ensuring they have the correct orientation (RFC 7946).
class RingClassifier {
  /// Classify rings as either exterior shells or holes, 
  /// returning nested polygon structure (exterior ring with optional holes)
  List<List<List<Position>>> classifyRings(List<List<Position>> rings) {
    if (rings.isEmpty) return [];
    
    // Ensure all rings are closed
    final closedRings = rings.map((ring) {
      final closed = List<Position>.from(ring);
      if (closed.first[0] != closed.last[0] || closed.first[1] != closed.last[1]) {
        closed.add(PositionUtils.createPosition(closed.first));
      }
      return closed;
    }).toList();
    
    // Calculate the area of each ring to determine nesting relationships
    final areas = <num>[];
    for (final ring in closedRings) {
      final polygon = Polygon(coordinates: [ring]);
      final areaValue = area(polygon);
      areas.add(areaValue != null ? areaValue.abs() : 0); // Absolute area value
    }
    
    // Sort rings by area (largest first) for efficient containment checks
    final ringData = <RingData>[];
    for (var i = 0; i < closedRings.length; i++) {
      ringData.add(RingData(
        ring: closedRings[i],
        area: areas[i],
        isHole: !booleanClockwise(LineString(coordinates: closedRings[i])),
        parent: null,
      ));
    }
    ringData.sort((a, b) => b.area.compareTo(a.area));
    
    // Determine parent-child relationships
    for (var i = 0; i < ringData.length; i++) {
      if (ringData[i].isHole) {
        // Find the smallest containing ring for this hole
        var minArea = double.infinity;
        int? parentIndex;
        
        for (var j = 0; j < ringData.length; j++) {
          if (i == j || ringData[j].isHole) continue;
          
          // Check if j contains i using point-in-polygon test
          final pointInside = booleanPointInPolygon(
            _getSamplePointInRing(ringData[i].ring),
            Polygon(coordinates: [ringData[j].ring])
          );
          
          if (pointInside && ringData[j].area < minArea) {
            minArea = ringData[j].area.toDouble();
            parentIndex = j;
          }
        }
        
        if (parentIndex != null) {
          ringData[i].parent = parentIndex;
        } else {
          // If no parent found, treat as exterior (non-hole)
          ringData[i].isHole = false;
        }
      }
    }
    
    // Group rings by parent to form polygons
    final polygons = <List<List<Position>>>[];
    
    // Process exterior rings
    for (var i = 0; i < ringData.length; i++) {
      if (!ringData[i].isHole && ringData[i].parent == null) {
        final polygonRings = <List<Position>>[];
        
        // Ensure CCW orientation for exterior ring per RFC 7946
        final exterior = List<Position>.from(ringData[i].ring);
        if (booleanClockwise(LineString(coordinates: exterior))) {
          reverseRing(exterior);
        }
        polygonRings.add(exterior);
        
        // Add holes
        for (var j = 0; j < ringData.length; j++) {
          if (ringData[j].isHole && ringData[j].parent == i) {
            final hole = List<Position>.from(ringData[j].ring);
            
            // Ensure CW orientation for holes per RFC 7946
            if (!booleanClockwise(LineString(coordinates: hole))) {
              reverseRing(hole);
            }
            
            polygonRings.add(hole);
          }
        }
        
        polygons.add(polygonRings);
      }
    }
    
    return polygons;
  }

  /// Reverse the ring orientation, preserving the closing point
  void reverseRing(List<Position> ring) {
    // Remove closing point
    final lastPoint = ring.removeLast();
    
    // Reverse the ring
    final reversed = ring.reversed.toList();
    ring.clear();
    ring.addAll(reversed);
    
    // Re-add the closing point (which should match the new first point)
    if (lastPoint[0] != ring.first[0] || lastPoint[1] != ring.first[1]) {
      ring.add(PositionUtils.createPosition(ring.first));
    } else {
      ring.add(lastPoint);
    }
  }

  /// Get a sample point inside a ring for containment tests
  Position _getSamplePointInRing(List<Position> ring) {
    // Use the centroid of the first triangle in the ring as a sample point
    final p1 = ring[0];
    final p2 = ring[1];
    final p3 = ring[2];
    
    // Calculate the centroid
    final x = (p1[0]! + p2[0]! + p3[0]!) / 3;
    final y = (p1[1]! + p2[1]! + p3[1]!) / 3;
    
    return Position.of([x, y]);
  }
}

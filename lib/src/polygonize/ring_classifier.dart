import 'package:turf/helpers.dart';
import 'package:turf/src/area.dart';
import 'package:turf/src/booleans/boolean_clockwise.dart';
import 'package:turf/src/booleans/boolean_point_in_polygon.dart';

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

    final closedRings = rings.map((ring) {
      final closed = List<Position>.from(ring);
      if (closed.first[0] != closed.last[0] ||
          closed.first[1] != closed.last[1]) {
        closed.add(PositionUtils.createPosition(closed.first));
      }
      return closed;
    }).toList();

    final areas = <num>[];
    for (final ring in closedRings) {
      final polygon = Polygon(coordinates: [ring]);
      final areaValue = area(polygon);
      areas.add(areaValue != null ? areaValue.abs() : 0);
    }

    final ringData = <RingData>[];
    for (var i = 0; i < closedRings.length; i++) {
      ringData.add(
        RingData(
          ring: closedRings[i],
          area: areas[i],
          isHole: !booleanClockwise(LineString(coordinates: closedRings[i])),
          parent: null,
        ),
      );
    }
    ringData.sort((a, b) => b.area.compareTo(a.area));

    for (var i = 0; i < ringData.length; i++) {
      if (ringData[i].isHole) {
        var minArea = double.infinity;
        int? parentIndex;

        for (var j = 0; j < ringData.length; j++) {
          if (i == j || ringData[j].isHole) continue;

          final pointInside = booleanPointInPolygon(
            PositionUtils.getSamplePointFromPositions(ringData[i].ring),
            Polygon(coordinates: [ringData[j].ring]),
          );

          if (pointInside && ringData[j].area < minArea) {
            minArea = ringData[j].area.toDouble();
            parentIndex = j;
          }
        }

        if (parentIndex != null) {
          ringData[i].parent = parentIndex;
        } else {
          ringData[i].isHole = false;
        }
      }
    }

    final polygons = <List<List<Position>>>[];

    for (var i = 0; i < ringData.length; i++) {
      if (!ringData[i].isHole && ringData[i].parent == null) {
        final polygonRings = <List<Position>>[];

        final exterior = List<Position>.from(ringData[i].ring);
        if (booleanClockwise(LineString(coordinates: exterior))) {
          final lastPoint = exterior.removeLast();
          final reversed = exterior.reversed.toList();
          exterior
            ..clear()
            ..addAll(reversed);

          if (lastPoint[0] != exterior.first[0] ||
              lastPoint[1] != exterior.first[1]) {
            exterior.add(PositionUtils.createPosition(exterior.first));
          } else {
            exterior.add(lastPoint);
          }
        }
        polygonRings.add(exterior);

        for (var j = 0; j < ringData.length; j++) {
          if (ringData[j].isHole && ringData[j].parent == i) {
            final hole = List<Position>.from(ringData[j].ring);

            if (!booleanClockwise(LineString(coordinates: hole))) {
              final lastPoint = hole.removeLast();
              final reversed = hole.reversed.toList();
              hole
                ..clear()
                ..addAll(reversed);

              if (lastPoint[0] != hole.first[0] ||
                  lastPoint[1] != hole.first[1]) {
                hole.add(PositionUtils.createPosition(hole.first));
              } else {
                hole.add(lastPoint);
              }
            }

            polygonRings.add(hole);
          }
        }

        polygons.add(polygonRings);
      }
    }

    return polygons;
  }
}

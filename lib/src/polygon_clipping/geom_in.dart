import 'dart:math';

import 'package:turf/helpers.dart';
import 'package:turf/src/polygon_clipping/point_extension.dart';
import 'package:turf/src/polygon_clipping/sweep_event.dart';

import 'rounder.dart';
import 'segment.dart';

//TODO: mark factory methods to remove late values;
class RingIn {
  List<Segment> segments = [];
  final bool isExterior;
  final PolyIn poly;
  late BBox bbox;

  RingIn(List<Position> geomRing, this.poly, this.isExterior) {
    final firstPoint = rounder.round(geomRing[0].lng, geomRing[0].lat);
    bbox = BBox.fromPositions(
      Position(firstPoint.lng, firstPoint.lat),
      Position(firstPoint.lng, firstPoint.lat),
    );

    var prevPoint = firstPoint;
    for (var i = 1; i < geomRing.length; i++) {
      var point = rounder.round(geomRing[i].lng, geomRing[i].lat);
      // skip repeated points
      if (point.lng == prevPoint.lng && point.lat == prevPoint.lat) continue;
      segments.add(Segment.fromRing(PositionEvents.fromPoint(prevPoint),
          PositionEvents.fromPoint(point), this));
      bbox.expandToFitPosition(point);

      prevPoint = point;
    }
    // add segment from last to first if last is not the same as first
    if (firstPoint.lng != prevPoint.lng || firstPoint.lat != prevPoint.lat) {
      segments.add(Segment.fromRing(PositionEvents.fromPoint(prevPoint),
          PositionEvents.fromPoint(firstPoint), this));
    }
  }

  List<SweepEvent> getSweepEvents() {
    final List<SweepEvent> sweepEvents = [];
    for (var i = 0; i < segments.length; i++) {
      final segment = segments[i];
      sweepEvents.add(segment.leftSE);
      sweepEvents.add(segment.rightSE);
    }
    return sweepEvents;
  }
}

//TODO: mark factory methods to remove late values;
class PolyIn {
  late RingIn exteriorRing;
  late List<RingIn> interiorRings;
  final MultiPolyIn multiPoly;
  late BBox bbox;

  PolyIn(Polygon geomPoly, this.multiPoly) {
    exteriorRing = RingIn(geomPoly.coordinates[0], this, true);
    // copy by value
    bbox = exteriorRing.bbox;

    interiorRings = [];
    Position lowerLeft = bbox.position1;
    Position upperRight = bbox.position2;
    for (var i = 1; i < geomPoly.coordinates.length; i++) {
      final ring = RingIn(geomPoly.coordinates[i], this, false);
      lowerLeft = Position(min(ring.bbox.position1.lng, lowerLeft.lng),
          min(ring.bbox.position1.lat, lowerLeft.lat));
      upperRight = Position(max(ring.bbox.position2.lng, upperRight.lng),
          max(ring.bbox.position2.lat, upperRight.lat));
      interiorRings.add(ring);
    }

    bbox = BBox.fromPositions(lowerLeft, upperRight);
  }

  List<SweepEvent> getSweepEvents() {
    final List<SweepEvent> sweepEvents = exteriorRing.getSweepEvents();
    for (var i = 0; i < interiorRings.length; i++) {
      final ringSweepEvents = interiorRings[i].getSweepEvents();
      for (var j = 0; j < ringSweepEvents.length; j++) {
        sweepEvents.add(ringSweepEvents[j]);
      }
    }
    return sweepEvents;
  }
}

//TODO: mark factory methods to remove late values;
class MultiPolyIn {
  late List<PolyIn> polys;
  final bool isSubject;
  late BBox bbox;

  MultiPolyIn(MultiPolygon geom, this.isSubject) {
    bbox = BBox.fromPositions(
      Position(double.infinity, double.infinity),
      Position(double.negativeInfinity, double.negativeInfinity),
    );

    List<Polygon> polygonsIn = geom.toPolygons();

    Position lowerLeft = bbox.position1;
    Position upperRight = bbox.position2;
    for (var i = 0; i < polygonsIn.length; i++) {
      final poly = PolyIn(polygonsIn[i], this);
      lowerLeft = Position(min(poly.bbox.position1.lng, lowerLeft.lng),
          min(poly.bbox.position1.lat, lowerLeft.lat));
      upperRight = Position(max(poly.bbox.position2.lng, upperRight.lng),
          max(poly.bbox.position2.lat, upperRight.lat));
    }

    bbox = BBox.fromPositions(lowerLeft, upperRight);
  }

  List<SweepEvent> getSweepEvents() {
    final List<SweepEvent> sweepEvents = [];
    for (var i = 0; i < polys.length; i++) {
      final polySweepEvents = polys[i].getSweepEvents();
      for (var j = 0; j < polySweepEvents.length; j++) {
        sweepEvents.add(polySweepEvents[j]);
      }
    }
    return sweepEvents;
  }
}

import 'dart:math';

import 'package:turf/src/polygon_clipping/bbox.dart';
import 'package:turf/src/polygon_clipping/point_extension.dart';

import 'rounder.dart';
import 'segment.dart';

//TODO: mark factory methods to remove late values;
class RingIn {
  List<Segment> segments = [];
  final bool isExterior;
  final PolyIn poly;
  late BoundingBox bbox;

  RingIn(List<Point> geomRing, this.poly, this.isExterior) {
    if (!(geomRing is List && geomRing.isNotEmpty)) {
      throw ArgumentError(
          "Input geometry is not a valid Polygon or MultiPolygon");
    }

    final firstPoint = rounder.round(geomRing[0].x, geomRing[0].y);
    bbox = BoundingBox(
      Point(firstPoint.x, firstPoint.y),
      Point(firstPoint.x, firstPoint.y),
    );

    var prevPoint = firstPoint;
    for (var i = 1; i < geomRing.length; i++) {
      var point = rounder.round(geomRing[i].x, geomRing[i].y);
      // skip repeated points
      if (point.x == prevPoint.x && point.y == prevPoint.y) continue;
      segments.add(Segment.fromRing(PointEvents.fromPoint(prevPoint),
          PointEvents.fromPoint(point), this));

      bbox.ll = Point(min(point.x, bbox.ll.x), min(point.y, bbox.ll.y));
      bbox.ur = Point(max(point.x, bbox.ur.x), max(point.y, bbox.ur.y));

      prevPoint = point;
    }
    // add segment from last to first if last is not the same as first
    if (firstPoint.x != prevPoint.x || firstPoint.y != prevPoint.y) {
      segments.add(Segment.fromRing(PointEvents.fromPoint(prevPoint),
          PointEvents.fromPoint(firstPoint), this));
    }
  }

  List getSweepEvents() {
    final sweepEvents = [];
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
  late BoundingBox bbox;

  PolyIn(List<dynamic> geomPoly, this.multiPoly) {
    if (!(geomPoly is List)) {
      throw ArgumentError(
          "Input geometry is not a valid Polygon or MultiPolygon");
    }
    exteriorRing = RingIn(geomPoly[0], this, true);
    // copy by value
    bbox = exteriorRing.bbox;

    interiorRings = [];
    for (var i = 1; i < geomPoly.length; i++) {
      final ring = RingIn(geomPoly[i], this, false);
      bbox.ll =
          Point(min(ring.bbox.ll.x, bbox.ll.x), min(ring.bbox.ll.y, bbox.ll.y));
      bbox.ur =
          Point(max(ring.bbox.ur.x, bbox.ur.x), max(ring.bbox.ur.y, bbox.ur.y));
      interiorRings.add(ring);
    }
  }

  List getSweepEvents() {
    final sweepEvents = exteriorRing.getSweepEvents();
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
  late BoundingBox bbox;

  MultiPolyIn(List<dynamic> geom, this.isSubject) {
    if (!(geom is List)) {
      throw ArgumentError(
          "Input geometry is not a valid Polygon or MultiPolygon");
    }

    try {
      // if the input looks like a polygon, convert it to a multipolygon
      if (geom[0][0][0] is num) geom = [geom];
    } catch (ex) {
      // The input is either malformed or has empty arrays.
      // In either case, it will be handled later on.
    }

    polys = [];
    bbox = BoundingBox(
      Point(double.infinity, double.infinity),
      Point(double.negativeInfinity, double.negativeInfinity),
    );
    for (var i = 0; i < geom.length; i++) {
      final poly = PolyIn(geom[i], this);
      bbox.ll =
          Point(min(poly.bbox.ll.x, bbox.ll.x), min(poly.bbox.ll.y, bbox.ll.y));
      bbox.ur =
          Point(max(poly.bbox.ur.x, bbox.ur.x), max(poly.bbox.ur.y, bbox.ur.y));
    }
  }

  List getSweepEvents() {
    final sweepEvents = [];
    for (var i = 0; i < polys.length; i++) {
      final polySweepEvents = polys[i].getSweepEvents();
      for (var j = 0; j < polySweepEvents.length; j++) {
        sweepEvents.add(polySweepEvents[j]);
      }
    }
    return sweepEvents;
  }
}

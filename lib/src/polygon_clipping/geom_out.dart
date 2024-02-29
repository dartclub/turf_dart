import 'package:turf/src/geojson.dart';
import 'package:turf/src/polygon_clipping/intersection.dart';
import 'package:turf/src/polygon_clipping/sweep_event.dart';
import 'package:turf/src/polygon_clipping/segment.dart';
import 'package:turf/src/polygon_clipping/vector_extension.dart';

class RingOut {
  List<SweepEvent> events;
  PolyOut? poly;

  RingOut(this.events) {
    for (int i = 0, iMax = events.length; i < iMax; i++) {
      events[i].segment!.ringOut = this;
    }
    poly = null;
  }
  /* Given the segments from the sweep line pass, compute & return a series
   * of closed rings from all the segments marked to be part of the result */
  static List<RingOut> factory(List<Segment> allSegments) {
    List<RingOut> ringsOut = [];

    for (int i = 0, iMax = allSegments.length; i < iMax; i++) {
      final Segment segment = allSegments[i];
      if (!segment.isInResult() || segment.ringOut != null) continue;

      SweepEvent prevEvent;
      SweepEvent event = segment.leftSE;
      SweepEvent nextEvent = segment.rightSE;
      final List<SweepEvent> events = [event];

      final Position startingPoint = event.point;
      final List<Intersection> intersectionLEs = [];

      while (true) {
        prevEvent = event;
        event = nextEvent;
        events.add(event);

        if (event.point == startingPoint) break;

        while (true) {
          List<SweepEvent> availableLEs = event.getAvailableLinkedEvents();

          if (availableLEs.isEmpty) {
            Position firstPt = events[0].point;
            Position lastPt = events[events.length - 1].point;
            throw Exception(
                'Unable to complete output ring starting at [${firstPt.lng}, ${firstPt.lat}]. Last matching segment found ends at [${lastPt.lng}, ${lastPt.lat}].');
          }

          if (availableLEs.length == 1) {
            nextEvent = availableLEs[0].otherSE!;
            break;
          }

          ///Index of the intersection
          int? indexLE;
          for (int j = 0, jMax = intersectionLEs.length; j < jMax; j++) {
            if (intersectionLEs[j].point == event.point) {
              indexLE = j;
              break;
            }
          }

          if (indexLE != null) {
            Intersection intersectionLE = intersectionLEs.removeAt(indexLE);
            List<SweepEvent> ringEvents = events.sublist(intersectionLE.id);
            ringEvents.insert(0, ringEvents[0].otherSE!);
            ringsOut.add(RingOut(ringEvents.reversed.toList()));
            continue;
          }

          intersectionLEs.add(Intersection(
            events.length,
            event.point,
          ));

          Comparator<SweepEvent> comparator =
              event.getLeftmostComparator(prevEvent);
          availableLEs.sort(comparator);
          nextEvent = availableLEs[0].otherSE!;
          break;
        }
      }

      ringsOut.add(RingOut(events));
    }

    return ringsOut;
  }

  bool? _isExteriorRing;

  bool get isExteriorRing {
    if (_isExteriorRing == null) {
      RingOut enclosing = enclosingRing();
      _isExteriorRing = (enclosing != null) ? !enclosing.isExteriorRing : true;
    }
    return _isExteriorRing!;
  }

  //TODO: Convert type to List<Position>?
  List<List<double>>? getGeom() {
    Position prevPt = events[0].point;
    List<Position> points = [prevPt];

    for (int i = 1, iMax = events.length - 1; i < iMax; i++) {
      Position pt = events[i].point;
      Position nextPt = events[i + 1].point;
      if (compareVectorAngles(pt, prevPt, nextPt) == 0) continue;
      points.add(pt);
      prevPt = pt;
    }

    if (points.length == 1) return null;

    Position pt = points[0];
    Position nextPt = points[1];
    if (compareVectorAngles(pt, prevPt, nextPt) == 0) points.removeAt(0);

    points.add(points[0]);
    int step = isExteriorRing ? 1 : -1;
    int iStart = isExteriorRing ? 0 : points.length - 1;
    int iEnd = isExteriorRing ? points.length : -1;
    List<List<double>> orderedPoints = [];

    for (int i = iStart; i != iEnd; i += step) {
      orderedPoints.add([points[i].lng.toDouble(), points[i].lat.toDouble()]);
    }

    return orderedPoints;
  }

  RingOut? _enclosingRing;
  RingOut enclosingRing() {
    if (_enclosingRing == null) {
      _enclosingRing = _calcEnclosingRing();
    }
    return _enclosingRing!;
  }

  RingOut? _calcEnclosingRing() {
    SweepEvent leftMostEvt = events[0];

    for (int i = 1, iMax = events.length; i < iMax; i++) {
      SweepEvent evt = events[i];
      if (SweepEvent.compare(leftMostEvt, evt) > 0) leftMostEvt = evt;
    }

    Segment? prevSeg = leftMostEvt.segment!.prevInResult();
    Segment? prevPrevSeg = prevSeg != null ? prevSeg.prevInResult() : null;

    while (true) {
      if (prevSeg == null) return null;

      if (prevPrevSeg == null) return prevSeg.ringOut;

      if (prevPrevSeg.ringOut != prevSeg.ringOut) {
        if (prevPrevSeg.ringOut!.enclosingRing() != prevSeg.ringOut) {
          return prevSeg.ringOut;
        } else {
          return prevSeg.ringOut!.enclosingRing();
        }
      }

      prevSeg = prevPrevSeg.prevInResult();
      prevPrevSeg = prevSeg != null ? prevSeg.prevInResult() : null;
    }
  }
}

class PolyOut {
  RingOut exteriorRing;
  List<RingOut> interiorRings = [];

  PolyOut(this.exteriorRing) {
    exteriorRing.poly = this;
  }

  void addInterior(RingOut ring) {
    interiorRings.add(ring);
    ring.poly = this;
  }

  List<List<List<double>>>? getGeom() {
    List<List<double>>? exteriorGeom = exteriorRing.getGeom();
    List<List<List<double>>>? geom =
        exteriorGeom != null ? [exteriorGeom] : null;

    if (geom == null) return null;

    for (int i = 0, iMax = interiorRings.length; i < iMax; i++) {
      List<List<double>>? ringGeom = interiorRings[i].getGeom();
      if (ringGeom == null) continue;
      geom.add(ringGeom);
    }

    return geom;
  }
}

class MultiPolyOut {
  List<RingOut> rings;
  late List<PolyOut> polys;

  MultiPolyOut(this.rings) {
    polys = _composePolys(rings);
  }

  List<List<List<List<double>>>> getGeom() {
    List<List<List<List<double>>>> geom = [];

    for (int i = 0, iMax = polys.length; i < iMax; i++) {
      List<List<List<double>>>? polyGeom = polys[i].getGeom();
      if (polyGeom == null) continue;
      geom.add(polyGeom);
    }

    return geom;
  }

  List<PolyOut> _composePolys(List<RingOut> rings) {
    List<PolyOut> polys = [];

    for (int i = 0, iMax = rings.length; i < iMax; i++) {
      RingOut ring = rings[i];
      if (ring.poly != null) continue;
      if (ring.isExteriorRing) {
        polys.add(PolyOut(ring));
      } else {
        RingOut enclosingRing = ring.enclosingRing();
        if (enclosingRing.poly == null) {
          polys.add(PolyOut(enclosingRing));
        }
        enclosingRing.poly!.addInterior(ring);
      }
    }

    return polys;
  }
}

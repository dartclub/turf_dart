// Give segments unique ID's to get consistent sorting of
// segments and sweep events when all else is identical

import 'package:turf/src/geojson.dart';
import 'package:turf/src/polygon_clipping/geom_out.dart';
import 'package:turf/src/polygon_clipping/operation.dart';
import 'package:turf/src/polygon_clipping/point_extension.dart';
import 'package:turf/src/polygon_clipping/rounder.dart';
import 'package:turf/src/polygon_clipping/sweep_event.dart';
import 'package:turf/src/polygon_clipping/utils.dart';
import 'package:turf/src/polygon_clipping/vector_extension.dart';

class Segment {
  static int _nextId = 1;
  int id;
  SweepEvent leftSE;
  SweepEvent rightSE;
  //TODO: can we make these empty lists instead of being nullable?
  List? rings;
  // TODO: add concrete typing for winding, should this be a nullable boolean? true, clockwise, false counter clockwhise, null unknown
  List? windings;

  ///These set later in algorithm
  Segment? consumedBy;
  Segment? prev;
  RingOut? ringOut;

  /* Warning: a reference to ringWindings input will be stored,
   *  and possibly will be later modified */
  Segment(this.leftSE, this.rightSE, this.rings, this.windings)
      //Auto increment id
      : id = _nextId++ {
    //Set intertwined relationships between segment and sweep events
    leftSE.segment = this;
    leftSE.otherSE = rightSE;

    rightSE.segment = this;
    rightSE.otherSE = leftSE;
    // left unset for performance, set later in algorithm
    // this.ringOut, this.consumedBy, this.prev
  }

  /* This compare() function is for ordering segments in the sweep
   * line tree, and does so according to the following criteria:
   *
   * Consider the vertical line that lies an infinestimal step to the
   * right of the right-more of the two left endpoints of the input
   * segments. Imagine slowly moving a point up from negative infinity
   * in the increasing y direction. Which of the two segments will that
   * point intersect first? That segment comes 'before' the other one.
   *
   * If neither segment would be intersected by such a line, (if one
   * or more of the segments are vertical) then the line to be considered
   * is directly on the right-more of the two left inputs.
   */

  //TODO: Implement compare type, should return bool?
  static int compare(Segment a, Segment b) {
    final alx = a.leftSE.point.lng;
    final blx = b.leftSE.point.lng;
    final arx = a.rightSE.point.lng;
    final brx = b.rightSE.point.lng;

    // check if they're even in the same vertical plane
    if (brx < alx) return 1;
    if (arx < blx) return -1;

    final aly = a.leftSE.point.lat;
    final bly = b.leftSE.point.lat;
    final ary = a.rightSE.point.lat;
    final bry = b.rightSE.point.lat;

    // is left endpoint of segment B the right-more?
    if (alx < blx) {
      // are the two segments in the same horizontal plane?
      if (bly < aly && bly < ary) return 1;
      if (bly > aly && bly > ary) return -1;

      // is the B left endpoint colinear to segment A?
      final aCmpBLeft = a.comparePoint(b.leftSE.point);
      if (aCmpBLeft < 0) return 1;
      if (aCmpBLeft > 0) return -1;

      // is the A right endpoint colinear to segment B ?
      final bCmpARight = b.comparePoint(a.rightSE.point);
      if (bCmpARight != 0) return bCmpARight;

      // colinear segments, consider the one with left-more
      // left endpoint to be first (arbitrary?)
      return -1;
    }

    // is left endpoint of segment A the right-more?
    if (alx > blx) {
      if (aly < bly && aly < bry) return -1;
      if (aly > bly && aly > bry) return 1;

      // is the A left endpoint colinear to segment B?
      final bCmpALeft = b.comparePoint(a.leftSE.point);
      if (bCmpALeft != 0) return bCmpALeft;

      // is the B right endpoint colinear to segment A?
      final aCmpBRight = a.comparePoint(b.rightSE.point);
      if (aCmpBRight < 0) return 1;
      if (aCmpBRight > 0) return -1;

      // colinear segments, consider the one with left-more
      // left endpoint to be first (arbitrary?)
      return 1;
    }

    // if we get here, the two left endpoints are in the same
    // vertical plane, ie alx === blx

    // consider the lower left-endpoint to come first
    if (aly < bly) return -1;
    if (aly > bly) return 1;

    // left endpoints are identical
    // check for colinearity by using the left-more right endpoint

    // is the A right endpoint more left-more?
    if (arx < brx) {
      final bCmpARight = b.comparePoint(a.rightSE.point);
      if (bCmpARight != 0) return bCmpARight;
    }

    // is the B right endpoint more left-more?
    if (arx > brx) {
      final aCmpBRight = a.comparePoint(b.rightSE.point);
      if (aCmpBRight < 0) return 1;
      if (aCmpBRight > 0) return -1;
    }

    if (arx != brx) {
      // are these two [almost] vertical segments with opposite orientation?
      // if so, the one with the lower right endpoint comes first
      final ay = ary - aly;
      final ax = arx - alx;
      final by = bry - bly;
      final bx = brx - blx;
      if (ay > ax && by < bx) return 1;
      if (ay < ax && by > bx) return -1;
    }

    // we have colinear segments with matching orientation
    // consider the one with more left-more right endpoint to be first
    if (arx > brx) return 1;
    if (arx < brx) return -1;

    // if we get here, two two right endpoints are in the same
    // vertical plane, ie arx === brx

    // consider the lower right-endpoint to come first
    if (ary < bry) return -1;
    if (ary > bry) return 1;

    // right endpoints identical as well, so the segments are idential
    // fall back on creation order as consistent tie-breaker
    if (a.id < b.id) return -1;
    if (a.id > b.id) return 1;

    // identical segment, ie a === b
    return 0;
  }

  /* Compare this segment with a point.
   *
   * A point P is considered to be colinear to a segment if there
   * exists a distance D such that if we travel along the segment
   * from one * endpoint towards the other a distance D, we find
   * ourselves at point P.
   *
   * Return value indicates:
   *
   *   1: point lies above the segment (to the left of vertical)
   *   0: point is colinear to segment
   *  -1: point lies below the segment (to the right of vertical)
   */

  //TODO: return bool?
  comparePoint(Position point) {
    if (isAnEndpoint(point)) return 0;

    final Position lPt = leftSE.point;
    final Position rPt = rightSE.point;
    final Position v = vector;

    // Exactly vertical segments.
    if (lPt.lng == rPt.lng) {
      if (point.lng == lPt.lng) return 0;
      return point.lng < lPt.lng ? 1 : -1;
    }

    // Nearly vertical segments with an intersection.
    // Check to see where a point on the line with matching Y coordinate is.
    final yDist = (point.lat - lPt.lat) / v.lat;
    final xFromYDist = lPt.lng + yDist * v.lng;
    if (point.lng == xFromYDist) return 0;

    // General case.
    // Check to see where a point on the line with matching X coordinate is.
    final xDist = (point.lng - lPt.lng) / v.lng;
    final yFromXDist = lPt.lat + xDist * v.lat;
    if (point.lat == yFromXDist) return 0;
    return point.lat < yFromXDist ? -1 : 1;
  }

  /* When a segment is split, the rightSE is replaced with a new sweep event */
  replaceRightSE(newRightSE) {
    rightSE = newRightSE;
    rightSE.segment = this;
    rightSE.otherSE = leftSE;
    leftSE.otherSE = rightSE;
  }

  /* Create Bounding Box for segment */
  BBox get bbox {
    final y1 = leftSE.point.lat;
    final y2 = rightSE.point.lat;
    return BBox.fromPositions(
      Position(leftSE.point.lng, y1 < y2 ? y1 : y2),
      Position(rightSE.point.lng, y1 > y2 ? y1 : y2),
    );
  }

  /*
   * Given another segment, returns the first non-trivial intersection
   * between the two segments (in terms of sweep line ordering), if it exists.
   *
   * A 'non-trivial' intersection is one that will cause one or both of the
   * segments to be split(). As such, 'trivial' vs. 'non-trivial' intersection:
   *
   *   * endpoint of segA with endpoint of segB --> trivial
   *   * endpoint of segA with point along segB --> non-trivial
   *   * endpoint of segB with point along segA --> non-trivial
   *   * point along segA with point along segB --> non-trivial
   *
   * If no non-trivial intersection exists, return null
   * Else, return null.
   */

  Position? getIntersection(Segment other) {
    // If bboxes don't overlap, there can't be any intersections
    final tBbox = bbox;
    final oBbox = other.bbox;
    final bboxOverlap = getBboxOverlap(tBbox, oBbox);
    if (bboxOverlap == null) return null;

    // We first check to see if the endpoints can be considered intersections.
    // This will 'snap' intersections to endpoints if possible, and will
    // handle cases of colinearity.

    final tlp = leftSE.point;
    final trp = rightSE.point;
    final olp = other.leftSE.point;
    final orp = other.rightSE.point;

    // does each endpoint touch the other segment?
    // note that we restrict the 'touching' definition to only allow segments
    // to touch endpoints that lie forward from where we are in the sweep line pass
    final touchesOtherLSE = isInBbox(tBbox, olp) && comparePoint(olp) == 0;
    final touchesThisLSE = isInBbox(oBbox, tlp) && other.comparePoint(tlp) == 0;
    final touchesOtherRSE = isInBbox(tBbox, orp) && comparePoint(orp) == 0;
    final touchesThisRSE = isInBbox(oBbox, trp) && other.comparePoint(trp) == 0;

    // do left endpoints match?
    if (touchesThisLSE && touchesOtherLSE) {
      // these two cases are for colinear segments with matching left
      // endpoints, and one segment being longer than the other
      if (touchesThisRSE && !touchesOtherRSE) return trp;
      if (!touchesThisRSE && touchesOtherRSE) return orp;
      // either the two segments match exactly (two trival intersections)
      // or just on their left endpoint (one trivial intersection
      return null;
    }

    // does this left endpoint matches (other doesn't)
    if (touchesThisLSE) {
      // check for segments that just intersect on opposing endpoints
      if (touchesOtherRSE) {
        if (tlp.lng == orp.lng && tlp.lat == orp.lat) return null;
      }
      // t-intersection on left endpoint
      return tlp;
    }

    // does other left endpoint matches (this doesn't)
    if (touchesOtherLSE) {
      // check for segments that just intersect on opposing endpoints
      if (touchesThisRSE) {
        if (trp.lng == olp.lng && trp.lat == olp.lat) return null;
      }
      // t-intersection on left endpoint
      return olp;
    }

    // trivial intersection on right endpoints
    if (touchesThisRSE && touchesOtherRSE) return null;

    // t-intersections on just one right endpoint
    if (touchesThisRSE) return trp;
    if (touchesOtherRSE) return orp;

    // None of our endpoints intersect. Look for a general intersection between
    // infinite lines laid over the segments
    Position? pt = intersection(tlp, vector, olp, other.vector);

    // are the segments parrallel? Note that if they were colinear with overlap,
    // they would have an endpoint intersection and that case was already handled above
    if (pt == null) return null;

    // is the intersection found between the lines not on the segments?
    if (!isInBbox(bboxOverlap, pt)) return null;

    // round the the computed point if needed
    return rounder.round(pt.lng, pt.lat);
  }

  /*
   * Split the given segment into multiple segments on the given points.
   *  * Each existing segment will retain its leftSE and a new rightSE will be
   *    generated for it.
   *  * A new segment will be generated which will adopt the original segment's
   *    rightSE, and a new leftSE will be generated for it.
   *  * If there are more than two points given to split on, new segments
   *    in the middle will be generated with new leftSE and rightSE's.
   *  * An array of the newly generated SweepEvents will be returned.
   *
   * Warning: input array of points is modified
   */
  //TODO: point events
  List<SweepEvent> split(PositionEvents point) {
    final List<SweepEvent> newEvents = [];
    final alreadyLinked = point.events != null;

    final newLeftSE = SweepEvent(point, true);
    final newRightSE = SweepEvent(point, false);
    final oldRightSE = rightSE;
    replaceRightSE(newRightSE);
    newEvents.add(newRightSE);
    newEvents.add(newLeftSE);
    final newSeg = Segment(
      newLeftSE,
      oldRightSE,
      //TODO: Can rings and windings be null here?
      rings != null ? List.from(rings!) : null,
      windings != null ? List.from(windings!) : null,
    );

    // when splitting a nearly vertical downward-facing segment,
    // sometimes one of the resulting new segments is vertical, in which
    // case its left and right events may need to be swapped
    if (SweepEvent.comparePoints(newSeg.leftSE.point, newSeg.rightSE.point) >
        0) {
      newSeg.swapEvents();
    }
    if (SweepEvent.comparePoints(leftSE.point, rightSE.point) > 0) {
      swapEvents();
    }

    // in the point we just used to create new sweep events with was already
    // linked to other events, we need to check if either of the affected
    // segments should be consumed
    if (alreadyLinked) {
      newLeftSE.checkForConsuming();
      newRightSE.checkForConsuming();
    }

    return newEvents;
  }

  /* Swap which event is left and right */
  swapEvents() {}

  /* Consume another segment. We take their rings under our wing
   * and mark them as consumed. Use for perfectly overlapping segments */
  consume(other) {
    Segment consumer = this;
    Segment consumee = other;
    while (consumer.consumedBy != null) {
      consumer = consumer.consumedBy!;
    }
    while (consumee.consumedBy != null) {
      consumee = consumee.consumedBy!;
    }
    ;
    final cmp = Segment.compare(consumer, consumee);
    if (cmp == 0) return; // already consumed
    // the winner of the consumption is the earlier segment
    // according to sweep line ordering
    if (cmp > 0) {
      final tmp = consumer;
      consumer = consumee;
      consumee = tmp;
    }

    // make sure a segment doesn't consume it's prev
    if (consumer.prev == consumee) {
      final tmp = consumer;
      consumer = consumee;
      consumee = tmp;
    }

    for (var i = 0, iMax = consumee.rings!.length; i < iMax; i++) {
      final ring = consumee.rings![i];
      final winding = consumee.windings![i];
      final index = consumer.rings!.indexOf(ring);
      if (index == -1) {
        consumer.rings!.add(ring);
        consumer.windings!.add(winding);
      } else {
        consumer.windings![index] += winding;
      }
    }
    consumee.rings = null;
    consumee.windings = null;
    consumee.consumedBy = consumer;

    // mark sweep events consumed as to maintain ordering in sweep event queue
    consumee.leftSE.consumedBy = consumer.leftSE;
    consumee.rightSE.consumedBy = consumer.rightSE;
  }

  static Segment fromRing(PositionEvents pt1, PositionEvents pt2, ring) {
    PositionEvents leftPt;
    PositionEvents rightPt;
    var winding;

    // ordering the two points according to sweep line ordering
    final cmpPts = SweepEvent.comparePoints(pt1, pt2);
    if (cmpPts < 0) {
      leftPt = pt1;
      rightPt = pt2;
      winding = 1;
    } else if (cmpPts > 0) {
      leftPt = pt2;
      rightPt = pt1;
      winding = -1;
    } else {
      throw Exception(
          "Tried to create degenerate segment at [${pt1.lng}, ${pt1.lat}]");
    }

    final leftSE = SweepEvent(leftPt, true);
    final rightSE = SweepEvent(rightPt, false);
    return Segment(leftSE, rightSE, [ring], [winding]);
  }

  var _prevInResult;

  /* The first segment previous segment chain that is in the result */
  Segment? prevInResult() {
    if (_prevInResult != null) return _prevInResult;
    if (prev == null) {
      _prevInResult = null;
    } else if (prev!.isInResult()) {
      _prevInResult = prev;
    } else {
      _prevInResult = prev!.prevInResult();
    }
    return _prevInResult;
  }

  _SegmentState? _beforeState;

  beforeState() {
    if (_beforeState != null) return _beforeState;
    if (prev == null) {
      _beforeState = _SegmentState(
        rings: [],
        windings: [],
        multiPolys: [],
      );
    } else {
      final Segment seg = prev!.consumedBy ?? prev!;
      _beforeState = seg.afterState();
    }
    return _beforeState;
  }

  afterState() {}

  bool? _isInResult;

  /* Is this segment part of the final result? */
  bool isInResult() {
    // if we've been consumed, we're not in the result
    if (consumedBy != null) return false;

    if (_isInResult != null) return _isInResult!;

    final mpsBefore = beforeState().multiPolys;
    final mpsAfter = afterState().multiPolys;

    switch (operation.type) {
      case "union":
        {
          // UNION - included iff:
          //  * On one side of us there is 0 poly interiors AND
          //  * On the other side there is 1 or more.
          final noBefores = mpsBefore.length == 0;
          final noAfters = mpsAfter.length == 0;
          _isInResult = noBefores != noAfters;
          break;
        }

      case "intersection":
        {
          // INTERSECTION - included iff:
          //  * on one side of us all multipolys are rep. with poly interiors AND
          //  * on the other side of us, not all multipolys are repsented
          //    with poly interiors
          int least;
          int most;
          if (mpsBefore.length < mpsAfter.length) {
            least = mpsBefore.length;
            most = mpsAfter.length;
          } else {
            least = mpsAfter.length;
            most = mpsBefore.length;
          }
          _isInResult = most == operation.numMultiPolys && least < most;
          break;
        }

      case "xor":
        {
          // XOR - included iff:
          //  * the difference between the number of multipolys represented
          //    with poly interiors on our two sides is an odd number
          final diff = (mpsBefore.length - mpsAfter.length).abs();
          _isInResult = diff % 2 == 1;
          break;
        }

      case "difference":
        {
          // DIFFERENCE included iff:
          //  * on exactly one side, we have just the subject
          bool isJustSubject(List mps) => mps.length == 1 && mps[0].isSubject;
          _isInResult = isJustSubject(mpsBefore) != isJustSubject(mpsAfter);
          break;
        }

      default:
        throw Exception('Unrecognized operation type found ${operation.type}');
    }

    return _isInResult!;
  }

  isAnEndpoint(Position pt) {
    return ((pt.lng == leftSE.point.lng && pt.lat == leftSE.point.lat) ||
        (pt.lng == rightSE.point.lng && pt.lat == rightSE.point.lat));
  }

  /* A vector from the left point to the right */
  Position get vector {
    return Position((rightSE.point.lng - leftSE.point.lng).toDouble(),
        (rightSE.point.lat - leftSE.point.lat).toDouble());
  }
}

class _SegmentState {
  List rings;
  List windings;
  List multiPolys;
  _SegmentState({
    required this.rings,
    required this.windings,
    required this.multiPolys,
  });
}

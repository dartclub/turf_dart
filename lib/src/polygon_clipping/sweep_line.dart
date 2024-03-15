import 'dart:collection';
import 'package:turf/src/geojson.dart';
import 'package:turf/src/polygon_clipping/point_extension.dart';

import 'segment.dart';
import 'sweep_event.dart';

/// Represents a sweep line used in polygon clipping algorithms.
/// The sweep line is used to efficiently process intersecting edges of polygons.
class SweepLine {
  late SplayTreeMap<Segment, void> tree;
  final List<Segment> segments = [];
  final List<SweepEvent> queue;

  SweepLine(this.queue, {int Function(Segment a, Segment b)? comparator}) {
    tree = SplayTreeMap(comparator ?? Segment.compare);
  }

  List<SweepEvent> process(SweepEvent event) {
    Segment segment = event.segment!;
    List<SweepEvent> newEvents = [];

    // if we've already been consumed by another segment,
    // clean up our body parts and get out
    if (event.consumedBy != null) {
      if (event.isLeft) {
        queue.remove(event.otherSE!);
      } else {
        tree.remove(segment);
      }
      return newEvents;
    }

    Segment? node;

    if (event.isLeft) {
      tree[segment] = null;
      node = null;
      //? Can you use SplayTreeSet lookup here? looks for internal of segment.
    } else if (tree.containsKey(segment)) {
      node = segment;
    } else {
      node = null;
    }

    if (node == null) {
      throw ArgumentError(
        'Unable to find segment #${segment.id} '
        '[${segment.leftSE.point.lng}, ${segment.leftSE.point.lat}] -> '
        '[${segment.rightSE.point.lng}, ${segment.rightSE.point.lat}] '
        'in SweepLine tree.',
      );
    }

    Segment? prevNode = node;
    Segment? nextNode = node;
    Segment? prevSeg;
    Segment? nextSeg;

    // skip consumed segments still in tree
    while (prevSeg == null) {
      prevNode = tree.lastKeyBefore(prevNode!);
      if (prevNode == null) {
        prevSeg = null;
      } else if (prevNode.consumedBy == null) {
        prevSeg = prevNode;
      }
    }

    // skip consumed segments still in tree
    while (nextSeg == null) {
      nextNode = tree.firstKeyAfter(nextNode!);
      if (nextNode == null) {
        nextSeg = null;
      } else if (nextNode.consumedBy == null) {
        nextSeg = nextNode;
      }
    }

    if (event.isLeft) {
      // Check for intersections against the previous segment in the sweep line
      Position? prevMySplitter;
      if (prevSeg != null) {
        var prevInter = prevSeg.getIntersection(segment);
        if (prevInter != null) {
          if (!segment.isAnEndpoint(prevInter)) prevMySplitter = prevInter;
          if (!prevSeg.isAnEndpoint(prevInter)) {
            var newEventsFromSplit = _splitSafely(prevSeg, prevInter);
            newEvents.addAll(newEventsFromSplit);
          }
        }
      }
      // Check for intersections against the next segment in the sweep line
      Position? nextMySplitter;
      if (nextSeg != null) {
        var nextInter = nextSeg.getIntersection(segment);
        if (nextInter != null) {
          if (!segment.isAnEndpoint(nextInter)) nextMySplitter = nextInter;
          if (!nextSeg.isAnEndpoint(nextInter)) {
            var newEventsFromSplit = _splitSafely(nextSeg, nextInter);
            newEvents.addAll(newEventsFromSplit);
          }
        }
      }

      // For simplicity, even if we find more than one intersection we only
      // spilt on the 'earliest' (sweep-line style) of the intersections.
      // The other intersection will be handled in a future process().
      Position? mySplitter;
      if (prevMySplitter == null) {
        mySplitter = nextMySplitter;
      } else if (nextMySplitter == null) {
        mySplitter = prevMySplitter;
      } else {
        var cmpSplitters = SweepEvent.comparePoints(
          prevMySplitter,
          nextMySplitter,
        );
        mySplitter = cmpSplitters <= 0 ? prevMySplitter : nextMySplitter;
      }
      //TODO: check if mySplitter is null? do we need that check?
      if (prevMySplitter != null || nextMySplitter != null) {
        queue.remove(segment.rightSE);
        newEvents.addAll(segment.split(PositionEvents.fromPoint(mySplitter!)));
      }

      if (newEvents.isNotEmpty) {
        tree.remove(segment);
        tree[segment] = null;
        newEvents.add(event);
      } else {
        segments.add(segment);
        segment.prev = prevSeg;
      }
    } else {
      if (prevSeg != null && nextSeg != null) {
        var inter = prevSeg.getIntersection(nextSeg);
        if (inter != null) {
          if (!prevSeg.isAnEndpoint(inter)) {
            var newEventsFromSplit = _splitSafely(prevSeg, inter);
            newEvents.addAll(newEventsFromSplit);
          }
          if (!nextSeg.isAnEndpoint(inter)) {
            var newEventsFromSplit = _splitSafely(nextSeg, inter);
            newEvents.addAll(newEventsFromSplit);
          }
        }
      }

      tree.remove(segment);
    }

    return newEvents;
  }

  List<SweepEvent> _splitSafely(Segment seg, dynamic pt) {
    tree.remove(seg);
    var rightSE = seg.rightSE;
    queue.remove(rightSE);
    var newEvents = seg.split(pt);
    newEvents.add(rightSE);
    if (seg.consumedBy == null) {
      tree[seg] = null;
    }
    return newEvents;
  }
}

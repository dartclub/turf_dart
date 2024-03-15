import 'dart:collection';
import 'package:turf/helpers.dart';
import 'package:turf/src/polygon_clipping/utils.dart';

import 'geom_in.dart';
import 'geom_out.dart';
import 'sweep_event.dart';
import 'sweep_line.dart';

// Limits on iterative processes to prevent infinite loops - usually caused by floating-point math round-off errors.
const int POLYGON_CLIPPING_MAX_QUEUE_SIZE =
    (bool.fromEnvironment('dart.library.io')
            ? int.fromEnvironment('POLYGON_CLIPPING_MAX_QUEUE_SIZE')
            : 1000000) ??
        1000000;
const int POLYGON_CLIPPING_MAX_SWEEPLINE_SEGMENTS =
    (bool.fromEnvironment('dart.library.io')
            ? int.fromEnvironment('POLYGON_CLIPPING_MAX_SWEEPLINE_SEGMENTS')
            : 1000000) ??
        1000000;

class Operation {
  late String type;
  int numMultiPolys = 0;

  GeometryObject? run(
      String type, GeometryObject geom, List<GeometryObject> moreGeoms) {
    this.type = type;

    if (geom is! Polygon || geom is! MultiPolygon) {
      throw Exception(
          "Input GeometryTry doesn't match Polygon or MultiPolygon");
    }

    if (geom is! Polygon) {
      geom = MultiPolygon(coordinates: [geom.coordinates]);
    }

    /* Convert inputs to MultiPoly objects */
    //TODO: handle multipolygons
    final List<MultiPolyIn> multipolys = [
      MultiPolyIn(geom as MultiPolygon, true)
    ];
    for (var i = 0; i < moreGeoms.length; i++) {
      if (moreGeoms[i] is! Polygon && moreGeoms[i] is! MultiPolygon) {
        throw Exception(
            "Input GeometryTry doesn't match Polygon or MultiPolygon");
      }
      multipolys.add(MultiPolyIn(moreGeoms[i] as MultiPolygon, false));
    }
    numMultiPolys = multipolys.length;

    /* BBox optimization for difference operation
     * If the bbox of a multipolygon that's part of the clipping doesn't
     * intersect the bbox of the subject at all, we can just drop that
     * multiploygon. */
    if (this.type == 'difference') {
      // in place removal
      final subject = multipolys[0];
      var i = 1;
      while (i < multipolys.length) {
        if (getBboxOverlap(multipolys[i].bbox, subject.bbox) != null) {
          i++;
        } else {
          multipolys.removeAt(i);
        }
      }
    }

    /* BBox optimization for intersection operation
     * If we can find any pair of multipolygons whose bbox does not overlap,
     * then the result will be empty. */
    if (this.type == 'intersection') {
      // TODO: this is O(n^2) in number of polygons. By sorting the bboxes,
      //       it could be optimized to O(n * ln(n))
      for (var i = 0; i < multipolys.length; i++) {
        final mpA = multipolys[i];
        for (var j = i + 1; j < multipolys.length; j++) {
          if (getBboxOverlap(mpA.bbox, multipolys[j].bbox) == null) {
            // todo ensure not a list if needed
            // return [];
            return null;
          }
        }
      }
    }

    /* Put segment endpoints in a priority queue */
    final queue = SplayTreeSet<SweepEvent>(SweepEvent.compare);
    for (var i = 0; i < multipolys.length; i++) {
      final sweepEvents = multipolys[i].getSweepEvents();
      for (var j = 0; j < sweepEvents.length; j++) {
        queue.add(sweepEvents[j]);

        if (queue.length > POLYGON_CLIPPING_MAX_QUEUE_SIZE) {
          // prevents an infinite loop, an otherwise common manifestation of bugs
          throw StateError(
              'Infinite loop when putting segment endpoints in a priority queue '
              '(queue size too big).');
        }
      }
    }

    /* Pass the sweep line over those endpoints */
    final sweepLine = SweepLine(queue.toList());
    var prevQueueSize = queue.length;
    var node = queue.last;
    queue.remove(node);
    while (node != null) {
      final evt = node;
      if (queue.length == prevQueueSize) {
        // prevents an infinite loop, an otherwise common manifestation of bugs
        final seg = evt.segment;
        throw StateError('Unable to pop() ${evt.isLeft ? 'left' : 'right'} '
            'SweepEvent [${evt.point.lng}, ${evt.point.lat}] from segment #${seg?.id} '
            '[${seg?.leftSE.point.lng}, ${seg?.leftSE.point.lat}] -> '
            '[${seg?.rightSE.point.lng}, ${seg?.rightSE.point.lat}] from queue.');
      }

      if (queue.length > POLYGON_CLIPPING_MAX_QUEUE_SIZE) {
        // prevents an infinite loop, an otherwise common manifestation of bugs
        throw StateError('Infinite loop when passing sweep line over endpoints '
            '(queue size too big).');
      }

      if (sweepLine.segments.length > POLYGON_CLIPPING_MAX_SWEEPLINE_SEGMENTS) {
        // prevents an infinite loop, an otherwise common manifestation of bugs
        throw StateError('Infinite loop when passing sweep line over endpoints '
            '(too many sweep line segments).');
      }

      final newEvents = sweepLine.process(evt);
      for (var i = 0; i < newEvents.length; i++) {
        final evt = newEvents[i];
        if (evt.consumedBy == null) {
          queue.add(evt);
        }
      }
      prevQueueSize = queue.length;
      node = queue.last;
      queue.remove(node);
    }

    /* Collect and compile segments we're keeping into a multipolygon */
    final ringsOut = RingOut.factory(sweepLine.segments);
    final result = MultiPolyOut(ringsOut);
    return result.getGeom();
  }
}

// singleton available by import
final operation = Operation();

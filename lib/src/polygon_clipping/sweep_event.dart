import 'package:turf/src/geojson.dart';
import 'package:turf/src/polygon_clipping/point_extension.dart';
import 'package:turf/src/polygon_clipping/vector_extension.dart';

import 'segment.dart'; // Assuming this is the Dart equivalent of your Segment class // Assuming this contains cosineOfAngle and sineOfAngle functions

/// Represents a sweep event in the polygon clipping algorithm.
///
/// A sweep event is a point where the sweep line intersects an edge of a polygon.
/// It is used in the polygon clipping algorithm to track the state of the sweep line
/// as it moves across the polygon edges.
class SweepEvent {
  static int _nextId = 1;
  int id;
  PositionEvents point;
  bool isLeft;
  Segment? segment; // Assuming these are defined in your environment
  SweepEvent? otherSE;
  SweepEvent? consumedBy;

  // Warning: 'point' input will be modified and re-used (for performance

  SweepEvent(this.point, this.isLeft) : id = _nextId++ {
    print(point);
    if (point.events == null) {
      point.events = [this];
    } else {
      point.events!.add(this);
    }
    point = point;
    // this.segment, this.otherSE set by factory
  }

  @override
  bool operator ==(Object other) {
    if (other is SweepEvent) {
      print("id matching: $id ${other.id}");
      if (isLeft == other.isLeft &&
          //Becuase segments self reference within the sweet event in their own paramenters it creates a loop that cannot be equivelant.
          segment?.id == other.segment?.id &&
          otherSE?.id == other.otherSE?.id &&
          consumedBy == other.consumedBy &&
          point == other.point) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  // for ordering sweep events in the sweep event queue
  static int compare(SweepEvent a, SweepEvent b) {
    // favor event with a point that the sweep line hits first
    final int ptCmp = SweepEvent.comparePoints(a.point, b.point);
    if (ptCmp != 0) return ptCmp;

    // the points are the same, so link them if needed
    if (a.point != b.point) a.link(b);

    // favor right events over left
    if (a.isLeft != b.isLeft) return a.isLeft ? 1 : -1;

    // we have two matching left or right endpoints
    // ordering of this case is the same as for their segments
    return Segment.compare(a.segment!, b.segment!);
  }

  static int comparePoints(Position aPt, Position bPt) {
    if (aPt.lng < bPt.lng) return -1;
    if (aPt.lng > bPt.lng) return 1;

    if (aPt.lat < bPt.lat) return -1;
    if (aPt.lat > bPt.lat) return 1;

    return 0;
  }

  void link(SweepEvent other) {
    //TODO: write test for Position comparison
    if (other.point == point) {
      throw Exception('Tried to link already linked events');
    }
    if (other.point.events == null) {
      throw Exception('PointEventsError: events called on null point.events');
    }
    for (var evt in other.point.events!) {
      point.events!.add(evt);
      evt.point = point;
    }
    checkForConsuming();
  }

  void checkForConsuming() {
    if (point.events == null) {
      throw Exception(
          'PointEventsError: events called on null point.events, method requires events');
    }
    var numEvents = point.events!.length;
    for (int i = 0; i < numEvents; i++) {
      var evt1 = point.events![i];
      if (evt1.segment == null) throw Exception("evt1.segment is null");
      if (evt1.segment!.consumedBy != null) continue;
      for (int j = i + 1; j < numEvents; j++) {
        var evt2 = point.events![j];
        if (evt2.consumedBy != null) continue;
        if (evt1.otherSE!.point.events != evt2.otherSE!.point.events) continue;
        evt1.segment!.consume(evt2.segment);
      }
    }
  }

  List<SweepEvent> getAvailableLinkedEvents() {
    List<SweepEvent> events = [];
    for (var evt in point.events!) {
      print(point.events!);
      //TODO: !evt.segment!.ringOut was written first but th

      if (evt != this &&
          evt.segment!.ringOut == null &&
          evt.segment!.isInResult()) {
        events.add(evt);
      }
    }
    return events;
  }

  Comparator<SweepEvent> getLeftmostComparator(SweepEvent baseEvent) {
    var cache = <SweepEvent, Map<String, double>>{};

    void fillCache(SweepEvent linkedEvent) {
      var nextEvent = linkedEvent.otherSE;
      if (nextEvent != null) {
        cache[linkedEvent] = {
          'sine':
              sineOfAngle(point, baseEvent.point, nextEvent!.point).toDouble(),
          'cosine':
              cosineOfAngle(point, baseEvent.point, nextEvent.point).toDouble(),
        };
      }
    }

    return (SweepEvent a, SweepEvent b) {
      if (!cache.containsKey(a)) fillCache(a);
      if (!cache.containsKey(b)) fillCache(b);

      var aValues = cache[a]!;
      var bValues = cache[b]!;

      if (aValues['sine']! >= 0 && bValues['sine']! >= 0) {
        if (aValues['cosine']! < bValues['cosine']!) return 1;
        if (aValues['cosine']! > bValues['cosine']!) return -1;
        return 0;
      }

      if (aValues['sine']! < 0 && bValues['sine']! < 0) {
        if (aValues['cosine']! < bValues['cosine']!) return -1;
        if (aValues['cosine']! > bValues['cosine']!) return 1;
        return 0;
      }

      if (bValues['sine']! < aValues['sine']!) return -1;
      if (bValues['sine']! > aValues['sine']!) return 1;
      return 0;
    };
  }

  @override
  String toString() {
    return 'SweepEvent(id:$id, point=$point, segment=${segment?.id})';
  }
}


// class Position {
//   double x;
//   double y;
//   List<SweepEvent> events;

//   Position(this.lng, this.lat);
// }

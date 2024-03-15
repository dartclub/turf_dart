import 'dart:developer';

import 'package:test/test.dart';
import 'package:turf/helpers.dart';
import 'package:turf/src/polygon_clipping/geom_in.dart';
import 'package:turf/src/polygon_clipping/point_extension.dart';
import 'package:turf/src/polygon_clipping/segment.dart';
import 'package:turf/src/polygon_clipping/sweep_event.dart';

void main() {
  group('sweep event compare', () {
    final RingIn placeholderRingIn = RingIn([
      Position(0, 0),
      Position(6, 6),
      Position(4, 2),
    ], isExterior: true);
    test('favor earlier x in point', () {
      final s1 = SweepEvent(PositionEvents(-5, 4), false);
      final s2 = SweepEvent(PositionEvents(5, 1), false);
      expect(SweepEvent.compare(s1, s2), -1);
      expect(SweepEvent.compare(s2, s1), 1);
    });

    test('then favor earlier y in point', () {
      final s1 = SweepEvent(PositionEvents(5, -4), false);
      final s2 = SweepEvent(PositionEvents(5, 4), false);
      expect(SweepEvent.compare(s1, s2), -1);
      expect(SweepEvent.compare(s2, s1), 1);
    });

    test('then favor right events over left', () {
      final seg1 = Segment.fromRing(
        PositionEvents(5, 4),
        PositionEvents(3, 2),
      );
      final seg2 = Segment.fromRing(
        PositionEvents(5, 4),
        PositionEvents(6, 5),
      );
      expect(SweepEvent.compare(seg1.rightSE, seg2.leftSE), -1);
      expect(SweepEvent.compare(seg2.leftSE, seg1.rightSE), 1);
    });

    test('then favor non-vertical segments for left events', () {
      final seg1 = Segment.fromRing(
        PositionEvents(3, 2),
        PositionEvents(3, 4),
      );
      final seg2 = Segment.fromRing(
        PositionEvents(3, 2),
        PositionEvents(5, 4),
      );
      expect(SweepEvent.compare(seg1.leftSE, seg2.rightSE), -1);
      expect(SweepEvent.compare(seg2.rightSE, seg1.leftSE), 1);
    });

    test('then favor vertical segments for right events', () {
      final seg1 = Segment.fromRing(
        PositionEvents(3, 4),
        PositionEvents(3, 2),
      );
      final seg2 = Segment.fromRing(
        PositionEvents(3, 4),
        PositionEvents(1, 2),
      );
      expect(SweepEvent.compare(seg1.leftSE, seg2.rightSE), -1);
      expect(SweepEvent.compare(seg2.rightSE, seg1.leftSE), 1);
    });

    test('then favor lower segment', () {
      final seg1 = Segment.fromRing(
        PositionEvents(0, 0),
        PositionEvents(4, 4),
      );
      final seg2 = Segment.fromRing(
        PositionEvents(0, 0),
        PositionEvents(5, 6),
      );
      expect(SweepEvent.compare(seg1.leftSE, seg2.rightSE), -1);
      expect(SweepEvent.compare(seg2.rightSE, seg1.leftSE), 1);
    });

    test('and favor barely lower segment', () {
      final seg1 = Segment.fromRing(
        PositionEvents(-75.725, 45.357),
        PositionEvents(-75.72484615384616, 45.35723076923077),
      );
      final seg2 = Segment.fromRing(
        PositionEvents(-75.725, 45.357),
        PositionEvents(-75.723, 45.36),
      );
      expect(SweepEvent.compare(seg1.leftSE, seg2.leftSE), 1);
      expect(SweepEvent.compare(seg2.leftSE, seg1.leftSE), -1);
    });

    test('then favor lower ring id', () {
      final seg1 = Segment.fromRing(
        PositionEvents(0, 0),
        PositionEvents(4, 4),
      );
      final seg2 = Segment.fromRing(
        PositionEvents(0, 0),
        PositionEvents(5, 5),
      );
      expect(SweepEvent.compare(seg1.leftSE, seg2.leftSE), -1);
      expect(SweepEvent.compare(seg2.leftSE, seg1.leftSE), 1);
    });

    test('identical equal', () {
      final s1 = SweepEvent(PositionEvents(0, 0), false);
      final s3 = SweepEvent(PositionEvents(3, 3), false);
      Segment(s1, s3);
      Segment(s1, s3);
      expect(SweepEvent.compare(s1, s1), 0);
    });

    test('totally equal but not identical events are consistent', () {
      final s1 = SweepEvent(PositionEvents(0, 0), false);
      final s2 = SweepEvent(PositionEvents(0, 0), false);
      final s3 = SweepEvent(PositionEvents(3, 3), false);
      Segment(s1, s3);
      Segment(s2, s3);
      final result = SweepEvent.compare(s1, s2);
      expect(SweepEvent.compare(s1, s2), result);
      expect(SweepEvent.compare(s2, s1), result * -1);
    });

    test('events are linked as side effect', () {
      final s1 = SweepEvent(PositionEvents(0, 0), false);
      final s2 = SweepEvent(PositionEvents(0, 0), false);
      Segment(s1, SweepEvent(PositionEvents(2, 2), false));
      Segment(s2, SweepEvent(PositionEvents(3, 4), false));
      expect(s1.point, equals(s2.point));
      SweepEvent.compare(s1, s2);
      expect(s1.point, equals(s2.point));
    });

    test('consistency edge case', () {
      final seg1 = Segment.fromRing(
        PositionEvents(-71.0390933353125, 41.504475),
        PositionEvents(-71.0389879, 41.5037842),
      );
      final seg2 = Segment.fromRing(
        PositionEvents(-71.0390933353125, 41.504475),
        PositionEvents(-71.03906280974431, 41.504275),
      );
      expect(SweepEvent.compare(seg1.leftSE, seg2.leftSE), -1);
      expect(SweepEvent.compare(seg2.leftSE, seg1.leftSE), 1);
    });
  });
  group('constructor', () {
    test('events created from same point are already linked', () {
      final p1 = PositionEvents(0, 0);
      final s1 = SweepEvent(p1, false);
      final s2 = SweepEvent(p1, false);
      expect(s1.point, equals(p1));
      expect(s1.point.events, equals(s2.point.events));
    });
  });

  group('sweep event link', () {
    test('no linked events', () {
      final s1 = SweepEvent(PositionEvents(0, 0), false);
      expect(s1.point.events, [s1]);
      expect(s1.getAvailableLinkedEvents(), []);
    });

    test('link events already linked with others', () {
      final p1 = PositionEvents(1, 2);
      final p2 = PositionEvents(2, 3);
      final se1 = SweepEvent(p1, false);
      final se2 = SweepEvent(p1, false);
      final se3 = SweepEvent(p2, false);
      final se4 = SweepEvent(p2, false);
      Segment(se1, SweepEvent(PositionEvents(5, 5), false));
      Segment(se2, SweepEvent(PositionEvents(6, 6), false));
      Segment(se3, SweepEvent(PositionEvents(7, 7), false));
      Segment(se4, SweepEvent(PositionEvents(8, 8), false));
      se1.link(se3);
      // expect(se1.point.events!.length, 4);
      expect(se1.point, se2.point);
      expect(se1.point, se3.point);
      expect(se1.point, se4.point);
    });

    test('same event twice', () {
      final p1 = PositionEvents(0, 0);
      final s1 = SweepEvent(p1, false);
      final s2 = SweepEvent(p1, false);
      expect(() => s2.link(s1), throwsException);
      expect(() => s1.link(s2), throwsException);
    });

    test('unavailable linked events do not show up', () {
      final p1 = PositionEvents(0, 0);
      final p2 = PositionEvents(1, 1);
      final p3 = PositionEvents(1, 0);
      final se1 = SweepEvent(p1, false);
      final se2 = SweepEvent(p2, false);
      final se3 = SweepEvent(p3, true);
      final seNotInResult = SweepEvent(p1, false);
      seNotInResult.segment = Segment(se2, se3, forceIsInResult: false);
      print(seNotInResult);
      expect(se1.getAvailableLinkedEvents(), []);
    });

    test('available linked events show up', () {
      final p1 = PositionEvents(0, 0);
      final p2 = PositionEvents(1, 1);
      final p3 = PositionEvents(1, 0);
      final se1 = SweepEvent(p1, false);
      final se2 = SweepEvent(p2, false);
      final se3 = SweepEvent(p3, true);
      final seOkay = SweepEvent(p1, false);
      seOkay.segment = Segment(se2, se3, forceIsInResult: true);
      List<SweepEvent> events = se1.getAvailableLinkedEvents();
      expect(events[0], equals(seOkay));
    });

    //TODO: verify constructor functioning with reference events
    // test('link goes both ways', () {
    //   // final p2 = PositionEvents(1, 1);
    //   // final p3 = PositionEvents(1, 0);
    //   // final se2 = SweepEvent(p2, false);
    //   // final se3 = SweepEvent(p3, false);

    //   final p1 = PositionEvents(0, 0);
    //   final se1 = SweepEvent(p1, false);
    //   print(se1);
    //   final seOkay1 = SweepEvent(p1, false);
    //   print(seOkay1);
    //   final seOkay2 = SweepEvent(p1, false);
    //   print(seOkay2);
    //   seOkay1.segment = Segment(
    //     se1,
    //     seOkay1,
    //     forceIsInResult: true,
    //   );
    //   seOkay2.segment = Segment(
    //     se1,
    //     seOkay2,
    //     forceIsInResult: true,
    //   );
    //   expect(seOkay1.getAvailableLinkedEvents(), [seOkay2]);
    //   expect(seOkay2.getAvailableLinkedEvents(), [seOkay1]);
    // });
  });

  group('sweep event get leftmost comparator', () {
    test('after a segment straight to the right', () {
      final prevEvent = SweepEvent(PositionEvents(0, 0), false);
      final event = SweepEvent(PositionEvents(1, 0), false);
      final comparator = event.getLeftmostComparator(prevEvent);

      final e1 = SweepEvent(PositionEvents(1, 0), false);
      Segment(e1, SweepEvent(PositionEvents(0, 1), false));

      final e2 = SweepEvent(PositionEvents(1, 0), false);
      Segment(e2, SweepEvent(PositionEvents(1, 1), false));

      final e3 = SweepEvent(PositionEvents(1, 0), false);
      Segment(e3, SweepEvent(PositionEvents(2, 0), false));

      final e4 = SweepEvent(PositionEvents(1, 0), false);
      Segment(e4, SweepEvent(PositionEvents(1, -1), false));

      final e5 = SweepEvent(PositionEvents(1, 0), false);
      Segment(e5, SweepEvent(PositionEvents(0, -1), false));

      expect(comparator(e1, e2), -1);
      expect(comparator(e2, e3), -1);
      expect(comparator(e3, e4), -1);
      expect(comparator(e4, e5), -1);

      expect(comparator(e2, e1), 1);
      expect(comparator(e3, e2), 1);
      expect(comparator(e4, e3), 1);
      expect(comparator(e5, e4), 1);

      expect(comparator(e1, e3), -1);
      expect(comparator(e1, e4), -1);
      expect(comparator(e1, e5), -1);

      expect(comparator(e1, e1), 0);
    });

    test('after a down and to the left', () {
      final prevEvent = SweepEvent(PositionEvents(1, 1), false);
      final event = SweepEvent(PositionEvents(0, 0), false);
      final comparator = event.getLeftmostComparator(prevEvent);

      final e1 = SweepEvent(PositionEvents(0, 0), false);
      Segment(e1, SweepEvent(PositionEvents(0, 1), false));

      final e2 = SweepEvent(PositionEvents(0, 0), false);
      Segment(e2, SweepEvent(PositionEvents(1, 0), false));

      final e3 = SweepEvent(PositionEvents(0, 0), false);
      Segment(e3, SweepEvent(PositionEvents(0, -1), false));

      final e4 = SweepEvent(PositionEvents(0, 0), false);
      Segment(e4, SweepEvent(PositionEvents(-1, 0), false));

      expect(comparator(e1, e2), 1);
      expect(comparator(e1, e3), 1);
      expect(comparator(e1, e4), 1);

      expect(comparator(e2, e1), -1);
      expect(comparator(e2, e3), -1);
      expect(comparator(e2, e4), -1);

      expect(comparator(e3, e1), -1);
      expect(comparator(e3, e2), 1);
      expect(comparator(e3, e4), -1);

      expect(comparator(e4, e1), -1);
      expect(comparator(e4, e2), 1);
      expect(comparator(e4, e3), 1);
    });
  });
}

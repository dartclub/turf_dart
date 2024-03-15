import 'package:test/test.dart';
import 'package:turf/src/polygon_clipping/geom_in.dart';
import 'package:turf/src/polygon_clipping/point_extension.dart';
import 'package:turf/src/polygon_clipping/segment.dart';
import 'package:turf/src/polygon_clipping/sweep_event.dart';
import 'package:turf/turf.dart';

void main() {
  group("constructor", () {
    test("general", () {
      final leftSE = SweepEvent(PositionEvents(0, 0), false);
      final rightSE = SweepEvent(PositionEvents(1, 1), false);
      final List<RingIn>? rings = [];
      final List<int> windings = [];
      final seg = Segment(leftSE, rightSE, rings: rings, windings: windings);
      expect(seg.rings, rings);
      expect(seg.windings, windings);
      expect(seg.leftSE, leftSE);
      expect(seg.leftSE.otherSE, rightSE);
      expect(seg.rightSE, rightSE);
      expect(seg.rightSE.otherSE, leftSE);
      expect(seg.ringOut, null);
      expect(seg.prev, null);
      expect(seg.consumedBy, null);
    });

    test("segment Id increments", () {
      final leftSE = SweepEvent(PositionEvents(0, 0), false);
      final rightSE = SweepEvent(PositionEvents(1, 1), false);
      final seg1 = Segment(
        leftSE,
        rightSE,
      );
      final seg2 = Segment(
        leftSE,
        rightSE,
      );
      expect(seg2.id - seg1.id, 1);
    });
  });

  group("fromRing", () {
    test("correct point on left and right 1", () {
      final p1 = PositionEvents(0, 0);
      final p2 = PositionEvents(0, 1);
      final seg = Segment.fromRing(p1, p2);
      expect(seg.leftSE.point, p1);
      expect(seg.rightSE.point, p2);
    });

    test("correct point on left and right 1", () {
      final p1 = PositionEvents(0, 0);
      final p2 = PositionEvents(-1, 0);
      final seg = Segment.fromRing(p1, p2);
      expect(seg.leftSE.point, p2);
      expect(seg.rightSE.point, p1);
    });

    test("attempt create segment with same points", () {
      final p1 = PositionEvents(0, 0);
      final p2 = PositionEvents(0, 0);
      expect(() => Segment.fromRing(p1, p2), throwsException);
    });
  });

  group("split", () {
    test("on interior point", () {
      final seg = Segment.fromRing(
        PositionEvents(0, 0),
        PositionEvents(10, 10),
      );
      final pt = PositionEvents(5, 5);
      final evts = seg.split(pt);
      expect(evts[0].segment, seg);
      expect(evts[0].point, pt);
      expect(evts[0].isLeft, false);
      expect(evts[0].otherSE!.otherSE, evts[0]);
      expect(evts[1].segment!.leftSE.segment, evts[1].segment);
      expect(evts[1].segment, isNot(seg));
      expect(evts[1].point, pt);
      expect(evts[1].isLeft, true);
      expect(evts[1].otherSE!.otherSE, evts[1]);
      expect(evts[1].segment!.rightSE.segment, evts[1].segment);
    });

    test("on close-to-but-not-exactly interior point", () {
      final seg = Segment.fromRing(
        PositionEvents(0, 10),
        PositionEvents(10, 0),
      );
      final pt = PositionEvents(5 + epsilon, 5);
      final evts = seg.split(pt);
      expect(evts[0].segment, seg);
      expect(evts[0].point, pt);
      expect(evts[0].isLeft, false);
      expect(evts[1].segment, isNot(seg));
      expect(evts[1].point, pt);
      expect(evts[1].isLeft, true);
      expect(evts[1].segment!.rightSE.segment, evts[1].segment);
    });

    test("on three interior points", () {
      final seg = Segment.fromRing(
        PositionEvents(0, 0),
        PositionEvents(10, 10),
      );
      final sPt1 = PositionEvents(2, 2);
      final sPt2 = PositionEvents(4, 4);
      final sPt3 = PositionEvents(6, 6);

      final orgLeftEvt = seg.leftSE;
      final orgRightEvt = seg.rightSE;
      final newEvts3 = seg.split(sPt3);
      final newEvts2 = seg.split(sPt2);
      final newEvts1 = seg.split(sPt1);
      final newEvts = [...newEvts1, ...newEvts2, ...newEvts3];

      expect(newEvts.length, 6);

      expect(seg.leftSE, orgLeftEvt);
      var evt = newEvts.firstWhere((e) => e.point == sPt1 && !e.isLeft);
      expect(seg.rightSE, evt);

      evt = newEvts.firstWhere((e) => e.point == sPt1 && e.isLeft);
      var otherEvt = newEvts.firstWhere((e) => e.point == sPt2 && !e.isLeft);
      expect(evt.segment, otherEvt.segment);

      evt = newEvts.firstWhere((e) => e.point == sPt2 && e.isLeft);
      otherEvt = newEvts.firstWhere((e) => e.point == sPt3 && !e.isLeft);
      expect(evt.segment, otherEvt.segment);

      evt = newEvts.firstWhere((e) => e.point == sPt3 && e.isLeft);
      expect(evt.segment, orgRightEvt.segment);
    });
  });

  group("simple properties - bbox, vector", () {
    test("general", () {
      final seg = Segment.fromRing(PositionEvents(1, 2), PositionEvents(3, 4));
      expect(seg.bbox,
          BBox.fromPositions(PositionEvents(1, 2), PositionEvents(3, 4)));
      expect(seg.vector, Position(2, 2));
    });

    test("horizontal", () {
      final seg = Segment.fromRing(PositionEvents(1, 4), PositionEvents(3, 4));
      expect(
          seg.bbox, equals(BBox.fromPositions(Position(1, 4), Position(3, 4))));
      expect(seg.vector, Position(2, 0));
    });

    test("vertical", () {
      final seg = Segment.fromRing(PositionEvents(3, 2), PositionEvents(3, 4));
      expect(seg.bbox,
          BBox.fromPositions(PositionEvents(3, 2), PositionEvents(3, 4)));
      expect(seg.vector, Position(0, 2));
    });
  });

  group("consume()", () {
    test("not automatically consumed", () {
      final p1 = PositionEvents(0, 0);
      final p2 = PositionEvents(1, 0);
      final seg1 = Segment.fromRing(p1, p2);
      final seg2 = Segment.fromRing(p1, p2);
      expect(seg1.consumedBy, null);
      expect(seg2.consumedBy, null);
    });

    test("basic case", () {
      final p1 = PositionEvents(0, 0);
      final p2 = PositionEvents(1, 0);
      final seg1 = Segment.fromRing(
        p1,
        p2,
        // {},
      );
      final seg2 = Segment.fromRing(
        p1,
        p2,
        // {},
      );
      seg1.consume(seg2);
      expect(seg2.consumedBy, seg1);
      expect(seg1.consumedBy, null);
    });

    test("ealier in sweep line sorting consumes later", () {
      final p1 = PositionEvents(0, 0);
      final p2 = PositionEvents(1, 0);
      final seg1 = Segment.fromRing(
        p1,
        p2,
        // {},
      );
      final seg2 = Segment.fromRing(
        p1,
        p2,
        // {},
      );
      seg2.consume(seg1);
      expect(seg2.consumedBy, seg1);
      expect(seg1.consumedBy, null);
    });

    test("consuming cascades", () {
      final p1 = PositionEvents(0, 0);
      final p2 = PositionEvents(0, 0);
      final p3 = PositionEvents(1, 0);
      final p4 = PositionEvents(1, 0);
      final seg1 = Segment.fromRing(
        p1,
        p3,
        // {},
      );
      final seg2 = Segment.fromRing(
        p1,
        p3,
        // {},
      );
      final seg3 = Segment.fromRing(
        p2,
        p4,
        // {},
      );
      final seg4 = Segment.fromRing(
        p2,
        p4,
        // {},
      );
      final seg5 = Segment.fromRing(
        p2,
        p4,
        // {},
      );
      seg1.consume(seg2);
      seg4.consume(seg2);
      seg3.consume(seg2);
      seg3.consume(seg5);
      expect(seg1.consumedBy, null);
      expect(seg2.consumedBy, seg1);
      expect(seg3.consumedBy, seg1);
      expect(seg4.consumedBy, seg1);
      expect(seg5.consumedBy, seg1);
    });
  });

  group("is an endpoint", () {
    final p1 = PositionEvents(0, -1);
    final p2 = PositionEvents(1, 0);
    final seg = Segment.fromRing(p1, p2);

    test("yup", () {
      expect(seg.isAnEndpoint(p1), true);
      expect(seg.isAnEndpoint(p2), true);
    });

    test("nope", () {
      expect(seg.isAnEndpoint(PositionEvents(-34, 46)), false);
      expect(seg.isAnEndpoint(PositionEvents(0, 0)), false);
    });
  });

  group("comparison with point", () {
    test("general", () {
      final s1 = Segment.fromRing(PositionEvents(0, 0), PositionEvents(1, 1));
      final s2 = Segment.fromRing(PositionEvents(0, 1), PositionEvents(0, 0));

      expect(s1.comparePoint(PositionEvents(0, 1)), 1);
      expect(s1.comparePoint(PositionEvents(1, 2)), 1);
      expect(s1.comparePoint(PositionEvents(0, 0)), 0);
      expect(s1.comparePoint(PositionEvents(5, -1)), -1);

      expect(s2.comparePoint(PositionEvents(0, 1)), 0);
      expect(s2.comparePoint(PositionEvents(1, 2)), -1);
      expect(s2.comparePoint(PositionEvents(0, 0)), 0);
      expect(s2.comparePoint(PositionEvents(5, -1)), -1);
    });

    test("barely above", () {
      final s1 = Segment.fromRing(PositionEvents(1, 1), PositionEvents(3, 1));
      final pt = PositionEvents(2, 1 - epsilon);
      expect(s1.comparePoint(pt), -1);
    });

    test("barely below", () {
      final s1 = Segment.fromRing(PositionEvents(1, 1), PositionEvents(3, 1));
      final pt = PositionEvents(2, 1 + (epsilon * 3) / 2);
      expect(s1.comparePoint(pt), 1);
    });

    test("vertical before", () {
      final seg = Segment.fromRing(PositionEvents(1, 1), PositionEvents(1, 3));
      final pt = PositionEvents(0, 0);
      expect(seg.comparePoint(pt), 1);
    });

    test("vertical after", () {
      final seg = Segment.fromRing(PositionEvents(1, 1), PositionEvents(1, 3));
      final pt = PositionEvents(2, 0);
      expect(seg.comparePoint(pt), -1);
    });

    test("vertical on", () {
      final seg = Segment.fromRing(PositionEvents(1, 1), PositionEvents(1, 3));
      final pt = PositionEvents(1, 0);
      expect(seg.comparePoint(pt), 0);
    });

    test("horizontal below", () {
      final seg = Segment.fromRing(PositionEvents(1, 1), PositionEvents(3, 1));
      final pt = PositionEvents(0, 0);
      expect(seg.comparePoint(pt), -1);
    });

    test("horizontal above", () {
      final seg = Segment.fromRing(PositionEvents(1, 1), PositionEvents(3, 1));
      final pt = PositionEvents(0, 2);
      expect(seg.comparePoint(pt), 1);
    });

    test("horizontal on", () {
      final seg = Segment.fromRing(PositionEvents(1, 1), PositionEvents(3, 1));
      final pt = PositionEvents(0, 1);
      expect(seg.comparePoint(pt), 0);
    });

    test("in vertical plane below", () {
      final seg = Segment.fromRing(PositionEvents(1, 1), PositionEvents(3, 3));
      final pt = PositionEvents(2, 0);
      expect(seg.comparePoint(pt), -1);
    });

    test("in vertical plane above", () {
      final seg = Segment.fromRing(PositionEvents(1, 1), PositionEvents(3, 3));
      final pt = PositionEvents(2, 4);
      expect(seg.comparePoint(pt), 1);
    });

    test("in horizontal plane upward sloping before", () {
      final seg = Segment.fromRing(PositionEvents(1, 1), PositionEvents(3, 3));
      final pt = PositionEvents(0, 2);
      expect(seg.comparePoint(pt), 1);
    });

    test("in horizontal plane upward sloping after", () {
      final seg = Segment.fromRing(PositionEvents(1, 1), PositionEvents(3, 3));
      final pt = PositionEvents(4, 2);
      expect(seg.comparePoint(pt), -1);
    });

    test("in horizontal plane downward sloping before", () {
      final seg = Segment.fromRing(PositionEvents(1, 3), PositionEvents(3, 1));
      final pt = PositionEvents(0, 2);
      expect(seg.comparePoint(pt), -1);
    });

    test("in horizontal plane downward sloping after", () {
      final seg = Segment.fromRing(PositionEvents(1, 3), PositionEvents(3, 1));
      final pt = PositionEvents(4, 2);
      expect(seg.comparePoint(pt), 1);
    });

    test("upward more vertical before", () {
      final seg = Segment.fromRing(PositionEvents(1, 1), PositionEvents(3, 6));
      final pt = PositionEvents(0, 2);
      expect(seg.comparePoint(pt), 1);
    });

    test("upward more vertical after", () {
      final seg = Segment.fromRing(PositionEvents(1, 1), PositionEvents(3, 6));
      final pt = PositionEvents(4, 2);
      expect(seg.comparePoint(pt), -1);
    });

    test("downward more vertical before", () {
      final seg = Segment.fromRing(PositionEvents(1, 6), PositionEvents(3, 1));
      final pt = PositionEvents(0, 2);
      expect(seg.comparePoint(pt), -1);
    });

    test("downward more vertical after", () {
      final seg = Segment.fromRing(PositionEvents(1, 6), PositionEvents(3, 1));
      final pt = PositionEvents(4, 2);
      expect(seg.comparePoint(pt), 1);
    });

    test("downward-slopping segment with almost touching point - from issue 37",
        () {
      final seg = Segment.fromRing(
        PositionEvents(0.523985, 51.281651),
        PositionEvents(0.5241, 51.281651000100005),
      );
      final pt = PositionEvents(0.5239850000000027, 51.281651000000004);
      expect(seg.comparePoint(pt), 1);
    });

    test("avoid splitting loops on near vertical segments - from issue 60-2",
        () {
      final seg = Segment.fromRing(
        PositionEvents(-45.3269382, -1.4059341),
        PositionEvents(-45.326737413921656, -1.40635),
      );
      final pt = PositionEvents(-45.326833968900424, -1.40615);
      expect(seg.comparePoint(pt), 0);
    });
  });
}

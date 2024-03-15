import 'package:test/test.dart';
import 'package:turf/src/polygon_clipping/point_extension.dart';
import 'package:turf/src/polygon_clipping/segment.dart';
import 'package:turf/src/polygon_clipping/sweep_event.dart';
import 'package:turf/src/polygon_clipping/sweep_line.dart';

void main() {
  test('Test tree construction', () {
    final sl = SweepLine(
      [],
    );

    final leftSE1 = SweepEvent(PositionEvents(0, 0), true);
    final rightSE1 = SweepEvent(PositionEvents(10, 10), false);
    final segment1 = Segment(
      leftSE1,
      rightSE1,
    );

    final leftSE2 = SweepEvent(PositionEvents(5, 5), true);
    final rightSE2 = SweepEvent(PositionEvents(15, 15), false);
    final segment2 = Segment(
      leftSE2,
      rightSE2,
    );

    sl.tree[segment1] = null;
    sl.tree[segment2] = null;

    expect(sl.tree.containsKey(segment1), equals(true));
    expect(sl.tree.containsKey(segment2), equals(true));
  });
  group("Test tree", () {
    final sl = SweepLine(
      [],
    );

    final leftSE1 = SweepEvent(PositionEvents(0, 0), true);
    final rightSE1 = SweepEvent(PositionEvents(10, 10), false);
    final segment1 = Segment(
      leftSE1,
      rightSE1,
    );

    final leftSE2 = SweepEvent(PositionEvents(5, 5), true);
    final rightSE2 = SweepEvent(PositionEvents(15, 15), false);
    final segment2 = Segment(
      leftSE2,
      rightSE2,
    );

    final leftSE3 = SweepEvent(PositionEvents(20, 20), true);
    final rightSE3 = SweepEvent(PositionEvents(25, 10), false);
    final segment3 = Segment(
      leftSE3,
      rightSE3,
    );

    final leftSE4 = SweepEvent(PositionEvents(5, 5), true);
    final rightSE4 = SweepEvent(PositionEvents(10, 10), false);
    final segment4 = Segment(
      leftSE4,
      rightSE4,
    );

    test("test filling up the tree then emptying it out", () {
      // var n1 = sl.tree[segment1];
      // var segment2 = sl.tree[segment2];
      // var segment4 = sl.tree[segment4];
      // var segment3 = sl.tree[segment3];

      sl.tree[segment1] = null;
      sl.tree[segment2] = null;
      sl.tree[segment3] = null;
      sl.tree[segment4] = null;

      expect(sl.tree.containsKey(segment1), equals(true));
      expect(sl.tree.containsKey(segment2), equals(true));
      expect(sl.tree.containsKey(segment3), equals(true));
      expect(sl.tree.containsKey(segment4), equals(true));

      // expect(sl.tree.lastKeyBefore(segment1), isNull);
      // expect(sl.tree.firstKeyAfter(segment1), equals(segment2));

      // expect(sl.tree.lastKeyBefore(segment2), equals(segment1));
      // expect(sl.tree.firstKeyAfter(segment2), equals(segment3));

      // expect(sl.tree.lastKeyBefore(segment3), equals(segment2));
      // expect(sl.tree.firstKeyAfter(segment3), equals(segment4));

      // expect(sl.tree.lastKeyBefore(segment4), equals(segment3));
      // expect(sl.tree.firstKeyAfter(segment4), isNull);

      sl.tree.remove(segment2);
      expect(sl.tree.containsKey(segment2), isNull);

      // n1 = sl.tree.containsKey(segment1);
      // segment3 = sl.tree.containsKey(segment3);
      // segment4 = sl.tree.containsKey(segment4);

      // expect(sl.tree.lastKeyBefore(n1), isNull);
      // expect(sl.tree.firstKeyAfter(n1), equals(segment3));

      // expect(sl.tree.lastKeyBefore(segment3), equals(segment1));
      // expect(sl.tree.firstKeyAfter(segment3), equals(segment4));

      // expect(sl.tree.lastKeyBefore(segment4), equals(segment3));
      // expect(sl.tree.firstKeyAfter(segment4), isNull);

      // sl.tree.remove(segment4);
      // expect(sl.tree.containsKey(segment4), isNull);

      // n1 = sl.tree.containsKey(segment1);
      // segment3 = sl.tree.containsKey(segment3);

      // expect(sl.tree.lastKeyBefore(n1), isNull);
      // expect(sl.tree.firstKeyAfter(n1), equals(segment3));

      // expect(sl.tree.lastKeyBefore(segment3), equals(segment1));
      // expect(sl.tree.firstKeyAfter(segment3), isNull);

      // sl.tree.remove(segment1);
      // expect(sl.tree.containsKey(segment1), isNull);

      // segment3 = sl.tree.containsKey(segment3);

      // expect(sl.tree.lastKeyBefore(segment3), isNull);
      // expect(sl.tree.firstKeyAfter(segment3), isNull);

      // sl.tree.remove(segment3);
      // expect(sl.tree.containsKey(segment3), isNull);
    });
  });
}

import 'package:test/test.dart';
import 'package:turf/src/geojson.dart';
import 'package:turf/src/polygon_clipping/geom_out.dart';
import 'package:turf/src/polygon_clipping/point_extension.dart';
import 'package:turf/src/polygon_clipping/segment.dart';

void main() {
  test('simple triangle', () {
    final p1 = PositionEvents(0, 0);
    final p2 = PositionEvents(1, 1);
    final p3 = PositionEvents(0, 1);

    final seg1 = Segment.fromRing(p1, p2, forceIsInResult: true);
    final seg2 = Segment.fromRing(p2, p3, forceIsInResult: true);
    final seg3 = Segment.fromRing(p3, p1, forceIsInResult: true);

    final rings = RingOut.factory([seg1, seg2, seg3]);

    expect(rings.length, 1);
    expect(rings[0].getGeom(), [
      [0, 0],
      [1, 1],
      [0, 1],
      [0, 0],
    ]);
  });

  test('bow tie', () {
    final p1 = PositionEvents(0, 0);
    final p2 = PositionEvents(1, 1);
    final p3 = PositionEvents(0, 2);

    final seg1 = Segment.fromRing(p1, p2);
    final seg2 = Segment.fromRing(p2, p3);
    final seg3 = Segment.fromRing(p3, p1);

    final p4 = PositionEvents(2, 0);
    final p5 = p2;
    final p6 = PositionEvents(2, 2);

    final seg4 = Segment.fromRing(p4, p5);
    final seg5 = Segment.fromRing(p5, p6);
    final seg6 = Segment.fromRing(p6, p4);

    // seg1.isInResult = true;
    // seg2.isInResult = true;
    // seg3.isInResult = true;
    // seg4.isInResult = true;
    // seg5.isInResult = true;
    // seg6.isInResult = true;

    final rings = RingOut.factory([seg1, seg2, seg3, seg4, seg5, seg6]);

    expect(rings.length, 2);
    expect(rings[0].getGeom(), [
      [0, 0],
      [1, 1],
      [0, 2],
      [0, 0],
    ]);
    expect(rings[1].getGeom(), [
      [1, 1],
      [2, 0],
      [2, 2],
      [1, 1],
    ]);
  });
}

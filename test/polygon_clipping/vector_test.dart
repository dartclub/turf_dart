import 'package:test/test.dart';
import 'package:turf/helpers.dart';
import 'package:turf/src/polygon_clipping/vector_extension.dart';

void main() {
  group('cross product', () {
    test('general', () {
      final Position pt1 = Position(1, 2);
      final Position pt2 = Position(3, 4);
      expect(crossProductMagnitude(pt1, pt2), -2);
    });
  });

  group('dot product', () {
    test('general', () {
      final Position pt1 = Position(1, 2);
      final Position pt2 = Position(3, 4);
      expect(pt1.dotProduct(pt2), 11);
    });
  });

  group('length()', () {
    test('horizontal', () {
      final Position v = Position(3, 0);
      expect(vectorLength(v), 3);
    });

    test('vertical', () {
      final Position v = Position(0, -2);
      expect(vectorLength(v), 2);
    });

    test('3-4-5', () {
      final Position v = Position(3, 4);
      expect(vectorLength(v), 5);
    });
  });

  group('compare vector angles', () {
    test('colinear', () {
      final Position pt1 = Position(1, 1);
      final Position pt2 = Position(2, 2);
      final Position pt3 = Position(3, 3);

      expect(compareVectorAngles(pt1, pt2, pt3), 0);
      expect(compareVectorAngles(pt2, pt1, pt3), 0);
      expect(compareVectorAngles(pt2, pt3, pt1), 0);
      expect(compareVectorAngles(pt3, pt2, pt1), 0);
    });

    test('offset', () {
      final Position pt1 = Position(0, 0);
      final Position pt2 = Position(1, 1);
      final Position pt3 = Position(1, 0);

      expect(compareVectorAngles(pt1, pt2, pt3), -1);
      expect(compareVectorAngles(pt2, pt1, pt3), 1);
      expect(compareVectorAngles(pt2, pt3, pt1), -1);
      expect(compareVectorAngles(pt3, pt2, pt1), 1);
    });
  });

  group('sine and cosine of angle', () {
    group('parallel', () {
      final Position shared = Position(0, 0);
      final Position base = Position(1, 0);
      final Position angle = Position(1, 0);
      test('sine', () {
        expect(sineOfAngle(shared, base, angle), 0);
      });
      test('cosine', () {
        expect(cosineOfAngle(shared, base, angle), 1);
      });
    });

    group('45 degrees', () {
      final Position shared = Position(0, 0);
      final Position base = Position(1, 0);
      final Position angle = Position(1, -1);
      test('sine', () {
        expect(sineOfAngle(shared, base, angle), closeTo(0.707, 0.001));
      });
      test('cosine', () {
        expect(cosineOfAngle(shared, base, angle), closeTo(0.707, 0.001));
      });
    });

    group('90 degrees', () {
      final Position shared = Position(0, 0);
      final Position base = Position(1, 0);
      final Position angle = Position(0, -1);
      test('sine', () {
        expect(sineOfAngle(shared, base, angle), 1);
      });
      test('cosine', () {
        expect(cosineOfAngle(shared, base, angle), 0);
      });
    });

    group('135 degrees', () {
      final Position shared = Position(0, 0);
      final Position base = Position(1, 0);
      final Position angle = Position(-1, -1);
      test('sine', () {
        expect(sineOfAngle(shared, base, angle), closeTo(0.707, 0.001));
      });
      test('cosine', () {
        expect(cosineOfAngle(shared, base, angle), closeTo(-0.707, 0.001));
      });
    });

    group('anti-parallel', () {
      final Position shared = Position(0, 0);
      final Position base = Position(1, 0);
      final Position angle = Position(-1, 0);
      test('sine', () {
        expect(sineOfAngle(shared, base, angle), -0);
      });
      test('cosine', () {
        expect(cosineOfAngle(shared, base, angle), -1);
      });
    });

    group('225 degrees', () {
      final Position shared = Position(0, 0);
      final Position base = Position(1, 0);
      final Position angle = Position(-1, 1);
      test('sine', () {
        expect(sineOfAngle(shared, base, angle), closeTo(-0.707, 0.001));
      });
      test('cosine', () {
        expect(cosineOfAngle(shared, base, angle), closeTo(-0.707, 0.001));
      });
    });

    group('270 degrees', () {
      final Position shared = Position(0, 0);
      final Position base = Position(1, 0);
      final Position angle = Position(0, 1);
      test('sine', () {
        expect(sineOfAngle(shared, base, angle), -1);
      });
      test('cosine', () {
        expect(cosineOfAngle(shared, base, angle), 0);
      });
    });

    group('315 degrees', () {
      final Position shared = Position(0, 0);
      final Position base = Position(1, 0);
      final Position angle = Position(1, 1);
      test('sine', () {
        expect(sineOfAngle(shared, base, angle), closeTo(-0.707, 0.001));
      });
      test('cosine', () {
        expect(cosineOfAngle(shared, base, angle), closeTo(0.707, 0.001));
      });
    });
  });

  // group('perpendicular()', () {
  //   test('vertical', () {
  //     final Position v = Position( 0,  1);
  //     final Position r = perpendicular(v);
  //     expect(dotProduct(v, r), 0);
  //     expect(crossProduct(v, r), isNot(0));
  //   });

  //   test('horizontal', () {
  //     final Position v = Position( 1,  0);
  //     final Position r = perpendicular(v);
  //     expect(dotProduct(v, r), 0);
  //     expect(crossProduct(v, r), isNot(0));
  //   });

  //   test('45 degrees', () {
  //     final Position v = Position( 1,  1);
  //     final Position r = perpendicular(v);
  //     expect(dotProduct(v, r), 0);
  //     expect(crossProduct(v, r), isNot(0));
  //   });

  //   test('120 degrees', () {
  //     final Position v = Position( -1,  2);
  //     final Position r = perpendicular(v);
  //     expect(dotProduct(v, r), 0);
  //     expect(crossProduct(v, r), isNot(0));
  //   });
  // });

  // group('closestPoint()', () {
  //   test('on line', () {
  //     final Position pA1 = Position( 2,  2);
  //     final Position pA2 = Position( 3,  3);
  //     final Position pB = Position( -1,  -1);
  //     final Position cp = closestPoint(pA1, pA2, pB);
  //     expect(cp, pB);
  //   });

  //   test('on first point', () {
  //     final Position pA1 = Position( 2,  2);
  //     final Position pA2 = Position( 3,  3);
  //     final Position pB = Position( 2,  2);
  //     final Position cp = closestPoint(pA1, pA2, pB);
  //     expect(cp, pB);
  //   });

  //   test('off line above', () {
  //     final Position pA1 = Position( 2,  2);
  //     final Position pA2 = Position( 3,  1);
  //     final Position pB = Position( 3,  7);
  //     final Position expected = Position( 0,  4);
  //     expect(closestPoint(pA1, pA2, pB), expected);
  //     expect(closestPoint(pA2, pA1, pB), expected);
  //   });

  //   test('off line below', () {
  //     final Position pA1 = Position( 2,  2);
  //     final Position pA2 = Position( 3,  1);
  //     final Position pB = Position( 0,  2);
  //     final Position expected = Position( 1,  3);
  //     expect(closestPoint(pA1, pA2, pB), expected);
  //     expect(closestPoint(pA2, pA1, pB), expected);
  //   });

  //   test('off line perpendicular to first point', () {
  //     final Position pA1 = Position( 2,  2);
  //     final Position pA2 = Position( 3,  3);
  //     final Position pB = Position( 1,  3);
  //     final Position cp = closestPoint(pA1, pA2, pB);
  //     final Position expected = Position( 2,  2);
  //     expect(cp, expected);
  //   });

  //   test('horizontal vector', () {
  //     final Position pA1 = Position( 2,  2);
  //     final Position pA2 = Position( 3,  2);
  //     final Position pB = Position( 1,  3);
  //     final Position cp = closestPoint(pA1, pA2, pB);
  //     final Position expected = Position( 1,  2);
  //     expect(cp, expected);
  //   });

  //   test('vertical vector', () {
  //     final Position pA1 = Position( 2,  2);
  //     final Position pA2 = Position( 2,  3);
  //     final Position pB = Position( 1,  3);
  //     final Position cp = closestPoint(pA1, pA2, pB);
  //     final Position expected = Position( 2,  3);
  //     expect(cp, expected);
  //   });

  //   test('on line but dot product does not think so - part of issue 60-2', () {
  //     final Position pA1 = Position( -45.3269382,  -1.4059341);
  //     final Position pA2 = Position( -45.326737413921656,  -1.40635);
  //     final Position pB = Position( -45.326833968900424,  -1.40615);
  //     final Position cp = closestPoint(pA1, pA2, pB);
  //     expect(cp, pB);
  //   });
  // });

  group('verticalIntersection()', () {
    test('horizontal', () {
      final Position p = Position(42, 3);
      final Position v = Position(-2, 0);
      final double x = 37;
      final Position? i = verticalIntersection(p, v, x);
      expect(i?.lng, 37);
      expect(i?.lat, 3);
    });

    test('vertical', () {
      final Position p = Position(42, 3);
      final Position v = Position(0, 4);
      final double x = 37;
      expect(verticalIntersection(p, v, x), null);
    });

    test('45 degree', () {
      final Position p = Position(1, 1);
      final Position v = Position(1, 1);
      final double x = -2;
      final Position? i = verticalIntersection(p, v, x);
      expect(i?.lng, -2);
      expect(i?.lat, -2);
    });

    test('upper left quadrant', () {
      final Position p = Position(-1, 1);
      final Position v = Position(-2, 1);
      final double x = -3;
      final Position? i = verticalIntersection(p, v, x);
      expect(i?.lng, -3);
      expect(i?.lat, 2);
    });
  });

  group('horizontalIntersection()', () {
    test('horizontal', () {
      final Position p = Position(42, 3);
      final Position v = Position(-2, 0);
      final double y = 37;
      expect(horizontalIntersection(p, v, y), null);
    });

    test('vertical', () {
      final Position p = Position(42, 3);
      final Position v = Position(0, 4);
      final double y = 37;
      final Position? i = horizontalIntersection(p, v, y);
      expect(i?.lng, 42);
      expect(i?.lat, 37);
    });

    test('45 degree', () {
      final Position p = Position(1, 1);
      final Position v = Position(1, 1);
      final double y = 4;
      final Position? i = horizontalIntersection(p, v, y);
      expect(i?.lng, 4);
      expect(i?.lat, 4);
    });

    test('bottom left quadrant', () {
      final Position p = Position(-1, -1);
      final Position v = Position(-2, -1);
      final double y = -3;
      final Position? i = horizontalIntersection(p, v, y);
      expect(i?.lng, -5);
      expect(i?.lat, -3);
    });
  });

  group('intersection()', () {
    final Position p1 = Position(42, 42);
    final Position p2 = Position(-32, 46);

    test('parrallel', () {
      final Position v1 = Position(1, 2);
      final Position v2 = Position(-1, -2);
      final Position? i = intersection(p1, v1, p2, v2);
      expect(i, null);
    });

    test('horizontal and vertical', () {
      final Position v1 = Position(0, 2);
      final Position v2 = Position(-1, 0);
      final Position? i = intersection(p1, v1, p2, v2);
      expect(i?.lng, 42);
      expect(i?.lat, 46);
    });

    test('horizontal', () {
      final Position v1 = Position(1, 1);
      final Position v2 = Position(-1, 0);
      final Position? i = intersection(p1, v1, p2, v2);
      expect(i?.lng, 46);
      expect(i?.lat, 46);
    });

    test('vertical', () {
      final Position v1 = Position(1, 1);
      final Position v2 = Position(0, 1);
      final Position? i = intersection(p1, v1, p2, v2);
      expect(i?.lng, -32);
      expect(i?.lat, -32);
    });

    test('45 degree & 135 degree', () {
      final Position v1 = Position(1, 1);
      final Position v2 = Position(-1, 1);
      final Position? i = intersection(p1, v1, p2, v2);
      expect(i?.lng, 7);
      expect(i?.lat, 7);
    });

    test('consistency', () {
      // Taken from https://github.com/mfogel/polygon-clipping/issues/37
      final Position p1 = Position(0.523787, 51.281453);
      final Position v1 =
          Position(0.0002729999999999677, 0.0002729999999999677);
      final Position p2 = Position(0.523985, 51.281651);
      final Position v2 =
          Position(0.000024999999999941735, 0.000049000000004184585);
      final Position? i1 = intersection(p1, v1, p2, v2);
      final Position? i2 = intersection(p2, v2, p1, v1);
      expect(i1!.lng, i2!.lng);
      expect(i1.lat, i2.lat);
    });
  });
}

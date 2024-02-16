import 'dart:math';

import 'package:turf/src/polygon_clipping/utils.dart';

/* Cross Product of two vectors with first point at origin */
num crossProduct(Point a, Point b) => a.x * b.y - a.y * b.x;

/* Dot Product of two vectors with first point at origin */
num dotProduct(Point a, Point b) => a.x * b.x + a.y * b.y;

/* Comparator for two vectors with same starting point */
num compareVectorAngles(Point basePt, Point endPt1, Point endPt2) {
  double res = orient2d(
    endPt1.x.toDouble(),
    endPt1.y.toDouble(),
    basePt.x.toDouble(),
    basePt.y.toDouble(),
    endPt2.x.toDouble(),
    endPt2.y.toDouble(),
  );
  return res > 0
      ? -1
      : res < 0
          ? 1
          : 0;
}

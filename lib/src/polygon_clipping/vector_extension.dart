import 'dart:math';

import 'package:vector_math/vector_math.dart';

extension Vector2Extension on Vector2 {
  /* Given a vector, return one that is perpendicular */
  Vector2 get perpendicularVector {
    return Vector2(-y, x);
  }
}

/* Get the intersection of two lines, each defined by a base point and a vector.
 * In the case of parrallel lines (including overlapping ones) returns null. */
Point? intersection(Point pt1, Vector2 v1, Point pt2, Vector2 v2) {
  // take some shortcuts for vertical and horizontal lines
  // this also ensures we don't calculate an intersection and then discover
  // it's actually outside the bounding box of the line
  if (v1.x == 0) return verticalIntersection(pt2, v2, pt1.x);
  if (v2.x == 0) return verticalIntersection(pt1, v1, pt2.x);
  if (v1.y == 0) return horizontalIntersection(pt2, v2, pt1.y);
  if (v2.y == 0) return horizontalIntersection(pt1, v1, pt2.y);

  // General case for non-overlapping segments.
  // This algorithm is based on Schneider and Eberly.
  // http://www.cimec.org.ar/~ncalvo/Schneider_Eberly.pdf - pg 244
  final v1CrossV2 = v1.cross(v2);
  if (v1CrossV2 == 0) return null;

  final ve = Vector2((pt2.x - pt1.x).toDouble(), (pt2.y - pt1.y).toDouble());
  final d1 = ve.cross(v1) / v1CrossV2;
  final d2 = ve.cross(v2) / v1CrossV2;

  // take the average of the two calculations to minimize rounding error
  final x1 = pt1.x + d2 * v1.x, x2 = pt2.x + d1 * v2.x;
  final y1 = pt1.y + d2 * v1.y, y2 = pt2.y + d1 * v2.y;
  final x = (x1 + x2) / 2;
  final y = (y1 + y2) / 2;
  return Point(x, y);
}

/* Get the x coordinate where the given line (defined by a point and vector)
 * crosses the horizontal line with the given y coordiante.
 * In the case of parrallel lines (including overlapping ones) returns null. */
Point? horizontalIntersection(Point pt, Vector2 v, num y) {
  if (v.y == 0) return null;
  return Point(pt.x + (v.x / v.y) * (y - pt.y), y);
}

/* Get the y coordinate where the given line (defined by a point and vector)
 * crosses the vertical line with the given x coordiante.
 * In the case of parrallel lines (including overlapping ones) returns null. */
Point? verticalIntersection(Point pt, Vector2 v, num x) {
  if (v.x == 0) return null;
  return Point(x, pt.y + (v.y / v.x) * (x - pt.x));
}

/* Get the sine of the angle from pShared -> pAngle to pShaed -> pBase */
sineOfAngle(Point pShared, Point pBase, Point pAngle) {
  final Vector2 vBase = Vector2(
      (pBase.x - pShared.x).toDouble(), (pBase.y - pShared.y).toDouble());
  final Vector2 vAngle = Vector2(
      (pAngle.x - pShared.x).toDouble(), (pAngle.y - pShared.y).toDouble());
  return vAngle.cross(vBase) / vAngle.length / vBase.length;
}

/* Get the cosine of the angle from pShared -> pAngle to pShaed -> pBase */
cosineOfAngle(Point pShared, Point pBase, Point pAngle) {
  final Vector2 vBase = Vector2(
      (pBase.x - pShared.x).toDouble(), (pBase.y - pShared.y).toDouble());
  final Vector2 vAngle = Vector2(
      (pAngle.x - pShared.x).toDouble(), (pAngle.y - pShared.y).toDouble());
  return vAngle.dot(vBase) / vAngle.length / vBase.length;
}

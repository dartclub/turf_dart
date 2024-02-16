import 'dart:collection';

const double epsilon =
    2.220446049250313e-16; // Equivalent to Number.EPSILON in JavaScript

/// Calculate the orientation of three points (a, b, c) in 2D space.
///
/// Parameters:
///   ax (double): X-coordinate of point a.
///   ay (double): Y-coordinate of point a.
///   bx (double): X-coordinate of point b.
///   by (double): Y-coordinate of point b.
///   cx (double): X-coordinate of point c.
///   cy (double): Y-coordinate of point c.
///
/// Returns:
///   double: The orientation value:
///     - Negative if points a, b, c are in counterclockwise order.
///     - Possitive if points a, b, c are in clockwise order.
///     - Zero if points a, b, c are collinear.
///
/// Note:
///   The orientation of three points is determined by the sign of the cross product
///   (bx - ax) * (cy - ay) - (by - ay) * (cx - ax). This value is twice the signed
///   area of the triangle formed by the points (a, b, c). The sign indicates the
///   direction of the rotation formed by the points.
double orient2d(
    double ax, double ay, double bx, double by, double cx, double cy) {
  return (by - ay) * (cx - bx) - (cy - by) * (bx - ax);
}

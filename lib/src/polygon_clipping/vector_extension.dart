import 'package:turf/helpers.dart';

/* Get the intersection of two lines, each defined by a base point and a vector.
 * In the case of parrallel lines (including overlapping ones) returns null. */
Position? intersection(Position pt1, Position v1, Position pt2, Position v2) {
  // take some shortcuts for vertical and horizontal lines
  // this also ensures we don't calculate an intersection and then discover
  // it's actually outside the bounding box of the line
  if (v1.lng == 0) return verticalIntersection(pt2, v2, pt1.lng);
  if (v2.lng == 0) return verticalIntersection(pt1, v1, pt2.lng);
  if (v1.lat == 0) return horizontalIntersection(pt2, v2, pt1.lat);
  if (v2.lat == 0) return horizontalIntersection(pt1, v1, pt2.lat);

  // General case for non-overlapping segments.
  // This algorithm is based on Schneider and Eberly.
  // http://www.cimec.org.ar/~ncalvo/Schneider_Eberly.pdf - pg 244
  final v1CrossV2 = crossProductMagnitude(v1, v2);
  if (v1CrossV2 == 0) return null;

  final ve =
      Position((pt2.lng - pt1.lng).toDouble(), (pt2.lat - pt1.lat).toDouble());
  final d1 = crossProductMagnitude(ve, v1) / v1CrossV2;
  final d2 = crossProductMagnitude(ve, v2) / v1CrossV2;

  // take the average of the two calculations to minimize rounding error
  final x1 = pt1.lng + d2 * v1.lng, x2 = pt2.lng + d1 * v2.lng;
  final y1 = pt1.lat + d2 * v1.lat, y2 = pt2.lat + d1 * v2.lat;
  final lng = (x1 + x2) / 2;
  final lat = (y1 + y2) / 2;
  return Position(lng, lat);
}

/* Get the lng coordinate where the given line (defined by a point and vector)
 * crosses the horizontal line with the given lat coordiante.
 * In the case of parrallel lines (including overlapping ones) returns null. */
Position? horizontalIntersection(Position pt, Position v, num lat) {
  if (v.lat == 0) return null;
  return Position(pt.lng + (v.lng / v.lat) * (lat - pt.lat), lat);
}

/* Get the lat coordinate where the given line (defined by a point and vector)
 * crosses the vertical line with the given lng coordiante.
 * In the case of parrallel lines (including overlapping ones) returns null. */
Position? verticalIntersection(Position pt, Position v, num lng) {
  if (v.lng == 0) return null;
  return Position(lng, pt.lat + (v.lat / v.lng) * (lng - pt.lng));
}

/* Get the sine of the angle from pShared -> pAngle to pShaed -> pBase */
num sineOfAngle(Position pShared, Position pBase, Position pAngle) {
  final Position vBase = Position((pBase.lng - pShared.lng).toDouble(),
      (pBase.lat - pShared.lat).toDouble());
  final Position vAngle = Position((pAngle.lng - pShared.lng).toDouble(),
      (pAngle.lat - pShared.lat).toDouble());
  return crossProductMagnitude(vAngle, vBase) / vAngle.length / vBase.length;
}

/* Get the cosine of the angle from pShared -> pAngle to pShaed -> pBase */
num cosineOfAngle(Position pShared, Position pBase, Position pAngle) {
  final Position vBase = Position((pBase.lng - pShared.lng).toDouble(),
      (pBase.lat - pShared.lat).toDouble());
  final Position vAngle = Position((pAngle.lng - pShared.lng).toDouble(),
      (pAngle.lat - pShared.lat).toDouble());
  return dotProductMagnitude(vAngle, vBase) / vAngle.length / vBase.length;
}

/* Cross Product of two vectors with first point at origin */
num crossProductMagnitude(Position a, Position b) =>
    a.lng * b.lat - a.lat * b.lng;

/* Dot Product of two vectors with first point at origin */
num dotProductMagnitude(Position a, Position b) =>
    a.lng * b.lng + a.lat * b.lat;

/* Comparator for two vectors with same starting point */
num compareVectorAngles(Position basePt, Position endPt1, Position endPt2) {
  double res = orient2d(
    endPt1.lng.toDouble(),
    endPt1.lat.toDouble(),
    basePt.lng.toDouble(),
    basePt.lat.toDouble(),
    endPt2.lng.toDouble(),
    endPt2.lat.toDouble(),
  );
  return res > 0
      ? -1
      : res < 0
          ? 1
          : 0;
}

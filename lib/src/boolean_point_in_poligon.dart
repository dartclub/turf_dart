import '../helpers.dart';
import '../invariant.dart';

bool booleanPointInPolygon(dynamic point, dynamic polygon,
    {bool ignoreBoundary = false}) {
  if (point is! Feature<Point> && point is! Point && point is! Position) {
    throw Exception('point must be Feature<Point> | Point | Position');
  }
  if (polygon is! Feature<Polygon> &&
      polygon is! Feature<MultiPolygon> &&
      polygon is! Polygon &&
      polygon is! MultiPolygon) {
    throw Exception(
        'polygon must be Feature<Polygon | MultiPolygon> | Polygon | MultiPolygon');
  }

  final pt = getCoord(point);
  final geom = getGeom(polygon);
  final type = geom?.type;
  final bbox = polygon.bbox;
  List polys = geom?.coordinates ?? [];

  // Quick elimination if point is not inside bbox
  if (bbox != null && !inBBox(pt, bbox)) {
    return false;
  }
  // normalize to multipolygon
  if (type == 'Polygon') {
    polys = [
      (polys as List<List<Position>>)
          .map((e) =>
              e.map((e2) => e2.toList().whereType<num>().toList()).toList())
          .toList()
    ];
  }
  if (polys is List<List<List<Position>>>) {
    polys = polys
        .map((i) => i
            .map((e) =>
                e.map((e2) => e2.toList().whereType<num>().toList()).toList())
            .toList())
        .toList();
  }

  var insidePoly = false;
  for (var i = 0; i < polys.length && !insidePoly; i++) {
    // check if it is in the outer ring first
    if (inRing(pt, polys[i][0], ignoreBoundary)) {
      var inHole = false;
      var k = 1;
      // check for the point in any of the holes
      while (k < polys[i].length && !inHole) {
        if (inRing(pt, polys[i][k], !ignoreBoundary)) {
          inHole = true;
        }
        k++;
      }
      if (!inHole) {
        insidePoly = true;
      }
    }
  }
  return insidePoly;
}

bool inRing(
  List<num> pt,
  List<List<num>> ring, [
  bool ignoreBoundary = false,
]) {
  var isInside = false;
  if (ring[0][0] == ring[ring.length - 1][0] &&
      ring[0][1] == ring[ring.length - 1][1]) {
    ring.removeLast();
  }
  for (var i = 0, j = ring.length - 1; i < ring.length; j = i++) {
    final xi = ring[i][0];
    final yi = ring[i][1];
    final xj = ring[j][0];
    final yj = ring[j][1];
    final onBoundary =
        pt[1] * (xi - xj) + yi * (xj - pt[0]) + yj * (pt[0] - xi) == 0 &&
            (xi - pt[0]) * (xj - pt[0]) <= 0 &&
            (yi - pt[1]) * (yj - pt[1]) <= 0;
    if (onBoundary) {
      return !ignoreBoundary;
    }
    final intersect = yi > pt[1] != yj > pt[1] &&
        pt[0] < ((xj - xi) * (pt[1] - yi)) / (yj - yi) + xi;
    if (intersect) {
      isInside = !isInside;
    }
  }
  return isInside;
}

bool inBBox(List<num?> pt, BBox bbox) {
  return (bbox.lng1 ?? 0) <= (pt[0] ?? 0) &&
      (bbox.lat1 ?? 0) <= (pt[1] ?? 0) &&
      (bbox.alt1 ?? 0) >= (pt[0] ?? 0) &&
      (bbox.lng2 ?? 0) >= (pt[1] ?? 0);
}

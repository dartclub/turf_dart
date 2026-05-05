import 'package:geotypes/geotypes.dart';
import 'package:turf/bbox.dart';

// Bit code reflects the position relative to the bounding box
int bitCode(Position p, BBox bbox) {
  int code = 0;

  if (p.lng < bbox.lng1) {
    code |= 1; // left
  } else if (p.lng > bbox.lng2) {
    code |= 2; // right
  }

  if (p.lat < bbox.lat1) {
    code |= 4; // bottom
  } else if (p.lat > bbox.lat2) {
    code |= 8; // top
  }

  return code;
}

// Intersection of a segment against one of the bbox edges
Position intersect(Position a, Position b, int edge, BBox bbox) {
  if ((edge & 8) != 0) {
    // top
    final double lng =
        a.lng + (b.lng - a.lng) * (bbox.lat2 - a.lat) / (b.lat - a.lat);
    return Position.named(lat: bbox.lat2, lng: lng);
  } else if ((edge & 4) != 0) {
    // bottom
    final double lng =
        a.lng + (b.lng - a.lng) * (bbox.lat1 - a.lat) / (b.lat - a.lat);
    return Position.named(lat: bbox.lat1, lng: lng);
  } else if ((edge & 2) != 0) {
    // right
    final double lat =
        a.lat + (b.lat - a.lat) * (bbox.lng2 - a.lng) / (b.lng - a.lng);
    return Position.named(lat: lat, lng: bbox.lng2);
  } else if ((edge & 1) != 0) {
    // left
    final double lat =
        a.lat + (b.lat - a.lat) * (bbox.lng1 - a.lng) / (b.lng - a.lng);
    return Position.named(lat: lat, lng: bbox.lng1);
  }

  throw Exception("No intersection found");
}

// Cohen-Sutherland line clipping for polylines
List<List<Position>> lineclip(
  List<Position> points,
  BBox bbox, [
  List<List<Position>>? result,
]) {
  final int len = points.length;
  int codeA = bitCode(points[0], bbox);
  List<Position> part = [];
  result ??= [];

  for (int i = 1; i < len; i++) {
    Position a = points[i - 1];
    Position b = points[i];
    int codeB = bitCode(b, bbox);
    final int lastCode = codeB;

    while (true) {
      if ((codeA | codeB) == 0) {
        part.add(a);
        if (codeB != lastCode) {
          part.add(b);
          if (i < len - 1) {
            result.add(List<Position>.from(part));
            part = [];
          }
        } else if (i == len - 1) {
          part.add(b);
        }
        break;
      } else if ((codeA & codeB) != 0) {
        break;
      } else if (codeA != 0) {
        a = intersect(a, b, codeA, bbox);
        codeA = bitCode(a, bbox);
      } else {
        b = intersect(a, b, codeB, bbox);
        codeB = bitCode(b, bbox);
      }
    }
    codeA = lastCode;
  }

  if (part.isNotEmpty) result.add(List<Position>.from(part));
  return result;
}

// Sutherland-Hodgman polygon clipping
List<Position> polygonclip(List<Position> points, BBox bbox) {
  List<Position> result = [];
  int edge;
  Position prev;
  bool prevInside;
  int i;
  Position p;
  bool inside;

  // First check if all points are outside the bounding box
  final bool allOutside = points.every((p) {
    return (bitCode(p, bbox) !=
        0); // If bitCode is non-zero, the point is outside
  });

  if (allOutside) {
    // If all points are outside, return an empty list
    return [];
  }

  // Otherwise, proceed with the normal clipping
  for (edge = 1; edge <= 8; edge *= 2) {
    result = [];
    prev = points[points.length - 1];
    prevInside = (bitCode(prev, bbox) & edge) == 0;

    for (i = 0; i < points.length; i++) {
      p = points[i];
      inside = (bitCode(p, bbox) & edge) == 0;

      if (inside != prevInside) {
        result.add(intersect(prev, p, edge, bbox));
      }
      if (inside) result.add(p);

      prev = p;
      prevInside = inside;
    }

    points = List<Position>.from(result);

    if (points.isEmpty) break;
  }

  return result;
}

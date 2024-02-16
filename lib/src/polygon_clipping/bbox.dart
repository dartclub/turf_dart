import 'dart:math';

class BoundingBox {
  Point ll; // Lower left point
  Point ur; // Upper right point

  BoundingBox(this.ll, this.ur);
}

bool isInBbox(BoundingBox bbox, Point point) {
  return (bbox.ll.x <= point.x &&
      point.x <= bbox.ur.x &&
      bbox.ll.y <= point.y &&
      point.y <= bbox.ur.y);
}

BoundingBox? getBboxOverlap(BoundingBox b1, BoundingBox b2) {
  // Check if the bboxes overlap at all
  if (b2.ur.x < b1.ll.x ||
      b1.ur.x < b2.ll.x ||
      b2.ur.y < b1.ll.y ||
      b1.ur.y < b2.ll.y) {
    return null;
  }

  // Find the middle two X values
  final lowerX = b1.ll.x < b2.ll.x ? b2.ll.x : b1.ll.x;
  final upperX = b1.ur.x < b2.ur.x ? b1.ur.x : b2.ur.x;

  // Find the middle two Y values
  final lowerY = b1.ll.y < b2.ll.y ? b2.ll.y : b1.ll.y;
  final upperY = b1.ur.y < b2.ur.y ? b1.ur.y : b2.ur.y;

  // Create a new bounding box with the overlap
  return BoundingBox(Point(lowerX, lowerY), Point(upperX, upperY));
}

import 'dart:math';

import 'package:turf/turf.dart';

// Returns a random Position within a Bbox
// Dart Random function module is obtained from dart:math

Position randomPosition(BBox? bbox) {
  checkBBox(bbox);
  return randomPositionUnchecked(bbox);
}

// Returns a Random Position without checking if it is valid
Position randomPositionUnchecked(BBox? bbox) {
  return coordInBBox(bbox);
}

// Performs checks on bbox ensuring a bbox is provided, and contains 4 values.
void checkBBox(BBox? bbox) {
  if (bbox == null) {
    throw ArgumentError("Bbox cannot be null.");
  }
  if (bbox.length != 4) {
    throw ArgumentError("Bbox must contain exactly 4 values.");
  }
}

// Returns a random Position within bbox
Position coordInBBox(BBox? bbox) {
  if (bbox == null) {
    throw ArgumentError("Bbox cannot be null.");
  }
  return Position(bbox[0]! + Random().nextDouble() * (bbox[2]! - bbox[0]!),
      bbox[1]! + Random().nextDouble() * (bbox[3]! - bbox[1]!));
}

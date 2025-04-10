import 'package:turf/distance.dart';
import 'package:turf/turf.dart';

/// Takes a [BBox] and returns a square [BBox] of equal dimensions.
BBox square(BBox bbox) {
  final horizontalDistance = distance(
    Point(coordinates: Position.named(lng: bbox.lng1, lat: bbox.lat1)),
    Point(coordinates: Position.named(lng: bbox.lng2, lat: bbox.lat1))
  );
  final verticalDistance = distance(
    Point(coordinates: Position.named(lng: bbox.lng1, lat: bbox.lat1)),
    Point(coordinates: Position.named(lng: bbox.lng1, lat: bbox.lat2))
  );

  if (horizontalDistance >= verticalDistance) {
    final verticalMidpoint = (bbox.lat1 + bbox.lat2) / 2;
    return BBox.named(
      lng1: bbox.lng1,
      lat1: verticalMidpoint - (bbox.lng2 - bbox.lng1) / 2,
      lng2: bbox.lng2,
      lat2: verticalMidpoint + (bbox.lng2 - bbox.lng1) / 2,
    );
  } else {
    final horizontalMidpoint = (bbox.lng1 + bbox.lng2) / 2;
    return BBox.named(
      lng1: horizontalMidpoint - (bbox.lat2 - bbox.lat1) / 2,
      lat1: bbox.lat1,
      lng2: horizontalMidpoint + (bbox.lat2 - bbox.lat1) / 2,
      lat2: bbox.lat2,
    );
  }
}
import 'package:turf/helpers.dart';
import 'package:turf/src/geojson.dart';

bool isInBbox(BBox bbox, Position point) {
  return (bbox.position1.lng <= point.lng &&
      point.lng <= bbox.position2.lng &&
      bbox.position1.lat <= point.lat &&
      point.lat <= bbox.position2.lat);
}

BBox? getBboxOverlap(BBox b1, BBox b2) {
  // Check if the bboxes overlap at all
  if (b2.position2.lng < b1.position1.lng ||
      b1.position2.lng < b2.position1.lng ||
      b2.position2.lat < b1.position1.lat ||
      b1.position2.lat < b2.position1.lat) {
    return null;
  }

  // Find the middle two lng values
  final num lowerX =
      b1.position1.lng < b2.position1.lng ? b2.position1.lng : b1.position1.lng;
  final num upperX =
      b1.position2.lng < b2.position2.lng ? b1.position2.lng : b2.position2.lng;

  // Find the middle two lat values
  final num lowerY =
      b1.position1.lat < b2.position1.lat ? b2.position1.lat : b1.position1.lat;
  final num upperY =
      b1.position2.lat < b2.position2.lat ? b1.position2.lat : b2.position2.lat;

  // Create a new bounding box with the overlap
  return BBox.fromPositions(Position(lowerX, lowerY), Position(upperX, upperY));
}

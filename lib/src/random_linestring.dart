import 'dart:math';
import 'package:turf/turf.dart';

// Takes an optional bbox and a mandatory integer to generate x number of linestrings. Other optional parameters: numVertices, maxLength, maxRotation
// Returns a random linestring

FeatureCollection<LineString> randomLineString(int? count,
    {BBox? bbox, int? numVertices, double? maxLength, double? maxRotation}) {
  numVertices ??= 10;
  maxLength ??= 0.0001;
  maxRotation ??= pi / 8;

  // Ensure count is +ve value
  if (count == null || count <= 0) {
    throw ArgumentError(
        'Count must be set to a positive integer to return a LineString.');
  }

  // Returns a random position within Bbox if provided
  Position coordInBBox(BBox? bbox) {
    return Position(bbox![0]! + Random().nextDouble() * (bbox[2]! - bbox[0]!),
        bbox[1]! + Random().nextDouble() * (bbox[3]! - bbox[1]!));
  }

  // Returns a random position within bbox if provided, else returns a random Position on the globe
  Position randomPositionUnchecked(BBox? bbox) {
    if (bbox != null) {
      return coordInBBox(bbox);
    }
    return Position(
        Random().nextDouble() * 360 - 180, Random().nextDouble() * 180 - 90);
  }

  // Generate list for all features, and loops through to generate all linestrings
  List<Feature<LineString>> features = [];

  for (int i = 0; i < count; i++) {
    Position startingPos = randomPositionUnchecked(bbox);

    List<Position> vertices = [startingPos];

    for (int j = 0; j < numVertices - 1; j++) {
      double priorAngle = j == 0
          ? Random().nextDouble() * 2 * pi
          : atan2(
              vertices[j][1]! - vertices[j - 1][1]!,
              vertices[j][0]! - vertices[j - 1][0]!,
            );

      double angle =
          priorAngle + (Random().nextDouble() - 0.5) * maxRotation * 2;
      double distance = Random().nextDouble() * maxLength;

      vertices.add(Position(
        vertices[j][0]! + distance * cos(angle),
        vertices[j][1]! + distance * sin(angle),
      ));
    }

    features.add(Feature(geometry: LineString(coordinates: vertices)));
  }
  //Finally return FeatureCollection
  return FeatureCollection(features: features);
}

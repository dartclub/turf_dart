import 'dart:math';
import 'package:test/test.dart';
import 'package:turf/turf.dart';

void main() {
  test('sample picks the requested number of features', () {
    final points = FeatureCollection<Point>(features: [
      Feature<Point>(
          geometry: Point(coordinates: Position(1, 2)),
          properties: {'team': 'Red Sox'}),
      Feature<Point>(
          geometry: Point(coordinates: Position(2, 1)),
          properties: {'team': 'Yankees'}),
      Feature<Point>(
          geometry: Point(coordinates: Position(3, 1)),
          properties: {'team': 'Nationals'}),
      Feature<Point>(
          geometry: Point(coordinates: Position(2, 2)),
          properties: {'team': 'Yankees'}),
      Feature<Point>(
          geometry: Point(coordinates: Position(2, 3)),
          properties: {'team': 'Red Sox'}),
      Feature<Point>(
          geometry: Point(coordinates: Position(4, 2)),
          properties: {'team': 'Yankees'}),
    ]);

    // Pass a seeded RNG so the test is reproducible.
    final results = sample<Point>(points, 4, random: Random(42));

    expect(results.features.length, equals(4),
        reason: 'should sample exactly 4 features');
  });
}

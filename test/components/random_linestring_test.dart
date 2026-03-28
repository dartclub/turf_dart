import 'package:test/test.dart';
import 'package:turf/random_linestring.dart';
import 'dart:math';

void main() {
  group('Random linestring tests', () {
    test('Returning a valid feature collection', () {
      FeatureCollection<LineString> featureCollection = randomLineString(3);

      expect(featureCollection, isA<FeatureCollection<LineString>>());
      expect(
          featureCollection.features
              .every((line) => line.geometry is LineString),
          isTrue);
    });

    test('Checking bbox boundaries', () {
      BBox? bbox = BBox(100.0, -24.0, 110.0, -23.0);

      FeatureCollection<LineString> lineString =
          randomLineString(1, bbox: bbox);

      lineString.features.first.geometry?.coordinates.forEach((coord) {
        expect(coord[0], greaterThanOrEqualTo(bbox[0]!));
        expect(coord[0], lessThanOrEqualTo(bbox[2]!));
        expect(coord[1], greaterThanOrEqualTo(bbox[1]!));
        expect(coord[1], lessThanOrEqualTo(bbox[3]!));
      });
    });

    test('Testing Linestrings have vertexes = numVertices', () {
      int vertices = 15;
      FeatureCollection<LineString> lineString =
          randomLineString(1, numVertices: vertices);

      expect(lineString.features.first.geometry?.coordinates.length,
          equals(vertices));
    });

    test('Testing maxLength and maxRotation constraints', () {
      double maxLength = 0.001;
      FeatureCollection<LineString> featureCollection =
          randomLineString(5, maxLength: maxLength);

      featureCollection.features.forEach((feature) {
        final coords = feature.geometry?.coordinates;
        for (int i = 1; i < coords!.length; i++) {
          final dx = coords[i][0]! - coords[i - 1][0]!;
          final dy = coords[i][1]! - coords[i - 1][1]!;
          final distance = sqrt(dx * dx + dy * dy);

          expect(distance, lessThanOrEqualTo(maxLength));
        }
      });
    });
  });
}

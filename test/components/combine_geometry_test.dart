import 'package:geotypes/geotypes.dart';
import 'package:test/test.dart';
import 'package:turf/src/combine.dart';

void main() {
  group('combine: geometry transformations:', () {
    test('combines multiple points to a MultiPoint', () {
      final point1 = Feature(
        geometry: Point(coordinates: Position.of([0, 0])),
        properties: {'name': 'point1'},
      );
      final point2 = Feature(
        geometry: Point(coordinates: Position.of([1, 1])),
        properties: {'name': 'point2'},
      );
      final point3 = Feature(
        geometry: Point(coordinates: Position.of([2, 2, 10])), // With altitude
        properties: {'name': 'point3'},
      );

      final collection = FeatureCollection(features: [point1, point2, point3]);
      final result = combine(collection);

      expect(result.features.length, 1);
      expect(result.features.first.geometry, isA<MultiPoint>());
      final mp = result.features.first.geometry as MultiPoint;
      expect(mp.coordinates.length, 3);
      expect(mp.coordinates[2].length, 3);
      expect(mp.coordinates[2][2], 10);
    });

    test('combines multiple linestrings to a MultiLineString', () {
      final line1 = Feature(
        geometry: LineString(coordinates: [
          Position.of([0, 0]),
          Position.of([1, 1]),
        ]),
        properties: {'name': 'line1'},
      );
      final line2 = Feature(
        geometry: LineString(coordinates: [
          Position.of([2, 2]),
          Position.of([3, 3]),
        ]),
        properties: {'name': 'line2'},
      );
      final line3 = Feature(
        geometry: LineString(coordinates: [
          Position.of([4, 4, 10]), // With altitude
          Position.of([5, 5, 15]), // With altitude
        ]),
        properties: {'name': 'line3'},
      );

      final collection = FeatureCollection(features: [line1, line2, line3]);
      final result = combine(collection);

      expect(result.features.length, 1);
      expect(result.features.first.geometry, isA<MultiLineString>());
      final mls = result.features.first.geometry as MultiLineString;
      expect(mls.coordinates.length, 3);
      expect(mls.coordinates[2][0].length, 3);
      expect(mls.coordinates[2][0][2], 10);
      expect(mls.coordinates[2][1][2], 15);
    });

    test('combines multiple polygons to a MultiPolygon', () {
      final poly1 = Feature(
        geometry: Polygon(coordinates: [
          [
            Position.of([0, 0]),
            Position.of([1, 0]),
            Position.of([1, 1]),
            Position.of([0, 1]),
            Position.of([0, 0]),
          ]
        ]),
        properties: {'name': 'poly1'},
      );
      final poly2 = Feature(
        geometry: Polygon(coordinates: [
          [
            Position.of([2, 2]),
            Position.of([3, 2]),
            Position.of([3, 3]),
            Position.of([2, 3]),
            Position.of([2, 2]),
          ]
        ]),
        properties: {'name': 'poly2'},
      );
      final poly3 = Feature(
        geometry: Polygon(coordinates: [
          [
            Position.of([4, 4, 10]), // With altitude
            Position.of([5, 4, 10]),
            Position.of([5, 5, 10]),
            Position.of([4, 5, 10]),
            Position.of([4, 4, 10]),
          ]
        ]),
        properties: {'name': 'poly3'},
      );

      final collection = FeatureCollection(features: [poly1, poly2, poly3]);
      final result = combine(collection);

      expect(result.features.length, 1);
      expect(result.features.first.geometry, isA<MultiPolygon>());
      final mpoly = result.features.first.geometry as MultiPolygon;
      expect(mpoly.coordinates.length, 3);
      expect(mpoly.coordinates[2][0][0].length, 3);
      expect(mpoly.coordinates[2][0][0][2], 10);
    });

    test('preserves negative or high-altitude z-values', () {
      final point1 = Feature(
        geometry: Point(coordinates: Position.of([0, 0, -9999.5])),
        properties: {'name': 'deep_point'},
      );
      final point2 = Feature(
        geometry: Point(coordinates: Position.of([1, 1, 9999.5])),
        properties: {'name': 'high_point'},
      );

      final collection = FeatureCollection(features: [point1, point2]);
      final result = combine(collection);

      expect(result.features.length, 1);
      final mp = result.features.first.geometry as MultiPoint;
      expect(mp.coordinates.length, 2);
      expect(mp.coordinates[0].length, 3);
      expect(mp.coordinates[0][2], -9999.5);
      expect(mp.coordinates[1].length, 3);
      expect(mp.coordinates[1][2], 9999.5);
    });
  });
}

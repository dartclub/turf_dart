import 'package:test/test.dart';
import 'package:turf/flip.dart';

void main() {
  group('flip tests', () {

    test('flipping individual coordinates - point', () {
      // Original point
      var point = Feature(
        geometry: Point(
          coordinates: Position.named(lat: -75, lng: 39),
        ),
      );

      var flipped = flip(point);

      expect(flipped.geometry?.coordinates.lat, equals(39));
      expect(flipped.geometry?.coordinates.lng, equals(-75));
    });

    test('flipping a group of coordinates - polygon', () {
      // Original polygon
      var polygon = Feature(
        geometry: Polygon(
          coordinates: [
            [
              Position.named(lat: -75, lng: 39),
              Position.named(lat: -75, lng: 38),
              Position.named(lat: -74, lng: 38),
              Position.named(lat: -74, lng: 39),
              Position.named(lat: -75, lng: 39),
            ]
          ],
        ),
      );

      // Expected flipped polygon
      var expPolygon = [
        [
          Position.named(lat: 39, lng: -75),
          Position.named(lat: 38, lng: -75),
          Position.named(lat: 38, lng: -74),
          Position.named(lat: 39, lng: -74),
          Position.named(lat: 39, lng: -75),
        ]
      ];

      var flipped = flip(polygon);

      // Compare ring by ring
      for (int i = 0; i < expPolygon[0].length; i++) {
        expect(flipped.geometry?.coordinates[0][i].lat, equals(expPolygon[0][i].lat));
        expect(flipped.geometry?.coordinates[0][i].lng, equals(expPolygon[0][i].lng));
      }
    });

  });
}
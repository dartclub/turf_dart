import 'package:test/test.dart';
import 'package:turf/flip.dart';

void main() {
  group('flip tests', () {
    test('flipping individual coordinates - point', () {
      var point = Feature(
        geometry: Point(
          coordinates: Position.named(lat: -75, lng: 39)
        ),
      );

      expect(flip(point).geometry?.coordinates, equals(Position(39,-75)));
    });

    test('flipping a group of coordinates - polygon', () {
      var polygon = Feature(
        geometry: Polygon(
          coordinates: [
            [
            Position.named(lat: -75, lng: 39),
            Position.named(lat: -75, lng: 38),
            Position.named(lat: -74, lng: 38),
            Position.named(lat: -74, lng: 39),
            Position.named(lat: -75, lng: 39),
            ],
          ], 
        ),
      );
      
      var expPolygon = [
        [
          Position(39,-75),
          Position(38, -75),
          Position(38, -74),
          Position(39, -74),
          Position(39, -75)
        ]
      ];
      expect(flip(polygon).geometry?.coordinates, equals(expPolygon));

    });
  });
}
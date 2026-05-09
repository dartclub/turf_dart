import 'package:test/test.dart';
import 'package:turf/flip.dart';

void main() {
  group('flip tests', () {
    test('flipping individual coordinates - point', () {
      // Original point
      final point = Feature(
        geometry: Point(
          coordinates: Position.named(lat: -75, lng: 39),
        ),
      );

      final flipped = flip(point);

      expect(flipped.geometry?.coordinates.lat, equals(39));
      expect(flipped.geometry?.coordinates.lng, equals(-75));
    });

    test('flipping coordinates - multipoint', () {
      final multiPoint = Feature(
        geometry: MultiPoint(coordinates: [
          Position.named(lat: -75, lng: 39),
          Position.named(lat: -74, lng: 38),
        ]),
      );

      final flipped = flip(multiPoint);

      expect(flipped.geometry?.coordinates[0].lat, equals(39));
      expect(flipped.geometry?.coordinates[0].lng, equals(-75));

      expect(flipped.geometry?.coordinates[1].lat, equals(38));
      expect(flipped.geometry?.coordinates[1].lng, equals(-74));
    });

    test('flipping coordinates - linestring', () {
      final line = Feature(
        geometry: LineString(coordinates: [
          Position.named(lat: -75, lng: 39),
          Position.named(lat: -74, lng: 38),
        ]),
      );

      final flipped = flip(line);

      expect(flipped.geometry?.coordinates[0].lat, equals(39));
      expect(flipped.geometry?.coordinates[0].lng, equals(-75));
    });

    test('flipping coordinates - multilinestring', () {
      final multiLine = Feature(
        geometry: MultiLineString(coordinates: [
          [
            Position.named(lat: -75, lng: 39),
            Position.named(lat: -74, lng: 38),
          ],
          [
            Position.named(lat: -73, lng: 37),
            Position.named(lat: -72, lng: 36),
          ],
        ]),
      );

      final flipped = flip(multiLine);

      expect(flipped.geometry?.coordinates[0][0].lat, equals(39));
      expect(flipped.geometry?.coordinates[0][0].lng, equals(-75));

      expect(flipped.geometry?.coordinates[0][1].lat, equals(38));
      expect(flipped.geometry?.coordinates[0][1].lng, equals(-74));

      expect(flipped.geometry?.coordinates[1][0].lat, equals(37));
      expect(flipped.geometry?.coordinates[1][0].lng, equals(-73));

      expect(flipped.geometry?.coordinates[1][1].lat, equals(36));
      expect(flipped.geometry?.coordinates[1][1].lng, equals(-72));
    });

    test('flipping a group of coordinates - polygon', () {
      // Original polygon
      final polygon = Feature(
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
      final expPolygon = [
        [
          Position.named(lat: 39, lng: -75),
          Position.named(lat: 38, lng: -75),
          Position.named(lat: 38, lng: -74),
          Position.named(lat: 39, lng: -74),
          Position.named(lat: 39, lng: -75),
        ]
      ];

      final flipped = flip(polygon);

      // Compare ring by ring
      for (int i = 0; i < expPolygon[0].length; i++) {
        expect(flipped.geometry?.coordinates[0][i].lat,
            equals(expPolygon[0][i].lat));
        expect(flipped.geometry?.coordinates[0][i].lng,
            equals(expPolygon[0][i].lng));
      }
    });

    test('flipping coordinates - multipolygon', () {
      final multiPolygon = Feature(
        geometry: MultiPolygon(coordinates: [
          // First polygon
          [
            [
              Position.named(lat: -75, lng: 39),
              Position.named(lat: -75, lng: 38),
              Position.named(lat: -74, lng: 38),
              Position.named(lat: -74, lng: 39),
              Position.named(lat: -75, lng: 39),
            ]
          ],
          // Second polygon
          [
            [
              Position.named(lat: -73, lng: 37),
              Position.named(lat: -73, lng: 36),
              Position.named(lat: -72, lng: 36),
              Position.named(lat: -72, lng: 37),
              Position.named(lat: -73, lng: 37),
            ]
          ]
        ]),
      );

      final flipped = flip(multiPolygon);

      // First polygon, first ring
      expect(flipped.geometry?.coordinates[0][0][0].lat, equals(39));
      expect(flipped.geometry?.coordinates[0][0][0].lng, equals(-75));
      expect(flipped.geometry?.coordinates[0][0][1].lat, equals(38));
      expect(flipped.geometry?.coordinates[0][0][1].lng, equals(-75));

      // Second polygon, first ring
      expect(flipped.geometry?.coordinates[1][0][0].lat, equals(37));
      expect(flipped.geometry?.coordinates[1][0][0].lng, equals(-73));
      expect(flipped.geometry?.coordinates[1][0][1].lat, equals(36));
      expect(flipped.geometry?.coordinates[1][0][1].lng, equals(-73));
    });

    test('flipping coordinates - point with decimal and negative', () {
      final point = Feature(
        geometry: Point(
          coordinates: Position.named(lat: -23.456, lng: 45.678),
        ),
      );

      final flipped = flip(point);

      expect(flipped.geometry?.coordinates.lat, equals(45.678));
      expect(flipped.geometry?.coordinates.lng, equals(-23.456));
    });

    test('empty geometries should remain empty', () {
      final emptyLine = Feature(geometry: LineString(coordinates: []));
      final flipped = flip(emptyLine);
      expect(flipped.geometry?.coordinates, equals([]));
    });
  });
}

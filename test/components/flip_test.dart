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

    test('flipping coordinates - multipoint', () {
      var multiPoint = Feature(
        geometry: MultiPoint(coordinates: [
          Position.named(lat: -75, lng: 39),
          Position.named(lat: -74, lng: 38),
        ]),
      );

      var flipped = flip(multiPoint);

      expect(flipped.geometry?.coordinates[0].lat, equals(39));
      expect(flipped.geometry?.coordinates[0].lng, equals(-75));

      expect(flipped.geometry?.coordinates[1].lat, equals(38));
      expect(flipped.geometry?.coordinates[1].lng, equals(-74));
    });

    test('flipping coordinates - linestring', () {
      var line = Feature(
        geometry: LineString(coordinates: [
          Position.named(lat: -75, lng: 39),
          Position.named(lat: -74, lng: 38),
        ]),
      );

      var flipped = flip(line);

      expect(flipped.geometry?.coordinates[0].lat, equals(39));
      expect(flipped.geometry?.coordinates[0].lng, equals(-75));
    });

    test('flipping coordinates - multilinestring', () {
      var multiLine = Feature(
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

      var flipped = flip(multiLine);

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

    test('flipping coordinates - multipolygon', () {
      var multiPolygon = Feature(
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

      var flipped = flip(multiPolygon);

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
      var point = Feature(
        geometry: Point(
          coordinates: Position.named(lat: -23.456, lng: 45.678),
        ),
      );

      var flipped = flip(point);

      expect(flipped.geometry?.coordinates.lat, equals(45.678));
      expect(flipped.geometry?.coordinates.lng, equals(-23.456));
    });

    test('empty geometries should remain empty', () {
      var emptyLine = Feature(geometry: LineString(coordinates: []));
      var flipped = flip(emptyLine);
      expect(flipped.geometry?.coordinates, equals([]));
    });

  });
}
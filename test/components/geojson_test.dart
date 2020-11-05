import 'dart:math';

import 'package:test/test.dart';
import 'package:turf/distance.dart';
import 'package:turf/helpers.dart';

main() {
  group('GeoJSON Objects', () {
    test('Position', () {
      _expectArgs(Position pos) {
        expect(pos.lng, 1);
        expect(pos.lat, 2);
        expect(pos.alt, 3);
        expect(pos[0], 1);
        expect(pos[1], 2);
        expect(pos[2], 3);
        expect(pos.length, 3);
        expect(pos.toJson(), [1, 2, 3]);
      }

      var pos1 = Position.named(lng: 1, lat: 2, alt: 3);
      var pos2 = Position.of([1, 2, 3]);
      _expectArgs(pos1);
      _expectArgs(pos2);
    });
    test('Position deserialization', () {
      expect(Position.of([1]).toList(), [1, 0, 0]);
      expect(Position.of([1, 2]).toList(), [1, 2, 0]);
      expect(Position.of([1, 2, 3]).toList(), [1, 2, 3]);
    });
    test('BBox', () {
      _expectArgs(BBox bbox) {
        expect(bbox.lng1, 1);
        expect(bbox.lat1, 2);
        expect(bbox.alt1, 3);
        expect(bbox.lng2, 4);
        expect(bbox.lat2, 5);
        expect(bbox.alt2, 6);
        expect(bbox[0], 1);
        expect(bbox[1], 2);
        expect(bbox[2], 3);
        expect(bbox[3], 4);
        expect(bbox[4], 5);
        expect(bbox[5], 6);
        expect(bbox.length, 6);
        expect(bbox.toJson(), [1, 2, 3, 4, 5, 6]);
      }

      var bbox1 =
          BBox.named(lng1: 1, lat1: 2, alt1: 3, lng2: 4, lat2: 5, alt2: 6);
      var bbox2 = BBox.of([1, 2, 3, 4, 5, 6]);
      _expectArgs(bbox1);
      _expectArgs(bbox2);
    });
  });
  group('Longitude normalization', () {
    var rand = Random();
    _rand() => rand.nextDouble() * (360 * 2) - 360;
    test('Position.toSigned', () {
      for (var i = 0; i < 10; i++) {
        var coord = Position.named(lat: _rand(), lng: _rand(), alt: 0);
        var zeroZero = Position(0, 0);
        var distToCoord = distanceRaw(zeroZero, coord);
        var distToNormalizedCoord = distanceRaw(zeroZero, coord.toSigned());

        expect(distToCoord, distToNormalizedCoord);
      }
    });

    test('BBox.toSigned', () {
      for (var i = 0; i < 10; i++) {
        var coord = BBox.named(
          lat1: _rand(),
          lat2: _rand(),
          lng1: _rand(),
          lng2: _rand(),
        );
        var zeroZero = Position(0, 0);

        var distToCoord1 = distanceRaw(
            zeroZero, Position.named(lng: coord.lng1, lat: coord.lat1));
        var normalized = coord.toSigned();
        var distToNormalized = distanceRaw(
            zeroZero,
            Position.named(
                lat: normalized.lat1,
                lng: normalized.lng1,
                alt: normalized.alt1));
        expect(distToCoord1, distToNormalized);

        var distToCoord2 = distanceRaw(
            zeroZero, Position.named(lng: coord.lng2, lat: coord.lat2));
        var distToNormalized2 = distanceRaw(
            zeroZero,
            Position.named(
                lat: normalized.lat2,
                lng: normalized.lng2,
                alt: normalized.alt2));
        expect(distToCoord2, distToNormalized2);
      }
    });
    test('Point', () {});
    test('Point', () {});
    test('MultiPoint', () {});
    test('LineString', () {});
    test('MultiLineString', () {});
    test('Polygon', () {});
    test('MultiPolygon', () {});
    test('GeometryCollection', () {});
    test('Feature', () {});
    test('FeatureCollection', () {});
  });
}

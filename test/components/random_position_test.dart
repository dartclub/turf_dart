import 'package:turf/random_position.dart';
import 'package:turf/turf.dart';
import 'package:test/test.dart';

void main() {
  group('Random Position tests', () {
    test('Generating a random position within a bounding box', () {
      BBox bbox = BBox(100.0, -24.0, 110.0, -23.0);
      Position randomPos = randomPosition(bbox);

      expect(randomPos.lng, greaterThanOrEqualTo(bbox[0]!));
      expect(randomPos.lng, lessThanOrEqualTo(bbox[2]!));
      expect(randomPos.lat, greaterThanOrEqualTo(bbox[1]!));
      expect(randomPos.lat, lessThanOrEqualTo(bbox[3]!));
    });

    test('Check coordInBBox returns point within bbox', () {
      BBox bbox = BBox(100.0, -24.0, 110.0, -23.0);
      Position coord = coordInBBox(bbox);

      expect(coord.lng, greaterThanOrEqualTo(bbox[0]!));
      expect(coord.lng, lessThanOrEqualTo(bbox[2]!));
      expect(coord.lat, greaterThanOrEqualTo(bbox[1]!));
      expect(coord.lat, lessThanOrEqualTo(bbox[3]!));
    });

    test('randomPosition throws when bbox is null', () {
      expect(() => randomPosition(null), throwsArgumentError);
    });

    test('checkBBox throws when bbox is null', () {
      expect(() => checkBBox(null), throwsArgumentError);
    });
  });
}

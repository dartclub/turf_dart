import 'package:test/test.dart';
import 'package:turf/helpers.dart';
import 'package:turf/polyline.dart';

main() {
  group('Polyline:', () {
    var example = [
          Position.named(lat: 38.5, lng: -120.2),
          Position.named(lat: 40.7, lng: -120.95),
          Position.named(lat: 43.252, lng: -126.453),
        ],
        exampleWithZ = [
          Position.named(lat: 38.5, lng: -120.2, alt: 0),
          Position.named(lat: 40.7, lng: -120.95, alt: 0),
          Position.named(lat: 43.252, lng: -126.453, alt: 0)
        ],
        exampleZero = [
          Position.named(lat: 39, lng: -120),
          Position.named(lat: 41, lng: -121),
          Position.named(lat: 43, lng: -126),
        ],
        exampleSlashes = [
          Position.named(lat: 35.6, lng: -82.55),
          Position.named(lat: 35.59985, lng: -82.55015),
          Position.named(lat: 35.6, lng: -82.55)
        ],
        exampleRounding = [Position.named(lat: 0, lng: 0.000006), Position.named(lat: 0, lng: 0.000002)],
        exampleRoundingNegative = [
          Position.named(lat: 36.05322, lng: -112.084004),
          Position.named(lat: 36.053573, lng: -112.083914),
          Position.named(lat: 36.053845, lng: -112.083965)
        ];

    group('#decode():', () {
      test('decodes an empty Array', () {
        expect(Polyline.decode(''), equals([]));
      });
      test('decodes a String into an Array of lat/lon pairs', () {
        expect(Polyline.decode('_p~iF~ps|U_ulLnnqC_mqNvxq`@'), equals(example));
      });
      test('decodes with a custom precision', () {
        expect(Polyline.decode('_izlhA~rlgdF_{geC~ywl@_kwzCn`{nI', precision: 6), equals(example));
      });
      test('decodes with precision 0', () {
        expect(Polyline.decode('mAnFC@CH', precision: 0), equals(exampleZero));
      });
    });

    group('#identity', () {
      test('feed encode into decode and check if the result is the same as the input', () {
        expect(Polyline.decode(Polyline.encode(exampleSlashes)), exampleSlashes);
      });

      test('feed decode into encode and check if the result is the same as the input', () {
        expect(Polyline.encode(Polyline.decode('_chxEn`zvN\\\\]]')), equals('_chxEn`zvN\\\\]]'));
        // t.end();
      });
    });

    group('#encode()', () {
      test('encodes an empty Array', () {
        expect(Polyline.encode([]), equals(''));
      });

      test('encodes an Array of lat/lon pairs into a String', () {
        expect(Polyline.encode(example), equals('_p~iF~ps|U_ulLnnqC_mqNvxq`@'));
      });

      test('encodes an Array of lat/lon/z into the same string as lat/lon', () {
        expect(Polyline.encode(exampleWithZ), equals('_p~iF~ps|U_ulLnnqC_mqNvxq`@'));
      });

      test('encodes with proper rounding', () {
        expect(Polyline.encode(exampleRounding), equals('?A?@'));
      });

      test('encodes with proper negative rounding', () {
        expect(Polyline.encode(exampleRoundingNegative), equals('ss`{E~kbkTeAQw@J'));
      });

      test('encodes with a custom precision', () {
        expect(Polyline.encode(example, precision: 6), equals('_izlhA~rlgdF_{geC~ywl@_kwzCn`{nI'));
      });

      test('encodes with precision 0', () {
        expect(Polyline.encode(example, precision: 0), equals('mAnFC@CH'));
      });

      test('encodes negative values correctly', () {
        expect(
            Polyline.decode(Polyline.encode([Position.named(lat: -107.3741825, lng: 0)], precision: 7), precision: 7)[0].lat < 0, isTrue);
      });
    });
  });
}

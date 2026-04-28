import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:turf/to_mercator.dart';
import 'package:turf/to_wgs84.dart';
import 'package:turf/truncate.dart';
import 'package:turf_equality/turf_equality.dart';

void main() {
  group('geoToWgs84', () {
    // ── File-based tests (in/out GeoJSON pairs) ────────────────────────────
    final inDir = Directory('./test/examples/to_wgs84/in');
    for (final file in inDir.listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.geojson')) continue;

      test(file.path, () {
        final inGeom =
            GeoJSONObject.fromJson(jsonDecode(file.readAsStringSync()));

        // Convert, then truncate to 6 decimal places to match fixture precision
        final result = truncate(
          geoToWgs84(inGeom),
          precision: 6,
          coordinates: 3,
        );

        final outDir = Directory('./test/examples/to_wgs84/out');
        for (final file2 in outDir.listSync(recursive: true)) {
          if (file2 is File &&
              file2.uri.pathSegments.last == file.uri.pathSegments.last) {
            final outGeom =
                GeoJSONObject.fromJson(jsonDecode(file2.readAsStringSync()));
            expect(Equality().compare(result, outGeom), true);
          }
        }
      });
    }

    // ── Inline tests ────────────────────────────────────────────────────────
    test('does not mutate input by default', () {
      final pt = Feature(
        geometry: Point(
          coordinates: Position(-7903683.846322424, 5012341.663847514),
        ),
      );
      final originalLng = pt.geometry!.coordinates.lng;
      geoToWgs84(pt);
      expect(pt.geometry!.coordinates.lng, equals(originalLng));
    });

    test('mutates input when mutate: true', () {
      final pt = Feature(
        geometry: Point(
          coordinates: Position(-7903683.846322424, 5012341.663847514),
        ),
      );
      geoToWgs84(pt, mutate: true);
      expect(pt.geometry!.coordinates.lng, closeTo(-71.0, 0.000001));
    });

    test('round-trip WGS84 → Mercator → WGS84 on Point', () {
      final original = Feature(
        geometry: Point(coordinates: Position(-71.0, 41.0)),
      );
      final roundTrip = geoToWgs84(geoToMercator(original)) as Feature<Point>;
      expect(roundTrip.geometry!.coordinates.lng, closeTo(-71.0, 0.000001));
      expect(roundTrip.geometry!.coordinates.lat, closeTo(41.0, 0.000001));
    });

    test('round-trip preserves altitude', () {
      final original = Feature(
        geometry: Point(coordinates: Position(-71.0, 41.0, 500.0)),
      );
      final roundTrip = geoToWgs84(geoToMercator(original)) as Feature<Point>;
      expect(roundTrip.geometry!.coordinates.alt, equals(500.0));
    });
  });
}

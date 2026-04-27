import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:turf/to_mercator.dart';
import 'package:turf/truncate.dart';
import 'package:turf_equality/turf_equality.dart';

void main() {
  group('geoToMercator', () {
    // ── File-based tests (in/out GeoJSON pairs) ────────────────────────────
    final inDir = Directory('./test/examples/to_mercator/in');
    for (final file in inDir.listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.geojson')) continue;

      test(file.path, () {
        final inGeom =
            GeoJSONObject.fromJson(jsonDecode(file.readAsStringSync()));

        // Convert, then truncate to 6 decimal places to match fixture precision
        final result = truncate(
          geoToMercator(inGeom),
          precision: 6,
          coordinates: 3,
        );

        final outDir = Directory('./test/examples/to_mercator/out');
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
        geometry: Point(coordinates: Position(-71.0, 41.0)),
      );
      final originalLng = pt.geometry!.coordinates.lng;
      geoToMercator(pt);
      expect(pt.geometry!.coordinates.lng, equals(originalLng));
    });

    test('mutates input when mutate: true', () {
      final pt = Feature(
        geometry: Point(coordinates: Position(-71.0, 41.0)),
      );
      geoToMercator(pt, mutate: true);
      expect(pt.geometry!.coordinates.lng, closeTo(-7903683.846322, 0.01));
    });

    test('clamps y to maxExtent near poles', () {
      final pt = Feature(geometry: Point(coordinates: Position(0.0, 89.9)));
      final result = geoToMercator(pt) as Feature<Point>;
      expect(result.geometry!.coordinates.lat,
          lessThanOrEqualTo(20037508.342789244));
    });

    test('wraps longitude beyond 180', () {
      final pt = Feature(geometry: Point(coordinates: Position(181.0, 0.0)));
      final result = geoToMercator(pt) as Feature<Point>;
      // 181 wraps to -179, so x must be negative
      expect(result.geometry!.coordinates.lng, lessThan(0));
    });
  });
}

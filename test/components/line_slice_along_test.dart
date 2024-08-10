import 'package:test/test.dart';
import 'package:turf/turf.dart';

import '../context/load_test_cases.dart';

void main() {
  loadGeoJson('./test/examples/line_slice_along/fixtures/line1.geojson',
      (path, geoJson) {
    final line1 = Feature<LineString>(
      geometry: (geoJson as Feature).geometry as LineString,
    );

    test('turf-line-slice-along -- line1', () {
      const start = 500.0;
      const stop = 750.0;
      const options = Unit.miles;

      final startPoint = along(line1, start, options);
      final endPoint = along(line1, stop, options);
      final sliced = lineSliceAlong(line1, start, stop, options);

      expect(sliced, isA<Feature<LineString>>());
      expect(sliced.type, GeoJSONObjectType.feature);
      expect(sliced.geometry?.type, GeoJSONObjectType.lineString);
      expect(sliced.geometry?.coordinates[0],
          equals(startPoint.geometry!.coordinates));
      expect(
        sliced.geometry?.coordinates[sliced.geometry!.coordinates.length - 1],
        equals(endPoint.geometry!.coordinates),
      );
    });

    test('turf-line-slice-along -- line1 overshoot', () {
      const start = 500.0;
      const stop = 1500.0;
      const options = Unit.miles;

      final startPoint = along(line1, start, options);
      final endPoint = along(line1, stop, options);
      final sliced = lineSliceAlong(line1, start, stop, options);

      expect(sliced, isA<Feature<LineString>>());
      expect(sliced.type, GeoJSONObjectType.feature);
      expect(sliced.geometry?.type, GeoJSONObjectType.lineString);
      expect(sliced.geometry?.coordinates[0],
          equals(startPoint.geometry!.coordinates));
      expect(
        sliced.geometry?.coordinates[sliced.geometry!.coordinates.length - 1],
        equals(endPoint.geometry!.coordinates),
      );
    });

    test('turf-line-slice-along -- start longer than line length', () {
      const start = 500000.0;
      const stop = 800000.0;
      const options = Unit.miles;

      expect(
        () => lineSliceAlong(line1, start, stop, options),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Start position is beyond line'),
        )),
      );
    });

    test('turf-line-slice-along -- start equal to line length', () {
      const options = Unit.miles;
      final start = length(line1, options);
      final stop = start + 100;

      final startPoint = along(line1, start, options);
      final endPoint = along(line1, stop, options);
      final sliced =
          lineSliceAlong(line1, start.toDouble(), stop.toDouble(), options);

      expect(sliced, isA<Feature<LineString>>());
      expect(sliced.type, GeoJSONObjectType.feature);
      expect(sliced.geometry?.type, GeoJSONObjectType.lineString);
      expect(sliced.geometry?.coordinates[0],
          equals(startPoint.geometry!.coordinates));
      expect(
        sliced.geometry?.coordinates[sliced.geometry!.coordinates.length - 1],
        endPoint.geometry!.coordinates,
      );
    });
  });

  loadGeoJson('./test/examples/line_slice_along/fixtures/route1.geojson',
      (path, geoJson) {
    final route1 = Feature<LineString>(
      geometry: (geoJson as Feature).geometry as LineString,
    );

    test('turf-line-slice-along -- route1', () {
      const start = 500.0;
      const stop = 750.0;
      const options = Unit.miles;

      final startPoint = along(route1, start, options);
      final endPoint = along(route1, stop, options);
      final sliced = lineSliceAlong(route1, start, stop, options);

      expect(sliced, isA<Feature<LineString>>());
      expect(sliced.type, GeoJSONObjectType.feature);
      expect(sliced.geometry?.type, GeoJSONObjectType.lineString);
      expect(sliced.geometry?.coordinates[0],
          equals(startPoint.geometry!.coordinates));
      expect(
        sliced.geometry?.coordinates[sliced.geometry!.coordinates.length - 1],
        equals(endPoint.geometry!.coordinates),
      );
    });
  });

  loadGeoJson('./test/examples/line_slice_along/fixtures/route2.geojson',
      (path, geoJson) {
    final route2 = Feature<LineString>(
      geometry: (geoJson as Feature).geometry as LineString,
    );

    test('turf-line-slice-along -- route2', () {
      const start = 25.0;
      const stop = 50.0;
      const options = Unit.miles;

      final startPoint = along(route2, start, options);
      final endPoint = along(route2, stop, options);
      final sliced = lineSliceAlong(route2, start, stop, options);

      expect(sliced, isA<Feature<LineString>>());
      expect(sliced.type, GeoJSONObjectType.feature);
      expect(sliced.geometry?.type, GeoJSONObjectType.lineString);
      expect(sliced.geometry?.coordinates[0],
          equals(startPoint.geometry!.coordinates));
      expect(
        sliced.geometry?.coordinates[sliced.geometry!.coordinates.length - 1],
        equals(endPoint.geometry!.coordinates),
      );
    });
  });
}

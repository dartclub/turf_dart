import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:turf/helpers.dart';
import 'package:turf/src/booleans/boolean_helper.dart';
import 'package:turf/src/booleans/boolean_within.dart';

void main() {
  group('within - true', () {
    loadGeoJsonFiles('./test/examples/booleans/within/true', (path, geoJson) {
      final feature1 = (geoJson as FeatureCollection).features[0];
      final feature2 = geoJson.features[1];
      test(path, () => expect(booleanWithin(feature1, feature2), true));
    });
  });

  group('within - false', () {
    loadGeoJsonFiles('./test/examples/booleans/within/false', (path, geoJson) {
      final feature1 = (geoJson as FeatureCollection).features[0];
      final feature2 = geoJson.features[1];
      test(path, () => expect(booleanWithin(feature1, feature2), false));
    });
  });

  group('within', () {
    loadGeoJson(
        './test/examples/booleans/within/true/MultiPolygon/MultiPolygon/skip-multipolygon-within-multipolygon.geojson',
        (path, geoJson) {
      final feature1 = (geoJson as FeatureCollection).features[0];
      final feature2 = geoJson.features[1];

      test(
        'FeatureNotSupported',
        () => expect(
          () => booleanWithin(feature1, feature2),
          throwsA(isA<FeatureNotSupported>()),
        ),
      );
    });

    test('within - point in multipolygon with hole', () {
      loadGeoJson(
          './test/examples/booleans/point_in_polygon/in/multipoly-with-hole.geojson',
          (path, geoJson) {
        final multiPolygon = (geoJson as Feature);
        final pointInHole = point([-86.69208526611328, 36.20373274711739]);
        final pointInPolygon = point([-86.72229766845702, 36.20258997094334]);
        final pointInSecondPolygon =
            point([-86.75079345703125, 36.18527313913089]);

        expect(booleanWithin(pointInHole, multiPolygon), false,
            reason: "point in hole");
        expect(booleanWithin(pointInPolygon, multiPolygon), true,
            reason: "point in polygon");
        expect(booleanWithin(pointInSecondPolygon, multiPolygon), true,
            reason: "point outside polygon");
      });
    });

    test("within - point in polygon", () {
      final simplePolygon = polygon([
        [
          [0, 0],
          [0, 100],
          [100, 100],
          [100, 0],
          [0, 0],
        ],
      ]);
      final pointIn = point([50, 50]);
      final pointOut = point([140, 150]);

      expect(booleanWithin(pointIn, simplePolygon), true,
          reason: "point inside polygon");
      expect(booleanWithin(pointOut, simplePolygon), false,
          reason: "point outside polygon");

      final concavePolygon = polygon([
        [
          [0, 0],
          [50, 50],
          [0, 100],
          [100, 100],
          [100, 0],
          [0, 0],
        ],
      ]);

      final pointInConcave = point([75, 75]);
      final pointOutConcave = point([25, 50]);

      expect(booleanWithin(pointInConcave, concavePolygon), true,
          reason: "point inside concave polygon");
      expect(booleanWithin(pointOutConcave, concavePolygon), false,
          reason: "point outside concave polygon");
    });
  });
}

void loadGeoJson(
    String path, void Function(String path, GeoJSONObject geoJson) test) {
  final file = File(path);
  final content = file.readAsStringSync();
  final geoJson = GeoJSONObject.fromJson(jsonDecode(content));
  test(file.path, geoJson);
}

void loadGeoJsonFiles(
    String path, void Function(String path, GeoJSONObject geoJson) test) {
  final testDirectory = Directory(path);

  for (final file in testDirectory.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.geojson')) {
      if (file.path.contains('skip')) continue;

      final content = file.readAsStringSync();
      final geoJson = GeoJSONObject.fromJson(jsonDecode(content));
      test(file.path, geoJson);
    }
  }
}

Point point(List<double> coordinates) {
  return Point(coordinates: Position.of(coordinates));
}

Feature<Polygon> polygon(List<List<List<int>>> coordinates) {
  return Feature(
    geometry: Polygon(coordinates: coordinates.toPositions()),
  );
}

extension PointsExtension on List<List<int>> {
  List<Position> toPositions() =>
      map((position) => Position.of(position)).toList(growable: false);
}

extension PolygonPointsExtensions on List<List<List<int>>> {
  List<List<Position>> toPositions() =>
      map((element) => element.toPositions()).toList(growable: false);
}

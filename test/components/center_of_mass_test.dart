import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';
import 'package:turf/turf.dart';
import 'package:turf_equality/turf_equality.dart';
import 'package:turf/center_of_mass.dart';
import 'package:path/path.dart' as p;

void main() {
  group('centerOfMass', () {
    // Compute absolute paths based on the location of this test file
    final testDir = p.dirname(Platform.script.toFilePath());
    final inDir = p.normalize(p.join(testDir, '../examples/centerOfMass/in'));
    final outDir = p.normalize(p.join(testDir, '../examples/centerOfMass/out'));

    // safety check
    if (!Directory(inDir).existsSync()) {
      throw Exception('Input directory not found: $inDir');
    }

    test('centerOfMass - preserves custom properties', () {
      final polygon = Feature<Polygon>(
        geometry: Polygon(coordinates: [
          [
            Position(0, 0),
            Position(2, 0),
            Position(2, 2),
            Position(0, 2),
            Position(0, 0)
          ]
        ]),
      );
      final out = centerOfMass(polygon, properties: {'foo': 'bar'});
      expect(out.properties?['foo'], 'bar');
    });

    for (final file in Directory(inDir).listSync()) {
      if (file is! File || !file.path.endsWith('.geojson')) continue;

      final fileName = p.basename(file.path);

      test(fileName, () {
        final inSource = file.readAsStringSync();
        final input = GeoJSONObject.fromJson(jsonDecode(inSource));

        final result = centerOfMass(
          input,
          properties: {"marker-symbol": "star", "marker-color": "#F00"},
        );

        final resultCollection =
            FeatureCollection<GeometryObject>(features: [result]);
        featureEach(input, (f, i) => resultCollection.features.add(f));

        final expectedPath = p.join(outDir, fileName);
        if (!File(expectedPath).existsSync()) {
          fail('Expected out file not found for $fileName');
        }

        final expectedSource = File(expectedPath).readAsStringSync();
        final expected = GeoJSONObject.fromJson(jsonDecode(expectedSource));

        final resultCoords = result.geometry!.coordinates;
        final expectedFeature = (expected as FeatureCollection).features.first;
        final expectedPoint = expectedFeature.geometry as Point;
        final expectedCoords = expectedPoint.coordinates;
        expect(resultCoords.lng, closeTo(expectedCoords.lng, 1e-9),
            reason: 'Longitude mismatch for ${file.path}');
        expect(resultCoords.lat, closeTo(expectedCoords.lat, 1e-9),
            reason: 'Latitude mismatch for ${file.path}');
      });
    }
  });
}

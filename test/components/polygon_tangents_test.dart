import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';
import 'package:turf/turf.dart';
import '../context/helper.dart';

void main() {
  group('Polygon Tangents', () {
    // Unit tests for specific scenarios
    test('Calculates Tangents for Valid Geometries', () {
      final pt = point([61, 5]);
      final poly = polygon([
        [
          [11, 0],
          [22, 4],
          [31, 0],
          [31, 11],
          [21, 15],
          [11, 11],
          [11, 0],
        ],
      ]);

      final result = polygonTangents(pt.geometry!, poly);

      expect(result, isNotNull);
      expect(result.features.length, equals(2));
    });

    test('Ensures Input Immutability', () {
      final pt = point([61, 5]);
      final poly = polygon([
        [
          [11, 0],
          [22, 4],
          [31, 0],
          [31, 11],
          [21, 15],
          [11, 11],
          [11, 0],
        ],
      ]);

      final beforePoly = jsonEncode(poly.toJson());
      final beforePt = jsonEncode(pt.toJson());

      polygonTangents(pt.geometry!, poly);

      expect(jsonEncode(poly.toJson()), equals(beforePoly),
          reason: 'poly should not mutate');
      expect(jsonEncode(pt.toJson()), equals(beforePt),
          reason: 'pt should not mutate');
    });

    test('Detailed Polygon', () {
      final coordinates = Position.of([8.725, 51.57]);
      final pt = Feature<Point>(
        geometry: Point(coordinates: coordinates),
        properties: {},
      );

      final poly = polygon([
        [
          [8.788482103824089, 51.56063487730164],
          [8.788583, 51.561554],
          [8.78839, 51.562241],
          [8.78705, 51.563616],
          [8.785483, 51.564445],
          [8.785481, 51.564446],
          [8.785479, 51.564447],
          [8.785479, 51.564449],
          [8.785478, 51.56445],
          [8.785478, 51.564452],
          [8.785479, 51.564454],
          [8.78548, 51.564455],
          [8.785482, 51.564457],
          [8.786358, 51.565053],
          [8.787022, 51.565767],
          [8.787024, 51.565768],
          [8.787026, 51.565769],
          [8.787028, 51.56577],
          [8.787031, 51.565771],
          [8.787033, 51.565771],
          [8.789951649580397, 51.56585502173034],
          [8.789734, 51.563604],
          [8.788482103824089, 51.56063487730164],
        ],
      ]);

      try {
        final result = polygonTangents(pt.geometry!, poly);
        expect(result, isNotNull);
      } catch (e) {
        print('Detailed Polygon test failed: $e');
        fail('Test should not throw an exception');
      }
    });

    // File-based tests for real-world scenarios
    group('File-based Real-world Scenario Tests', () {
      var inDir = Directory('./test/examples/polygonTangents/in');
      for (var file in inDir.listSync(recursive: false)) {
        if (file is File && file.path.endsWith('.geojson')) {
          test(file.path, () {
            final inSource = file.readAsStringSync();
            final collection = FeatureCollection.fromJson(jsonDecode(inSource));

            final rawPoly = collection.features[0];
            final rawPt = collection.features[1];

            late Feature polyFeature;
            // Handle Polygon or MultiPolygon
            if (rawPoly.geometry?.type == GeoJSONObjectType.multiPolygon) {
              polyFeature = Feature<MultiPolygon>.fromJson(rawPoly.toJson());
            } else if (rawPoly.geometry?.type == GeoJSONObjectType.polygon) {
              polyFeature = Feature<Polygon>.fromJson(rawPoly.toJson());
            } else {
              throw ArgumentError(
                  'Unsupported geometry type: ${rawPoly.geometry?.type}');
            }

            final ptFeature = Feature<Point>.fromJson(rawPt.toJson());
            final FeatureCollection results = FeatureCollection(
              features: [
                ...polygonTangents(ptFeature.geometry!, polyFeature).features,
                polyFeature,
                ptFeature,
              ],
            );
          
            // Prepare output path
            var outPath = file.path.replaceAll('/in', '/out');
            var outFile = File(outPath);
            if (!outFile.existsSync()) {
              print('Warning: Output file not found at $outPath');
              return;
            }

            // Regenerate output if REGEN environment variable is set
            if (Platform.environment.containsKey('REGEN')) {
              outFile.writeAsStringSync(jsonEncode(results.toJson()));
            }

            if (!outFile.existsSync()) {
              print('Warning: Output file not found at $outPath');
              return;
            } else {
              var outSource = outFile.readAsStringSync();
              var expected = jsonDecode(outSource);

              expect(results.toJson(), equals(expected),
                  reason: 'Result should match expected output');
            }
          });
        }
      }
    });
  });
}

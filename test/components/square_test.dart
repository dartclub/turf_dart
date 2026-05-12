import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';
import 'package:turf/turf.dart';

void main() {
  group('Square BBox Transformation', () {
    // Unit tests for specific scenarios
    test('Square a horizontal rectangle', () {
      // Input: Rectangle wider than tall
      final bbox = BBox.named(lng1: 0, lat1: 0, lng2: 10, lat2: 5);

      final squaredBBox = square(bbox);

      // Verify square dimensions
      expect(squaredBBox.lng2 - squaredBBox.lng1,
          squaredBBox.lat2 - squaredBBox.lat1,
          reason: 'BBox should be a perfect square');

      // Verify center point remains the same
      expect((squaredBBox.lng1 + squaredBBox.lng2) / 2,
          (bbox.lng1 + bbox.lng2) / 2,
          reason: 'Center longitude should remain the same');
      expect((squaredBBox.lat1 + squaredBBox.lat2) / 2,
          (bbox.lat1 + bbox.lat2) / 2,
          reason: 'Center latitude should remain the same');
    });

    test('Square a vertical rectangle', () {
      // Input: Rectangle taller than wide
      final bbox = BBox.named(lng1: 0, lat1: 0, lng2: 5, lat2: 10);

      final squaredBBox = square(bbox);

      // Verify square dimensions
      expect(squaredBBox.lng2 - squaredBBox.lng1,
          squaredBBox.lat2 - squaredBBox.lat1,
          reason: 'BBox should be a perfect square');

      // Verify center point remains the same
      expect((squaredBBox.lng1 + squaredBBox.lng2) / 2,
          (bbox.lng1 + bbox.lng2) / 2,
          reason: 'Center longitude should remain the same');
      expect((squaredBBox.lat1 + squaredBBox.lat2) / 2,
          (bbox.lat1 + bbox.lat2) / 2,
          reason: 'Center latitude should remain the same');
    });

    test('Square an already square BBox', () {
      // Input: Already square BBox
      final bbox = BBox.named(lng1: 0, lat1: 0, lng2: 10, lat2: 10);

      final squaredBBox = square(bbox);

      // Verify dimensions remain the same
      expect(squaredBBox.lng2 - squaredBBox.lng1,
          squaredBBox.lat2 - squaredBBox.lat1,
          reason: 'BBox should remain a square');

      expect(squaredBBox.lng1, bbox.lng1);
      expect(squaredBBox.lat1, bbox.lat1);
      expect(squaredBBox.lng2, bbox.lng2);
      expect(squaredBBox.lat2, bbox.lat2);
    });

    test('Square a BBox with negative coordinates', () {
      // Input: BBox with negative coordinates
      final bbox = BBox.named(lng1: -10, lat1: -5, lng2: 0, lat2: 5);

      final squaredBBox = square(bbox);

      // Verify square dimensions
      expect(squaredBBox.lng2 - squaredBBox.lng1,
          squaredBBox.lat2 - squaredBBox.lat1,
          reason: 'BBox should be a perfect square');

      // Verify center point remains the same
      expect((squaredBBox.lng1 + squaredBBox.lng2) / 2,
          (bbox.lng1 + bbox.lng2) / 2,
          reason: 'Center longitude should remain the same');
      expect((squaredBBox.lat1 + squaredBBox.lat2) / 2,
          (bbox.lat1 + bbox.lat2) / 2,
          reason: 'Center latitude should remain the same');
    });

    // File-based test for real-world scenarios
    // File-based test for real-world scenarios
    group('File-based Tests', () {
      var inDir = Directory('./test/examples/square/in');
      if (inDir.existsSync()) {
        for (var file in inDir.listSync(recursive: true)) {
          if (file is File && file.path.endsWith('.geojson')) {
            test(file.path, () {
              var inSource = file.readAsStringSync();
              var inJson = jsonDecode(inSource);

              // Get the first feature
              var feature = inJson['features'][0];
              if (feature['geometry']['bbox'] == null) {
                throw Exception("Missing 'bbox' in GeoJSON feature geometry");
              }

              // Extract bbox from the geometry
              var bbox = feature['geometry']['bbox'];

              // Create BBox instance
              var geoBbox = BBox.named(
                lng1: bbox[0], // min longitude
                lat1: bbox[1], // min latitude
                lng2: bbox[2], // max longitude
                lat2: bbox[3], // max latitude
              );

              // Perform square operation (this doesn't change geometry type)
              BBox squaredBBox = square(geoBbox);

              // Create updated feature with new bbox but original geometry
              var updatedFeature = Map<String, dynamic>.from(feature);
              updatedFeature['geometry'] =
                  Map<String, dynamic>.from(feature['geometry']);
              updatedFeature['geometry']['bbox'] = [
                squaredBBox.lng1,
                squaredBBox.lat1,
                squaredBBox.lng2,
                squaredBBox.lat2,
              ];

              // Prepare output path
              var outPath = file.path.replaceAll('/in', '/out');
              var outFile = File(outPath);
              if (!outFile.existsSync()) {
                print('Warning: Output file not found at $outPath');
                return;
              }

              var outSource = outFile.readAsStringSync();
              var expectedOutput = jsonDecode(outSource);
              var expectedFeature = expectedOutput['features'][0];

              // Verify feature collection structure
              expect(expectedOutput['type'], 'FeatureCollection');

              // Compare geometry types (should remain unchanged)
              expect(
                updatedFeature['geometry']['type'],
                expectedFeature['geometry']['type'],
                reason: 'Geometry type should remain the same',
              );

              // Compare coordinates (should remain unchanged)
              expect(
                updatedFeature['geometry']['coordinates'],
                expectedFeature['geometry']['coordinates'],
                reason: 'Coordinates should remain unchanged',
              );

              // Compare the updated bbox values
              expect(
                updatedFeature['geometry']['bbox'],
                expectedFeature['geometry']['bbox'],
                reason: 'BBox should match expected squared version',
              );
            });
          }
        }
      }
    });
  });
}

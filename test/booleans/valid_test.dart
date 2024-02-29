import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:turf/boolean.dart';

void main() {
  group(
    'boolean-valid',
    () {
      /// Assertion error is caught in the fromJSON factory constructor of [GeometryType]s
      Directory dir = Directory('./test/examples/booleans/valid/assertion');
      for (var file in dir.listSync(recursive: true)) {
        test(
          file.path,
          () {
            // Assertion Error Fixtures
            if (file is File && file.path.endsWith('.geojson')) {
              var inSource = file.readAsStringSync();
              expect(
                () => booleanValid(
                  GeoJSONObject.fromJson(
                    jsonDecode(inSource),
                  ),
                ),
                throwsA(isA<AssertionError>()),
              );
            }
          },
        );
      }
      Directory dirFile = Directory('./test/examples/booleans/valid/false');
      for (var file in dirFile.listSync(recursive: true)) {
        test(
          file.path,
          () {
            // False Fixtures
            if (file is File && file.path.endsWith('.geojson')) {
              var inSource = file.readAsStringSync();
              expect(
                  booleanValid(
                    GeoJSONObject.fromJson(
                      jsonDecode(inSource),
                    ),
                  ),
                  isFalse);
            }
          },
        );
      }
      Directory dir1 = Directory('./test/examples/booleans/valid/true');
      for (var file in dir1.listSync(recursive: true)) {
        test(
          file.path,
          () {
            if (file is File && file.path.endsWith('.geojson')) {
              var inSource = file.readAsStringSync();
              var inGeom = GeoJSONObject.fromJson(jsonDecode(inSource));
              expect(booleanValid(inGeom), isTrue);
            }
          },
        );
      }
    },
  );
}

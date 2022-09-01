import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:test/test.dart';
import 'package:turf/src/booleans/boolean_valid.dart';
import 'package:turf/turf.dart';

main() {
  group(
    'boolean-valid',
    () {
      // Directory dir = Directory('./test/examples/booleans/valid/true');
      // for (var file in dir.listSync(recursive: true)) {
      //   test(
      //     file.path,
      //     () {
      //       // True Fixtures
      //       if (file is File && file.path.endsWith('.geojson')) {
      //         var inSource = file.readAsStringSync();
      //         var inGeom = GeoJSONObject.fromJson(jsonDecode(inSource));
      //         var result = booleanValid(inGeom);
      //         expect(result, true);
      //       }
      //     },
      //   );
      // }
      Directory dir1 = Directory('./test/examples/booleans/valid/false');
      for (var file in dir1.listSync(recursive: true)) {
        test(
          file.path,
          () {
            // False Fixtures
            if (file is File && file.path.endsWith('.geojson')) {
              var inSource = file.readAsStringSync();
              try {
                var inGeom = GeoJSONObject.fromJson(jsonDecode(inSource));
              } catch (e) {
                if (e is AssertionError) {
                  print('assertion worked in case of ${file.path}');
                }
              } finally {
                if (!e.toString().contains('Failed assersion')) {
                  var inGeom = GeoJSONObject.fromJson(jsonDecode(inSource));
                  var result = booleanValid(inGeom);
                  expect(result, false);
                }
              }
            }
          },
        );
      }
    },
  );
}

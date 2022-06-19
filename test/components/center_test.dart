import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:turf/meta.dart';
import 'package:turf/turf.dart';

main() {
  group(
    'explode in == out',
    () {
      var inDir = Directory('./test/examples/center/in');
      for (var file in inDir.listSync(recursive: true)) {
        if (file is File && file.path.endsWith('.geojson')) {
          test(
            file.path,
            () {
              var inSource = file.readAsStringSync();
              var inGeom = GeoJSONObject.fromJson(jsonDecode(inSource));
              Map<String, dynamic> properties = {
                "marker-symbol": "star",
                "marker-color": "#F00"
              };
              var inCenter = center(inGeom, properties: properties);
              var featureCollection = FeatureCollection()
                ..features.add(inCenter);

              featureEach(inGeom,
                  (feature, index) => featureCollection.features.add(feature));
              var extent = bboxPolygon(bbox(inGeom));
              extent.properties = {
                "stroke": "#00F",
                "stroke-width": 1,
                "fill-opacity": 0,
              };
              coordEach(
                extent,
                (
                  currentCoord,
                  coordIndex,
                  featureIndex,
                  multiFeatureIndex,
                  geometryIndex,
                ) =>
                    featureCollection.features.add(
                  Feature(
                    geometry: LineString(coordinates: [
                      currentCoord!,
                      inCenter.geometry!.coordinates
                    ]),
                    properties: {
                      'stroke': "#00F",
                      "stroke-width": 1,
                    },
                  ),
                ),
              );
              featureCollection.features.add(extent);
              var outPath = './' +
                  file.uri.pathSegments
                      .sublist(0, file.uri.pathSegments.length - 2)
                      .join('/') +
                  '/out/${file.uri.pathSegments.last}';
              var outSource = File(outPath).readAsStringSync();
              var outCenter =
                  FeatureCollection<Point>.fromJson(jsonDecode(outSource));

              for (var i = 0; i < featureCollection.features.length; i++) {
                var input = featureCollection.features[i];
                var output = outCenter.features[i];
                expect(input.id, output.id);
                expect(input.properties, equals(output.properties));
                expect(input.geometry, output.geometry);
              }
            },
          );
        }
      }
    },
  );
}

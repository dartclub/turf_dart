import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:turf/meta.dart';
import 'package:turf/src/bbox_polygon.dart';
import 'package:turf/turf.dart';

void main() {
  group(
    'center in == out',
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
              Feature<Point> inCenter = center(inGeom, properties: properties);
              FeatureCollection featureCollection =
                  FeatureCollection(features: [])..features.add(inCenter);
              featureEach(inGeom, (feature, index) {
                featureCollection.features.add(feature);
              });
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

              // ignore: prefer_interpolation_to_compose_strings
              var outPath = './' +
                  file.uri.pathSegments
                      .sublist(0, file.uri.pathSegments.length - 2)
                      .join('/') +
                  '/out/${file.uri.pathSegments.last}';

              var outSource = File(outPath).readAsStringSync();

              var outGeom = FeatureCollection.fromJson(jsonDecode(outSource));
              for (var i = 0; i < featureCollection.features.length; i++) {
                var input = featureCollection.features[i];
                var output = outGeom.features[i];
                expect(input.id, output.id);
                expect(input.properties, equals(output.properties));
                expect(input.geometry!.type, output.geometry!.type);
              }
            },
          );
        }
      }
    },
  );
}

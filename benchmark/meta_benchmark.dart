import 'package:benchmark/benchmark.dart';
import 'package:turf/helpers.dart';
import 'package:turf/meta.dart';

import 'dart:convert';
import 'dart:io';

void main() {
  Point pt = Point.fromJson({
    'coordinates': [0, 0]
  });

  Feature<Point> featurePt = Feature(geometry: pt.clone());

  List<Point> points = [];
  List<Feature<Point>> pointFeatures = [];

  for (int i = 0; i < 1000; i++) {
    points.add(pt.clone());
    pointFeatures.add(Feature(geometry: pt.clone()));
  }

  GeometryCollection geomCollection = GeometryCollection(
    geometries: points,
  );

  FeatureCollection featureCollection = FeatureCollection(
    features: pointFeatures,
  );

  group('coordEach', () {
    void coordEachNoopCB(
      CoordinateType? currentCoord,
      int? coordIndex,
      int? featureIndex,
      int? multiFeatureIndex,
      int? geometryIndex,
    ) {}

    benchmark('geometry', () {
      coordEach(pt, coordEachNoopCB);
    });

    benchmark('feature', () {
      coordEach(featurePt, coordEachNoopCB);
    });

    benchmark('geometry collection', () {
      coordEach(geomCollection, coordEachNoopCB);
    });

    benchmark('feature collection', () {
      coordEach(featureCollection, coordEachNoopCB);
    });

    var dir = Directory('./test/examples');
    for (var file in dir.listSync(recursive: true)) {
      if (file is File && file.path.endsWith('.geojson')) {
        var source = (file).readAsStringSync();
        var geoJSON = GeoJSONObject.fromJson(jsonDecode(source));
        benchmark(file.path, () {
          coordEach(geoJSON, coordEachNoopCB);
        });
      }
    }
  });

  group('geomEach', () {
    void geomEachNoopCB(
      GeometryObject? currentGeometry,
      int? featureIndex,
      Map<String, dynamic>? featureProperties,
      BBox? featureBBox,
      dynamic featureId,
    ) {}

    benchmark('geometry', () {
      geomEach(pt, geomEachNoopCB);
    });

    benchmark('feature', () {
      geomEach(featurePt, geomEachNoopCB);
    });

    benchmark('geometry collection', () {
      geomEach(geomCollection, geomEachNoopCB);
    });

    benchmark('feature collection', () {
      geomEach(featureCollection, geomEachNoopCB);
    });
  });

  group('propEach', () {
    void propEachNoopCB(
      Map<String, dynamic>? currentProperties,
      num featureIndex,
    ) {}

    benchmark('feature', () {
      propEach(featurePt, propEachNoopCB);
    });

    benchmark('feature collection', () {
      propEach(featureCollection, propEachNoopCB);
    });
  });

  group('featureEach', () {
    void featureEachNoopCB(
      Feature currentFeature,
      num featureIndex,
    ) {}

    benchmark('feature', () {
      featureEach(featurePt, featureEachNoopCB);
    });

    benchmark('feature collection', () {
      featureEach(featureCollection, featureEachNoopCB);
    });
  });
}

import 'package:test/test.dart';
import 'package:turf/helpers.dart';
import 'package:turf/meta.dart';

Feature<Point> pt = Feature<Point>(
  geometry: Point.fromJson({
    'coordinates': [0, 0],
  }),
  properties: {
    'a': 1,
  },
);
Feature<Point> pt2 = Feature<Point>(
  geometry: Point.fromJson({
    'coordinates': [1, 1],
  }),
);
Feature<LineString> line = Feature<LineString>(
  geometry: LineString.fromJson({
    'coordinates': [
      [0, 0],
      [1, 1],
    ]
  }),
);
Feature<MultiLineString> multiline = Feature<MultiLineString>(
  geometry: MultiLineString.fromJson({
    'coordinates': [
      [
        [0, 0],
        [1, 1],
      ],
      [
        [3, 3],
        [4, 4],
      ],
    ],
  }),
);
Feature<MultiPoint> multiPoint = Feature<MultiPoint>(
    geometry: MultiPoint.fromJson({
  'coordinates': [
    [0, 0],
    [1, 1],
  ],
}));
Feature<GeometryCollection> geomCollection = Feature<GeometryCollection>(
  geometry: GeometryCollection(
    geometries: [
      pt.geometry!,
      line.geometry!,
      multiline.geometry!,
    ],
  ),
);

List<GeoJSONObject> collection(Feature feature) {
  FeatureCollection featureCollection = FeatureCollection(
    features: [
      feature,
    ],
  );
  return [feature, featureCollection];
}

List<GeoJSONObject> featureAndCollection(GeometryObject geometry) {
  Feature feature = Feature(
    geometry: geometry,
    properties: {
      'a': 1,
    },
  );
  FeatureCollection featureCollection = FeatureCollection(
    features: [
      feature,
    ],
  );
  return [geometry, feature, featureCollection];
}

FeatureCollection fcMixed = FeatureCollection(
  features: [
    Feature<Point>(
      geometry: Point.fromJson({
        'coordinates': [0, 0],
      }),
    ),
    Feature<LineString>(
      geometry: LineString.fromJson({
        'coordinates': [
          [1, 1],
          [2, 2],
        ]
      }),
    ),
    Feature<MultiLineString>(
      geometry: MultiLineString.fromJson({
        'coordinates': [
          [
            [1, 1],
            [0, 0],
          ],
          [
            [4, 4],
            [5, 5],
          ],
        ],
      }),
    ),
  ],
);

main() {
  test('propEach --featureCollection', () {
    collection(pt).forEach((input) {
      propEach(input, (prop, i) {
        expect(prop, {'a': 1});
        expect(i, 0);
      });
    });
  });

  test('propEach --feature', () {
    propEach(pt, (prop, i) {
      expect(prop, {'a': 1});
      expect(i, 0);
    });
  });

  test('featureEach --featureCollection', () {
    collection(pt).forEach((input) {
      featureEach(input, (feature, i) {
        expect(feature.properties, {'a': 1});
        expect(
            feature.geometry,
            Point.fromJson({
              'coordinates': [0, 0],
            }));
        expect(i, 0);
      });
    });
  });

  test('featureEach --feature', () {
    featureEach(pt, (feature, i) {
      expect(feature.properties, {'a': 1});
      expect(
          feature.geometry,
          Point.fromJson({
            'coordinates': [0, 0],
          }));
      expect(i, 0);
    });
  });

  test('geomEach -- GeometryCollection', () {
    featureAndCollection(geomCollection.geometry!)
        .forEach((GeoJSONObject input) {
      List<GeometryObject> output = [];
      geomEach(input, (geom, i, props, bbox, id) {
        output.add(geom!);
      });
      expect(output, geomCollection.geometry!.geometries);
    });
  });

  test('geomEach -- bare-GeometryCollection', () {
    List<GeometryObject> output = [];
    geomEach(geomCollection, (geom, i, props, bbox, id) {
      output.add(geom!);
    });
    expect(output, geomCollection.geometry!.geometries);
  });

  test('geomEach -- bare-pointGeometry', () {
    List<GeometryObject> output = [];
    geomEach(pt.geometry!, (geom, i, props, bbox, id) {
      output.add(geom!);
    });
    expect(output, [pt.geometry]);
  });

  test('geomEach -- bare-pointFeature', () {
    List<GeometryObject> output = [];
    geomEach(pt, (geom, i, props, bbox, id) {
      output.add(geom!);
    });
    expect(output, [pt.geometry]);
  });

  test('geomEach -- multiGeometryFeature-properties', () {
    Map<String, dynamic>? lastProperties = {};
    geomEach(geomCollection, (geom, i, props, bbox, id) {
      lastProperties = props;
    });
    expect(lastProperties, geomCollection.properties);
  });

  test('geomEach -- callback BBox & Id', () {
    Map<String, dynamic> properties = {'foo': 'bar'};
    BBox bbox = BBox.fromJson([0, 0, 0, 0, 0, 0]);
    String id = 'foo';
    Feature<Point> pt = Feature<Point>(
      geometry: Point.fromJson({
        'coordinates': [0, 0],
      }),
      properties: properties,
      bbox: bbox,
      id: id,
    );
    geomEach(
      pt,
      (GeometryObject? currentGeometry,
          int? featureIndex,
          Map<String, dynamic>? featureProperties,
          BBox? featureBBox,
          dynamic featureId) {
        expect(featureIndex, 0, reason: 'featureIndex');
        expect(featureProperties, properties, reason: 'featureProperties');
        expect(featureBBox, bbox, reason: 'featureBBox');
        expect(featureId, id, reason: 'featureId');
      },
    );
  });

  group('meta -- breaking of iterations', () {
    FeatureCollection<LineString> lines = FeatureCollection<LineString>(
      features: [
        Feature<LineString>(
          geometry: LineString.fromJson({
            'coordinates': [
              [10, 10],
              [50, 30],
              [30, 40]
            ]
          }),
        ),
        Feature<LineString>(
          geometry: LineString.fromJson({
            'coordinates': [
              [-10, -10],
              [-50, -30],
              [-30, -40]
            ]
          }),
        ),
      ],
    );
    Feature<MultiLineString> multiLine = Feature<MultiLineString>(
      geometry: MultiLineString.fromJson({
        'coordinates': [
          [
            [10, 10],
            [50, 30],
            [30, 40]
          ],
          [
            [-10, -10],
            [-50, -30],
            [-30, -40]
          ]
        ]
      }),
    );

    int iterationCount = 0;

    void runBreakingIterationTest(dynamic func, dynamic callback) {
      iterationCount = 0;
      func(lines, callback);
      expect(iterationCount, 1, reason: func.toString());
      iterationCount = 0;
      func(multiLine, callback);
      expect(iterationCount, 1, reason: func.toString());
    }

    // Each Iterators
    // meta.segmentEach has been purposely excluded from this list
    // TODO fill out this list will all 'each' iterators
    test('geomEach', () {
      runBreakingIterationTest(geomEach, (geom, i, props, bbox, id) {
        iterationCount += 1;
        return false;
      });
    });

    test('flattenEach', () {
      runBreakingIterationTest(flattenEach, (feature, i, mI) {
        iterationCount += 1;
        return false;
      });
    });

    test('propEach', () {
      runBreakingIterationTest(propEach, (prop, i) {
        iterationCount += 1;
        return false;
      });
    });

    test('featureEach', () {
      runBreakingIterationTest(featureEach, (feature, i) {
        iterationCount += 1;
        return false;
      });
    });
  });

  test('flattenEach -- MultiPoint', () {
    featureAndCollection(multiPoint.geometry!).forEach((input) {
      List<GeometryObject?> output = [];
      flattenEach(input, (currentFeature, index, multiIndex) {
        output.add(currentFeature.geometry);
      });
      expect(output, [pt.geometry!, pt2.geometry!]);
    });
  });

  test('flattenEach -- Mixed FeatureCollection', () {
    List<Feature> features = [];
    List<int> featureIndices = [];
    List<int> multiFeatureIndicies = [];
    flattenEach(fcMixed, (currentFeature, index, multiIndex) {
      features.add(currentFeature);
      featureIndices.add(index);
      multiFeatureIndicies.add(multiIndex);
    });
    expect(featureIndices, [0, 1, 2, 2]);
    expect(multiFeatureIndicies, [0, 0, 0, 1]);
    expect(features.length, 4);
  });

  test('flattenEach -- Point-properties', () {
    collection(pt).forEach((input) {
      Map<String, dynamic>? lastProperties;
      flattenEach(input, (currentFeature, index, multiIndex) {
        lastProperties = currentFeature.properties;
      });
      expect(lastProperties, pt.properties);
    });
  });

  test('flattenEach -- multiGeometryFeature-properties', () {
    collection(geomCollection).forEach((element) {
      Map<String, dynamic>? lastProperties;
      flattenEach(element, (currentFeature, index, multiIndex) {
        lastProperties = currentFeature.properties;
      });
      expect(lastProperties, geomCollection.properties);
    });
  });
}

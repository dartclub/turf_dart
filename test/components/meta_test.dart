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

/// Returns a FeatureCollection with a total of 8 copies of [geometryType]
/// in a mix of features of [geometryType], and features of geometry collections
/// containing [geometryType]
FeatureCollection<GeometryObject> getAsMixedFeatCollection(
  GeometryType geometryType,
) {
  GeometryCollection geometryCollection = GeometryCollection(
    geometries: [
      geometryType,
      geometryType,
      geometryType,
    ],
  );
  Feature geomCollectionFeature = Feature(
    geometry: geometryCollection,
  );
  Feature geomFeature = Feature(
    geometry: geometryType,
  );
  return FeatureCollection<GeometryObject>(
    features: [
      geomFeature,
      geomCollectionFeature,
      geomFeature,
      geomCollectionFeature,
    ],
  );
}

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

  test('propEach --breaking of iterations', () {
    var count = 0;
    propEach(multiline, (prop, i) {
      count += 1;
      return false;
    });
    expect(count, 1);
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

  test('featureEach --breaking of iterations', () {
    var count = 0;
    featureEach(multiline, (feature, i) {
      count += 1;
      return false;
    });
    expect(count, 1);
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

  test('meta -- breaking of iterations', () {
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
    // Each Iterators
    // meta.segmentEach has been purposely excluded from this list
    // TODO fill out this list will all 'each' iterators
    for (Function func in [geomEach]) {
      // Meta Each function should only a value of 1 after returning `false`
      // FeatureCollection
      var count = 0;
      func(lines, (
        GeometryObject? currentGeometry,
        int? featureIndex,
        Map<String, dynamic>? featureProperties,
        BBox? featureBBox,
        dynamic featureId,
      ) {
        count += 1;
        return false;
      });
      expect(count, 1, reason: func.toString());
      // Multi Geometry
      var multiCount = 0;
      func(multiLine, (
        GeometryObject? currentGeometry,
        int? featureIndex,
        Map<String, dynamic>? featureProperties,
        BBox? featureBBox,
        dynamic featureId,
      ) {
        multiCount += 1;
        return false;
      });
      expect(multiCount, 1, reason: func.toString());
    }
  });

  test('geomReduce', () {
    int? countReducer(
      int? previousValue,
      currentGeometry,
      featureIndex,
      featureProperties,
      featureBBox,
      featureId,
    ) {
      return (previousValue ?? 0) + 1;
    }

    expect(geomReduce(geomCollection, countReducer, 0), 3);
    expect(geomReduce(geomCollection, countReducer, 5), 8);

    // test more complex feature collection with geoms and geomCollections
    expect(
      geomReduce<int>(
        getAsMixedFeatCollection(pt.geometry!),
        countReducer,
        0,
      ),
      8,
    );
    expect(
      geomReduce<int>(
        getAsMixedFeatCollection(pt.geometry!),
        countReducer,
        10,
      ),
      18,
    );
  });

  test('geomReduce -- no intial value', () {
    LineString? lineGenerator(
      LineString? previousValue,
      GeometryType? currentGeometry,
      int? featureIndex,
      Map<String, dynamic>? featureProperties,
      BBox? featureBBox,
      dynamic featureId,
    ) {
      if (currentGeometry is Point) {
        previousValue!.coordinates.add(currentGeometry.coordinates);
      } else if (currentGeometry is LineString) {
        previousValue!.coordinates.addAll(currentGeometry.coordinates);
      } else if (currentGeometry is MultiLineString) {
        for (List<Position> l in currentGeometry.coordinates) {
          previousValue!.coordinates.addAll(l);
        }
      }
      return previousValue;
    }

    FeatureCollection featureCollection = FeatureCollection(
      features: [
        line,
        pt,
        multiline,
      ],
    );

    LineString expectedLine = LineString.fromJson({
      'coordinates': [
        // line
        [0, 0],
        [1, 1],
        // point
        [0, 0],
        // multiline, line 1
        [0, 0],
        [1, 1],
        // multuline, line 2
        [3, 3],
        [4, 4],
      ]
    });
    LineString? actualLineString = geomReduce<LineString>(
      featureCollection,
      lineGenerator,
      null,
    );
    expect(actualLineString?.toJson(), expectedLine.toJson());
  });
}

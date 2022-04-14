import 'package:test/test.dart';
import 'package:turf/helpers.dart';
import 'package:turf/src/meta/coord.dart';
import 'package:turf/src/meta/feature.dart';
import 'package:turf/src/meta/flatten.dart';
import 'package:turf/src/meta/geom.dart';
import 'package:turf/src/meta/prop.dart';

Feature<Point> pt = Feature<Point>(
  geometry: Point(coordinates: Position(0, 0)),
  properties: {
    'a': 1,
  },
);

Feature<Point> pt2 = Feature<Point>(
  geometry: Point(coordinates: Position(1, 1)),
);

Feature<LineString> line = Feature<LineString>(
  geometry: LineString(coordinates: [
    Position(0, 0),
    Position(1, 1),
  ]),
);

Feature<Polygon> poly = Feature<Polygon>(
  geometry: Polygon(coordinates: [
    [
      Position(0, 0),
      Position(1, 1),
      Position(0, 1),
      Position(0, 0),
    ],
  ]),
);

Feature<Polygon> polyWithHole = Feature<Polygon>(
  geometry: Polygon(coordinates: [
    [
      Position(100.0, 0.0),
      Position(101.0, 0.0),
      Position(101.0, 1.0),
      Position(100.0, 1.0),
      Position(100.0, 0.0),
    ],
    [
      Position(100.2, 0.2),
      Position(100.8, 0.2),
      Position(100.8, 0.8),
      Position(100.2, 0.8),
      Position(100.2, 0.2),
    ],
  ]),
);

Feature<MultiLineString> multiline = Feature<MultiLineString>(
  geometry: MultiLineString(
    coordinates: [
      [
        Position(0, 0),
        Position(1, 1),
      ],
      [
        Position(3, 3),
        Position(4, 4),
      ],
    ],
  ),
);

Feature<MultiPoint> multiPoint = Feature<MultiPoint>(
  geometry: MultiPoint(
    coordinates: [
      Position(0, 0),
      Position(1, 1),
    ],
  ),
);

Feature<MultiPolygon> multiPoly = Feature<MultiPolygon>(
  geometry: MultiPolygon(coordinates: [
    [
      [
        Position(0, 0),
        Position(1, 1),
        Position(0, 1),
        Position(0, 0),
      ],
    ],
    [
      [
        Position(3, 3),
        Position(2, 2),
        Position(1, 2),
        Position(3, 3),
      ],
    ],
  ]),
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

FeatureCollection fcMixed = FeatureCollection(
  features: [
    Feature<Point>(
      geometry: Point(
        coordinates: Position(0, 0),
      ),
      properties: {'foo': 'bar'},
    ),
    Feature<LineString>(
        geometry: LineString(coordinates: [
          Position(1, 1),
          Position(2, 2),
        ]),
        properties: {'foo': 'buz'}),
    Feature<MultiLineString>(
        geometry: MultiLineString(
          coordinates: [
            [
              Position(0, 0),
              Position(1, 1),
            ],
            [
              Position(4, 4),
              Position(5, 5),
            ],
          ],
        ),
        properties: {'foo': 'qux'}),
  ],
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
  test('coordEach -- Point', () {
    featureAndCollection(pt.geometry!).forEach((input) {
      coordEach(input, (currentCoord, coordIndex, featureIndex,
          multiFeatureIndex, geometryIndex) {
        expect(currentCoord, [0, 0]);
        expect(coordIndex, 0);
        expect(featureIndex, 0);
        expect(multiFeatureIndex, 0);
        expect(geometryIndex, 0);
      });
    });
  });

  test('coordEach -- LineString', () {
    featureAndCollection(line.geometry!).forEach((input) {
      List<CoordinateType?> output = [];
      int? lastIndex = 0;
      coordEach(input, (currentCoord, coordIndex, featureIndex,
          multiFeatureIndex, geometryIndex) {
        output.add(currentCoord);
        lastIndex = coordIndex;
      });
      expect(output, [
        [0, 0],
        [1, 1]
      ]);
      expect(lastIndex, 1);
    });
  });

  test('coordEach -- Polygon', () {
    featureAndCollection(poly.geometry!).forEach((input) {
      List<CoordinateType?> output = [];
      int? lastIndex = 0;
      coordEach(input, (currentCoord, coordIndex, featureIndex,
          multiFeatureIndex, geometryIndex) {
        output.add(currentCoord);
        lastIndex = coordIndex;
      });
      expect(output, [
        [0, 0],
        [1, 1],
        [0, 1],
        [0, 0]
      ]);
      expect(lastIndex, 3);
    });
  });

  test('coordEach -- Polygon excludeWrapCoord', () {
    featureAndCollection(poly.geometry!).forEach((input) {
      List<CoordinateType?> output = [];
      int? lastIndex = 0;
      coordEach(input, (currentCoord, coordIndex, featureIndex,
          multiFeatureIndex, geometryIndex) {
        output.add(currentCoord);
        lastIndex = coordIndex;
      }, true);
      expect(lastIndex, 2);
    });
  });

  test('coordEach -- MultiPolygon', () {
    List<CoordinateType?> coords = [];
    List<int?> coordIndexes = [];
    List<int?> featureIndexes = [];
    List<int?> multiFeatureIndexes = [];
    coordEach(multiPoly, (currentCoord, coordIndex, featureIndex,
        multiFeatureIndex, geometryIndex) {
      coords.add(currentCoord);
      coordIndexes.add(coordIndex);
      featureIndexes.add(featureIndex);
      multiFeatureIndexes.add(multiFeatureIndex);
    });
    expect(coordIndexes, [0, 1, 2, 3, 4, 5, 6, 7]);
    expect(featureIndexes, [0, 0, 0, 0, 0, 0, 0, 0]);
    expect(multiFeatureIndexes, [0, 0, 0, 0, 1, 1, 1, 1]);
    expect(coords.length, 8);
  });

  test('coordEach -- FeatureCollection', () {
    List<CoordinateType?> coords = [];
    List<int?> coordIndexes = [];
    List<int?> featureIndexes = [];
    List<int?> multiFeatureIndexes = [];
    coordEach(fcMixed, (currentCoord, coordIndex, featureIndex,
        multiFeatureIndex, geometryIndex) {
      coords.add(currentCoord);
      coordIndexes.add(coordIndex);
      featureIndexes.add(featureIndex);
      multiFeatureIndexes.add(multiFeatureIndex);
    });
    expect(coordIndexes, [0, 1, 2, 3, 4, 5, 6]);
    expect(featureIndexes, [0, 1, 1, 2, 2, 2, 2]);
    expect(multiFeatureIndexes, [0, 0, 0, 0, 0, 1, 1]);
    expect(coords.length, 7);
  });

  test('coordEach -- Indexes -- PolygonWithHole', () {
    List<int?> coordIndexes = [];
    List<int?> featureIndexes = [];
    List<int?> multiFeatureIndexes = [];
    List<int?> geometryIndexes = [];
    coordEach(polyWithHole, (currentCoord, coordIndex, featureIndex,
        multiFeatureIndex, geometryIndex) {
      coordIndexes.add(coordIndex);
      featureIndexes.add(featureIndex);
      multiFeatureIndexes.add(multiFeatureIndex);
      geometryIndexes.add(geometryIndex);
    });
    expect(coordIndexes, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
    expect(featureIndexes, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
    expect(multiFeatureIndexes, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
    expect(geometryIndexes, [0, 0, 0, 0, 0, 1, 1, 1, 1, 1]);
  });

  test('coordEach -- Indexes -- Multi-Polygon with hole', () {
    List<int?> featureIndexes = [];
    List<int?> multiFeatureIndexes = [];
    List<int?> geometryIndexes = [];
    List<int?> coordIndexes = [];

    Feature<MultiPolygon> multiPolyWithHole = Feature<MultiPolygon>(
      geometry: MultiPolygon.fromJson({
        'coordinates': [
          [
            [
              [102.0, 2.0],
              [103.0, 2.0],
              [103.0, 3.0],
              [102.0, 3.0],
              [102.0, 2.0],
            ],
          ],
          [
            [
              [100.0, 0.0],
              [101.0, 0.0],
              [101.0, 1.0],
              [100.0, 1.0],
              [100.0, 0.0],
            ],
            [
              [100.2, 0.2],
              [100.8, 0.2],
              [100.8, 0.8],
              [100.2, 0.8],
              [100.2, 0.2],
            ],
          ],
        ]
      }),
    );

    coordEach(multiPolyWithHole, (currentCoord, coordIndex, featureIndex,
        multiFeatureIndex, geometryIndex) {
      coordIndexes.add(coordIndex);
      featureIndexes.add(featureIndex);
      multiFeatureIndexes.add(multiFeatureIndex);
      geometryIndexes.add(geometryIndex);
    });
    expect(coordIndexes, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]);
    expect(featureIndexes, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
    expect(multiFeatureIndexes, [0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]);
    expect(geometryIndexes, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1]);
  });

  test('coordEach -- Indexes -- Polygon with hole', () {
    List<int?> featureIndexes = [];
    List<int?> multiFeatureIndexes = [];
    List<int?> geometryIndexes = [];
    List<int?> coordIndexes = [];

    Feature<Polygon> polygonWithHole = Feature<Polygon>(
      geometry: Polygon.fromJson({
        'coordinates': [
          [
            [100.0, 0.0],
            [101.0, 0.0],
            [101.0, 1.0],
            [100.0, 1.0],
            [100.0, 0.0],
          ],
          [
            [100.2, 0.2],
            [100.8, 0.2],
            [100.8, 0.8],
            [100.2, 0.8],
            [100.2, 0.2],
          ],
        ]
      }),
    );

    coordEach(polygonWithHole, (currentCoord, coordIndex, featureIndex,
        multiFeatureIndex, geometryIndex) {
      coordIndexes.add(coordIndex);
      featureIndexes.add(featureIndex);
      multiFeatureIndexes.add(multiFeatureIndex);
      geometryIndexes.add(geometryIndex);
    });
    expect(coordIndexes, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
    expect(featureIndexes, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
    expect(multiFeatureIndexes, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
    expect(geometryIndexes, [0, 0, 0, 0, 0, 1, 1, 1, 1, 1]);
  });

  test('coordEach -- Indexes -- FeatureCollection of LineString', () {
    List<int?> featureIndexes = [];
    List<int?> multiFeatureIndexes = [];
    List<int?> geometryIndexes = [];
    List<int?> coordIndexes = [];

    FeatureCollection line = FeatureCollection(features: [
      Feature<LineString>(
        geometry: LineString.fromJson({
          'coordinates': [
            [100.0, 0.0],
            [101.0, 0.0],
            [101.0, 1.0],
            [100.0, 1.0],
            [100.0, 0.0],
          ]
        }),
      ),
      Feature<LineString>(
        geometry: LineString.fromJson({
          'coordinates': [
            [100.2, 0.2],
            [100.8, 0.2],
            [100.8, 0.8],
            [100.2, 0.8],
            [100.2, 0.2],
          ]
        }),
      ),
    ]);

    coordEach(line, (currentCoord, coordIndex, featureIndex, multiFeatureIndex,
        geometryIndex) {
      coordIndexes.add(coordIndex);
      featureIndexes.add(featureIndex);
      multiFeatureIndexes.add(multiFeatureIndex);
      geometryIndexes.add(geometryIndex);
    });
    expect(coordIndexes, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
    expect(featureIndexes, [0, 0, 0, 0, 0, 1, 1, 1, 1, 1]);
    expect(multiFeatureIndexes, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
    expect(geometryIndexes, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
  });

  test('coordEach -- breaking of iterations - featureCollection', () {
    var count = 0;

    FeatureCollection lines = FeatureCollection(features: [
      Feature<LineString>(
        geometry: LineString.fromJson({
          'coordinates': [
            [10, 10],
            [50, 30],
            [30, 40],
          ]
        }),
      ),
      Feature<LineString>(
        geometry: LineString.fromJson({
          'coordinates': [
            [-10, -10],
            [-50, -30],
            [-30, -40],
          ]
        }),
      ),
    ]);

    coordEach(lines, (currentCoord, coordIndex, featureIndex, multiFeatureIndex,
        geometryIndex) {
      count += 1;
      return false;
    });
    expect(count, 1);
  });

  test('coordEach -- breaking of iterations - multiGeometry', () {
    var count = 0;
    coordEach(multiline, (currentCoord, coordIndex, featureIndex,
        multiFeatureIndex, geometryIndex) {
      count += 1;
      return false;
    });
    expect(count, 1);
  });

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
    List<int> featureIndexes = [];
    List<int> multiFeatureIndicies = [];
    flattenEach(fcMixed, (currentFeature, index, multiIndex) {
      features.add(currentFeature);
      featureIndexes.add(index);
      multiFeatureIndicies.add(multiIndex);
    });
    expect(featureIndexes, [0, 1, 2, 2]);
    expect(multiFeatureIndicies, [0, 0, 0, 1]);
    expect(features.length, 4);
    expect(features[0].geometry, isA<Point>());
    expect(features[1].geometry, isA<LineString>());
    expect(features[2].geometry, isA<LineString>());
    expect(features[3].geometry, isA<LineString>());
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

  test('propReduce with initialValue', () {
    String concatPropertyValues(
      previousValue,
      currentProperties,
      featureIndex,
    ) {
      return "$previousValue ${currentProperties?.values.first}";
    }

    expect(propReduce(pt, concatPropertyValues, 'hello'), 'hello 1');
  });

  test('propReduce -- without initial value', () {
    Map<String, dynamic>? concatPropertyValues(
      Map<String, dynamic>? previousValue,
      Map<String, dynamic>? currentProperties,
      num featureIndex,
    ) {
      return {'foo': previousValue!['foo'] + currentProperties!['foo']};
    }

    var results =
        propReduce<Map<String, dynamic>>(fcMixed, concatPropertyValues, null);
    expect(results?['foo'], 'barbuzqux');
  });

  test('featureReduce -- with/out initialValue', () {
    int? countReducer(
      int? previousValue,
      currentFeature,
      featureIndex,
    ) {
      return (previousValue ?? 0) + 1;
    }

    expect(featureReduce<int>(fcMixed, countReducer, null), 3);
    expect(featureReduce<int>(fcMixed, countReducer, 5), 8);
    expect(featureReduce<int>(pt, countReducer, null), 1);
  });
  test('flattenReduce -- with/out initialValue', () {
    int? countReducer(int? previousValue, Feature currentFeature,
        int featureIndex, int multiFeatureIndex) {
      return (previousValue ?? 0) + 1;
    }

    expect(flattenReduce<int>(fcMixed, countReducer, null), 4);
    expect(flattenReduce<int>(fcMixed, countReducer, 5), 9);
    expect(flattenReduce<int>(pt, countReducer, null), 1);
  });

  test('coordReduce -- with/out initialValue', () {
    int? countReducer(
      int? previousValue,
      Position? currentCoord,
      int? coordIndex,
      int? featureIndex,
      int? multiFeatureIndex,
      int? geometryIndex,
    ) {
      return (previousValue ?? 0) + 1;
    }

    expect(coordReduce<int>(fcMixed, countReducer, null), 7);
    expect(coordReduce<int>(fcMixed, countReducer, 5), 12);
    expect(coordReduce<int>(pt, countReducer, null), 1);
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

  test('geomReduce  -- no intial value and dynamic types', () {
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

    LineString? lineGeneratorDynamic(
      dynamic previousValue,
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

    LineString? actualDynamic = geomReduce(
      featureCollection,
      lineGeneratorDynamic,
      null,
    );
    expect(actualDynamic?.toJson(), expectedLine.toJson());
  });

  test('meta -- coordAll', () {
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

    List<Position?> results = coordAll(lines);
    expect(results, [
      Position.of([10, 10]),
      Position.of([50, 30]),
      Position.of([30, 40]),
      Position.of([-10, -10]),
      Position.of([-50, -30]),
      Position.of([-30, -40]),
    ]);
  });
}

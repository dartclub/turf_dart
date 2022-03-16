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

Feature<Polygon> poly = Feature<Polygon>(
  geometry: Polygon.fromJson({
    'coordinates': [
      [
        [0, 0],
        [1, 1],
        [0, 1],
        [0, 0],
      ],
    ]
  }),
);

Feature<Polygon> polyWithHole = Feature<Polygon>(
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

Feature<MultiPolygon> multiPoly = Feature<MultiPolygon>(
  geometry: MultiPolygon.fromJson({
    'coordinates': [
      [
        [
          [0, 0],
          [1, 1],
          [0, 1],
          [0, 0],
        ],
      ],
      [
        [
          [3, 3],
          [2, 2],
          [1, 2],
          [3, 3],
        ],
      ],
    ]
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

FeatureCollection fcMixed = FeatureCollection(features: [
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
]);

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

  test('coordEach -- indexes -- PolygonWithHole', () {
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

  test('coordEach -- indexes -- Multi-Polygon with hole', () {
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

  test('coordEach -- indexes -- Polygon with hole', () {
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

  test('coordEach -- indexes -- FeatureCollection of LineString', () {
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

    List<Position> results = coordAll(lines) as List<Position>;
    expect(results, [
      Position.of([10, 10]),
      Position.of([50, 30]),
      Position.of([30, 40])
    ]);
  });
}

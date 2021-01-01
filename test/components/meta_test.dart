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
      pt.geometry,
      line.geometry,
      multiline.geometry,
    ],
  ),
);
List<GeoJSONObject> featureAndCollection(Geometry geometry) {
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
  test('geomEach -- GeometryCollection', () {
    featureAndCollection(geomCollection.geometry)
        .forEach((GeoJSONObject input) {
      List<Geometry> output = [];
      geomEach(input, (geom, i, props, bbox, id) {
        output.add(geom);
      });
      expect(output, geomCollection.geometry.geometries);
    });
  });

  test('geomEach -- bare-GeometryCollection', () {
    List<Geometry> output = [];
    geomEach(geomCollection, (geom, i, props, bbox, id) {
      output.add(geom);
    });
    expect(output, geomCollection.geometry.geometries);
  });

  test('geomEach -- bare-pointGeometry', () {
    List<Geometry> output = [];
    geomEach(pt.geometry, (geom, i, props, bbox, id) {
      output.add(geom);
    });
    expect(output, [pt.geometry]);
  });

  test('geomEach -- bare-pointFeature', () {
    List<Geometry> output = [];
    geomEach(pt, (geom, i, props, bbox, id) {
      output.add(geom);
    });
    expect(output, [pt.geometry]);
  });

  test('geomEach -- multiGeometryFeature-properties', () {
    Map<String, dynamic> lastProperties = {};
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
      (Geometry currentGeometry,
          int featureIndex,
          Map<String, dynamic> featureProperties,
          BBox featureBBox,
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
        Geometry currentGeometry,
        int featureIndex,
        Map<String, dynamic> featureProperties,
        BBox featureBBox,
        dynamic featureId,
      ) {
        count += 1;
        return false;
      });
      expect(count, 1, reason: func.toString());
      // Multi Geometry
      var multiCount = 0;
      func(multiLine, (
        Geometry currentGeometry,
        int featureIndex,
        Map<String, dynamic> featureProperties,
        BBox featureBBox,
        dynamic featureId,
      ) {
        multiCount += 1;
        return false;
      });
      expect(multiCount, 1, reason: func.toString());
    }
  });
}
